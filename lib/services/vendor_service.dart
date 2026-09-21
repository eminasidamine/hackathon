import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class VendorService {
  final SupabaseClient _client = Supabase.instance.client;

  static const String _productSelect =
      'id, shop_id, category_id, name, description, price, compare_at_price, stock, is_visible, '
      'created_at, option_name, option_values, option_type, option_colors, option_sold_out, brand, '
      'product_images(url, sort_order, focal_x, focal_y, zoom), shops(id, name, logo_url, is_visible)';

  Future<Shop?> fetchMyShop() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from('shops')
        .select()
        .eq('owner_id', userId)
        .maybeSingle();
    return row == null ? null : Shop.fromMap(row);
  }

  Future<Shop> createMyShop({
    required String name,
    String? description,
    String? logoUrl,
    String? city,
    String? whatsappPhone,
    String? merchantCode,
    String? merchantProvider,
    double? lat,
    double? lng,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final row = await _client
        .from('shops')
        .insert({
          'owner_id': userId,
          'name': name,
          'description': description,
          'logo_url': logoUrl,
          'city': city,
          'whatsapp_phone': whatsappPhone,
          'merchant_code': merchantCode,
          'merchant_provider': merchantProvider,
          'lat': lat,
          'lng': lng,
        })
        .select()
        .single();
    return Shop.fromMap(row);
  }

  Future<void> updateMyShop({
    required String shopId,
    String? name,
    String? description,
    String? logoUrl,
    String? city,
    String? whatsappPhone,
    String? merchantCode,
    String? merchantProvider,
    double? lat,
    double? lng,
  }) async {
    await _client.from('shops').update({
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (city != null) 'city': city,
      if (whatsappPhone != null) 'whatsapp_phone': whatsappPhone,
      if (merchantCode != null) 'merchant_code': merchantCode,
      if (merchantProvider != null) 'merchant_provider': merchantProvider,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    }).eq('id', shopId);
  }

  Future<void> setMyShopCategories(
      {required String shopId, required List<String> categoryIds}) async {
    await _client.from('shop_categories').delete().eq('shop_id', shopId);
    if (categoryIds.isEmpty) return;
    await _client.from('shop_categories').insert([
      for (final id in categoryIds) {'shop_id': shopId, 'category_id': id},
    ]);
  }

  Future<List<Category>> fetchMyShopCategories(String shopId) async {
    final rows = await _client
        .from('shop_categories')
        .select('categories(*)')
        .eq('shop_id', shopId);
    return rows
        .map((r) => r['categories'] as Map<String, dynamic>?)
        .where((c) => c != null)
        .map((c) => Category.fromMap(c!))
        .toList();
  }

  Future<void> deleteMyShop(String shopId) async {
    await _client.from('shops').delete().eq('id', shopId);
  }

  Future<List<Product>> fetchMyProducts(String shopId) async {
    final rows = await _client
        .from('products')
        .select(_productSelect)
        .eq('shop_id', shopId)
        .order('created_at', ascending: false);
    return rows.map((r) => Product.fromMap(r)).toList();
  }

  Future<String> createMyProduct({
    required String shopId,
    String? categoryId,
    required String name,
    String? description,
    required double price,
    double? compareAtPrice,
    int stock = 0,
    String? optionName,
    List<String> optionValues = const [],
    String optionType = 'text',
    List<String> optionColors = const [],
    List<bool> optionSoldOut = const [],
    String? brand,
  }) async {
    final row = await _client
        .from('products')
        .insert({
          'shop_id': shopId,
          'category_id': categoryId,
          'name': name,
          'description': description,
          'price': price,
          'compare_at_price': compareAtPrice,
          'stock': stock,
          'option_name': optionName,
          'option_values': optionValues,
          'option_type': optionType,
          'option_colors': optionColors,
          'option_sold_out': optionSoldOut,
          'brand': brand,
        })
        .select()
        .single();
    return row['id'] as String;
  }

  Future<void> updateMyProduct({
    required String id,
    String? name,
    String? description,
    double? price,
    double? compareAtPrice,
    bool clearCompareAtPrice = false,
    int? stock,
    String? optionName,
    bool clearOptionName = false,
    List<String>? optionValues,
    String? optionType,
    List<String>? optionColors,
    List<bool>? optionSoldOut,
    String? brand,
  }) async {
    await _client.from('products').update({
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (compareAtPrice != null) 'compare_at_price': compareAtPrice,
      if (clearCompareAtPrice) 'compare_at_price': null,
      if (stock != null) 'stock': stock,
      if (optionName != null) 'option_name': optionName,
      if (clearOptionName) 'option_name': null,
      if (optionValues != null) 'option_values': optionValues,
      if (optionType != null) 'option_type': optionType,
      if (optionColors != null) 'option_colors': optionColors,
      if (optionSoldOut != null) 'option_sold_out': optionSoldOut,
      if (brand != null) 'brand': brand.isEmpty ? null : brand,
    }).eq('id', id);
  }

  Future<List<ProductImage>> fetchMyProductImages(String productId) async {
    final rows = await _client
        .from('product_images')
        .select('id, url, sort_order, focal_x, focal_y, zoom')
        .eq('product_id', productId)
        .order('sort_order');
    return rows.map((r) => ProductImage.fromMap(r)).toList();
  }

  Future<void> deleteMyProductImage(String imageId) async {
    await _client.from('product_images').delete().eq('id', imageId);
  }

  Future<void> updateMyProductImageFocal({
    required String imageId,
    required double focalX,
    required double focalY,
    required double zoom,
  }) async {
    await _client.from('product_images').update(
        {'focal_x': focalX, 'focal_y': focalY, 'zoom': zoom}).eq('id', imageId);
  }

  Future<void> reorderMyProductImages(List<String> orderedImageIds) async {
    for (var i = 0; i < orderedImageIds.length; i++) {
      await _client
          .from('product_images')
          .update({'sort_order': i}).eq('id', orderedImageIds[i]);
    }
  }

  Future<void> setMyProductVisible(String id, bool visible) async {
    await _client.from('products').update({'is_visible': visible}).eq('id', id);
  }

  Future<void> deleteMyProduct(String id) async {
    await _client.from('products').delete().eq('id', id);
  }

  Future<void> addMyProductImage({
    required String productId,
    required String url,
    int sortOrder = 0,
    double focalX = 0.5,
    double focalY = 0.5,
    double zoom = 1.0,
  }) async {
    await _client.from('product_images').insert({
      'product_id': productId,
      'url': url,
      'sort_order': sortOrder,
      'focal_x': focalX,
      'focal_y': focalY,
      'zoom': zoom,
    });
  }

  Future<List<OrderModel>> fetchMyShopOrders(String shopId) async {
    final rows = await _client
        .from('orders')
        .select('*, shops(name)')
        .eq('shop_id', shopId)
        .order('created_at', ascending: false);
    return rows.map((r) => OrderModel.fromMap(r)).toList();
  }

  Future<List<OrderItemModel>> fetchOrderItems(String orderId) async {
    final rows =
        await _client.from('order_items').select().eq('order_id', orderId);
    return rows.map((r) => OrderItemModel.fromMap(r)).toList();
  }

  Future<void> updateOrderStatus(String id, String status) async {
    await _client.from('orders').update({
      'status': status,
      if (status == 'confirmed')
        'confirmed_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> setPaymentStatus(
    String orderId,
    String status, {
    double? amountReceived,
  }) async {
    assert(
        status == 'verified' || status == 'rejected' || status == 'submitted');
    final updated = await _client
        .from('orders')
        .update({
          'payment_status': status,
          if (status == 'verified') 'payment_amount_received': amountReceived,
        })
        .eq('id', orderId)
        .select('id');
    if (updated.isEmpty) {
      throw Exception(
        'The payment status could not be saved (the database refused the '
        'update). Fix: run supabase/vendor_payment_tracking_patch.sql.',
      );
    }
  }
}
