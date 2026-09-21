import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'delivery_service.dart';
import 'vendor_service.dart';

class RoleController extends ChangeNotifier {
  final VendorService _vendor = VendorService();
  final DeliveryService _delivery = DeliveryService();

  Shop? _shop;
  DriverProfile? _driverProfile;
  bool _loaded = false;

  Shop? get shop => _shop;
  DriverProfile? get driverProfile => _driverProfile;
  bool get loaded => _loaded;

  bool get isVendor => _shop != null;

  bool get isDriver => _driverProfile != null;

  Future<void> refresh() async {
    try {
      _shop = await _vendor.fetchMyShop();
    } catch (_) {
      _shop = null;
    }
    try {
      _driverProfile = await _delivery.fetchMyDriverProfile();
    } catch (_) {
      _driverProfile = null;
    }
    _loaded = true;
    notifyListeners();
  }

  void clear() {
    _shop = null;
    _driverProfile = null;
    _loaded = false;
    notifyListeners();
  }
}
