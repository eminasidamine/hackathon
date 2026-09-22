import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'cart_controller.dart';
import 'storage_service.dart';

class OrderService {
  final SupabaseClient _client = Supabase.instance.client;
  final StorageService _storage = StorageService();

  Future<List<String>> checkout(
    CartController cart, {
    required String phone,
    required Map<String, String> paymentReferencesByShop,
    required double? deliveryLat,
    required double? deliveryLng,
    String? deliveryAddress,
    String deliveryMode = 'pickup',
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not signed in');
    final cleanPhone = phone.trim();
    if (cleanPhone.isEmpty) throw Exception('Phone number is required.');
    final cleanAddress = (deliveryAddress ?? '').trim();
    if (deliveryLat == null && cleanAddress.isEmpty) {
      throw Exception('Delivery location is required.');
    }

    final profileRow =
        await _client.from('profiles').select().eq('id', user.id).single();

    final shopIds = cart.linesByShop.keys.toList();
    final providerByShop = <String, String?>{};
    try {
      final rows = await _client
          .from('shops')
          .select('id, merchant_provider')
          .inFilter('id', shopIds);
      for (final row in rows) {
        providerByShop[row['id'] as String] =
            row['merchant_provider'] as String?;
      }
    } catch (_) {}

    final createdOrderIds = <String>[];

    for (final entry in cart.linesByShop.entries) {
      final shopId = entry.key;
      final lines = entry.value;
      final total = lines.fold<double>(0, (sum, l) => sum + l.subtotal);

      final orderRow = await _client
          .from('orders')
          .insert({
            'client_id': user.id,
            'shop_id': shopId,
            'total': total,
            'client_full_name': profileRow['full_name'] ?? '',
            'client_phone': cleanPhone,
            'client_city': profileRow['city'],
            'client_address':
                cleanAddress.isEmpty ? profileRow['address'] : cleanAddress,
            'payment_reference': paymentReferencesByShop[shopId]?.trim() ?? '',
            'payment_provider': providerByShop[shopId],
            'delivery_lat': deliveryLat,
            'delivery_lng': deliveryLng,
            'delivery_mode': deliveryMode,
          })
          .select()
          .single();

      final orderId = orderRow['id'] as String;

      if (deliveryMode == 'delivery' &&
          deliveryLat != null &&
          deliveryLng != null) {
        try {
          final shopRow = await _client
              .from('shops')
              .select('lat, lng')
              .eq('id', shopId)
              .maybeSingle();
          await _client.from('delivery_requests').insert({
            'order_id': orderId,
            'shop_id': shopId,
            'pickup_lat': shopRow?['lat'],
            'pickup_lng': shopRow?['lng'],
            'dropoff_lat': deliveryLat,
            'dropoff_lng': deliveryLng,
          });
        } catch (e) {
          print('Delivery request not created: $e');
        }
      }

      final items = lines
          .map((l) => {
                'order_id': orderId,
                'product_id': l.product.id,
                'product_name': l.selectedOption == null
                    ? l.product.name
                    : '${l.product.name} — ${l.selectedOption}',
                'unit_price': l.product.price,
                'quantity': l.quantity,
                'subtotal': l.subtotal,
              })
          .toList();
      await _client.from('order_items').insert(items);

      createdOrderIds.add(orderId);
      cart.clearShop(shopId);
    }

    if (cleanPhone != ((profileRow['phone'] as String?) ?? '')) {
      await _client
          .from('profiles')
          .update({'phone': cleanPhone}).eq('id', user.id);
    }

    return createdOrderIds;
  }

  Future<void> cancelOrder(String orderId) async {
    final updated = await _client
        .from('orders')
        .update({'status': 'cancelled'})
        .eq('id', orderId)
        .eq('status', 'pending')
        .select('id');
    if (updated.isEmpty) {
      throw Exception(
        'This order can no longer be cancelled: the shop has already taken it in charge.',
      );
    }
  }

  Future<List<OrderModel>> fetchMyOrders() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final rows = await _client
        .from('orders')
        .select('*, shops(name)')
        .eq('client_id', user.id)
        .order('created_at', ascending: false);
    return rows.map((r) => OrderModel.fromMap(r)).toList();
  }

  Future<void> attachPaymentProof({
    required String orderId,
    required Uint8List bytes,
    String extension = 'jpg',
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not signed in');
    final path = await _storage.uploadPaymentProof(
      userId: user.id,
      orderId: orderId,
      bytes: bytes,
      extension: extension,
    );
    final updated = await _client
        .from('orders')
        .update({'payment_proof_url': path})
        .eq('id', orderId)
        .select('id');
    if (updated.isEmpty) {
      throw Exception(
        'The payment proof could not be attached to the order '
        '(the database refused the update). The order itself was '
        'created. Fix: run supabase/securite_patch.sql.',
      );
    }
  }

  Future<void> submitVendorApplication({
    required String shopName,
    required String phone,
    String? description,
    String? city,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not signed in');
    await _client.from('vendor_applications').insert({
      'applicant_id': user.id,
      'shop_name': shopName,
      'phone': phone,
      'description': description,
      'city': city,
    });
  }
}
