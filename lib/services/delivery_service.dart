import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class DeliveryService {
  final SupabaseClient _client = Supabase.instance.client;

  static const String _boardSelect =
      'id, order_id, shop_id, pickup_lat, pickup_lng, dropoff_lat, dropoff_lng, distance_km, '
      'status, driver_id, created_at, shops(name, city), orders(total)';

  Future<DriverProfile?> fetchMyDriverProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from('driver_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return row == null ? null : DriverProfile.fromMap(row);
  }

  Future<DriverProfile> becomeDriver({String? vehicleType}) async {
    final userId = _client.auth.currentUser!.id;
    final row = await _client
        .from('driver_profiles')
        .insert(
            {'id': userId, 'vehicle_type': vehicleType, 'is_available': true})
        .select()
        .single();
    return DriverProfile.fromMap(row);
  }

  Future<void> setAvailability(bool available) async {
    final userId = _client.auth.currentUser!.id;
    await _client
        .from('driver_profiles')
        .update({'is_available': available}).eq('id', userId);
  }

  Future<List<Map<String, dynamic>>> fetchPendingDrivers() async {
    final rows = await _client
        .from('driver_profiles')
        .select(
            'id, vehicle_type, status, created_at, profiles(full_name, email, phone)')
        .eq('status', 'pending')
        .order('created_at');
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<void> setDriverStatus(String driverId, String status) async {
    await _client
        .from('driver_profiles')
        .update({'status': status}).eq('id', driverId);
  }

  Stream<List<DeliveryRequest>> streamOpenBoard() {
    return _client
        .from('delivery_requests')
        .stream(primaryKey: ['id'])
        .eq('status', 'pending')
        .order('created_at')
        .map((rows) => rows.map((r) => DeliveryRequest.fromMap(r)).toList());
  }

  Future<Map<String, Shop>> fetchShopsFor(
      List<DeliveryRequest> requests) async {
    final ids = requests.map((r) => r.shopId).toSet().toList();
    if (ids.isEmpty) return {};
    final rows = await _client.from('shops').select().inFilter('id', ids);
    return {for (final row in rows) row['id'] as String: Shop.fromMap(row)};
  }

  Future<List<DeliveryRequest>> fetchMyDeliveries() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    final rows = await _client
        .from('delivery_requests')
        .select(_boardSelect)
        .eq('driver_id', userId)
        .order('created_at', ascending: false);
    return rows.map((r) => DeliveryRequest.fromMap(r)).toList();
  }

  Future<DeliveryRequest> acceptRequest(String requestId) async {
    final row = await _client
        .rpc('accept_delivery_request', params: {'p_request_id': requestId});
    return DeliveryRequest.fromMap(Map<String, dynamic>.from(row as Map));
  }

  Future<DeliveryRequest> markDelivered(String requestId) async {
    final row = await _client
        .rpc('mark_delivery_delivered', params: {'p_request_id': requestId});
    return DeliveryRequest.fromMap(Map<String, dynamic>.from(row as Map));
  }

  Future<DeliveryRequest> releaseRequest(String requestId) async {
    final row = await _client
        .rpc('release_delivery_request', params: {'p_request_id': requestId});
    return DeliveryRequest.fromMap(Map<String, dynamic>.from(row as Map));
  }

  Future<DeliveryContact?> fetchContact(String requestId) async {
    final rows = await _client
        .rpc('get_delivery_contact', params: {'p_request_id': requestId});
    final list = rows as List;
    if (list.isEmpty) return null;
    return DeliveryContact.fromMap(
        Map<String, dynamic>.from(list.first as Map));
  }
}
