import 'package:flutter/foundation.dart';
import '../models/models.dart';

class CartController extends ChangeNotifier {
  final Map<String, CartLine> _lines = {};

  List<CartLine> get lines => _lines.values.toList();

  int get itemCount => _lines.values.fold(0, (sum, l) => sum + l.quantity);

  double get total => _lines.values.fold(0, (sum, l) => sum + l.subtotal);

  bool get isEmpty => _lines.isEmpty;

  Map<String, List<CartLine>> get linesByShop {
    final map = <String, List<CartLine>>{};
    for (final line in _lines.values) {
      map.putIfAbsent(line.product.shopId, () => []).add(line);
    }
    return map;
  }

  double totalForShop(String shopId) =>
      linesByShop[shopId]?.fold<double>(0, (sum, l) => sum + l.subtotal) ?? 0;

  bool add(Product product, {int quantity = 1, String? selectedOption}) {
    final key =
        selectedOption == null ? product.id : '${product.id}::$selectedOption';
    final existing = _lines[key];
    final currentQty = existing?.quantity ?? 0;
    final room = product.stock - currentQty;
    final addable = quantity < room ? quantity : (room > 0 ? room : 0);
    final wasCapped = addable < quantity;
    if (addable <= 0) return true;
    if (existing != null) {
      existing.quantity += addable;
    } else {
      _lines[key] = CartLine(
          product: product, quantity: addable, selectedOption: selectedOption);
    }
    notifyListeners();
    return wasCapped;
  }

  void updateQuantity(String cartKey, int quantity) {
    if (quantity <= 0) {
      _lines.remove(cartKey);
    } else {
      final line = _lines[cartKey];
      if (line != null)
        line.quantity =
            quantity > line.product.stock ? line.product.stock : quantity;
    }
    notifyListeners();
  }

  void remove(String cartKey) {
    _lines.remove(cartKey);
    notifyListeners();
  }

  void clearShop(String shopId) {
    _lines.removeWhere((_, line) => line.product.shopId == shopId);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}
