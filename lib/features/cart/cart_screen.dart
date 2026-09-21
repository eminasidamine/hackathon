import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/errors.dart';
import '../../core/money.dart';
import '../../core/settings_controller.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/cart_controller.dart';
import '../../services/catalog_service.dart';
import '../../services/location_service.dart';
import '../../services/order_service.dart';
import '../auth/login_screen.dart';
import '../widgets.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<void> _checkout(CartController cart) async {
    final auth = context.read<AuthService>();
    if (!auth.isLoggedIn) {
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      if (!mounted || !context.read<AuthService>().isLoggedIn) return;
    }
    if (!mounted) return;
    final t = context.read<SettingsController>().t;
    final initialPhone = context.read<AuthService>().profile?.phone ?? '';
    final placed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CheckoutSheet(cart: cart, initialPhone: initialPhone),
    );
    if (placed == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t('order_confirmed'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    final auth = context.watch<AuthService>();
    final cart = context.watch<CartController>();
    final shopCount = cart.linesByShop.length;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('tab_cart'),
                            style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.6,
                                color: AppTheme.ink)),
                        if (!cart.isEmpty)
                          Text(
                            '${cart.itemCount} ${t('items_count')} · $shopCount ${shopCount > 1 ? t('tab_shops').toLowerCase() : t('tab_shops').toLowerCase().replaceAll(RegExp(r's\$'), '')}',
                            style: const TextStyle(
                                fontSize: 12.5, color: AppTheme.muted),
                          ),
                      ],
                    ),
                  ),
                  if (!cart.isEmpty)
                    TextButton(
                      onPressed: () => cart.clear(),
                      child: Text(t('clear_all'),
                          style: const TextStyle(
                              color: AppTheme.muted, fontSize: 13)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: cart.isEmpty
                  ? EmptyState(
                      icon: Icons.shopping_bag_outlined,
                      title: t('empty_cart'),
                      subtitle: t('empty_cart_sub'))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      children: [
                        _Notice(text: t('one_order_per_store')),
                        ...cart.linesByShop.entries.map((entry) => _ShopGroup(
                              shopId: entry.key,
                              lines: entry.value,
                              subtotal: cart.totalForShop(entry.key),
                            )),
                        _SummaryCard(cart: cart, t: t),
                      ],
                    ),
            ),
            if (!cart.isEmpty)
              SafeArea(
                top: false,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppTheme.card,
                    border: Border(top: BorderSide(color: AppTheme.hair)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                                '${t('total')} · ${cart.itemCount} ${t('items_count')}',
                                style: const TextStyle(
                                    fontSize: 12, color: AppTheme.muted)),
                            Text(Money.format(cart.total),
                                style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                    color: AppTheme.ink)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => _checkout(cart),
                            child: Text(t('checkout')),
                          ),
                        ),
                        if (!auth.isLoggedIn) ...[
                          const SizedBox(height: 9),
                          Text(t('need_account_hint'),
                              style: const TextStyle(
                                  fontSize: 11.5, color: AppTheme.muted)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;

  const _Notice({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        border: Border.all(color: const Color(0xFFF3E2BE)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child:
                Icon(Icons.info_outline, size: 17, color: AppTheme.stockWarn),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12, height: 1.5, color: Color(0xFF6B5222))),
          ),
        ],
      ),
    );
  }
}

class _ShopGroup extends StatelessWidget {
  final String shopId;
  final List<CartLine> lines;
  final double subtotal;

  const _ShopGroup(
      {required this.shopId, required this.lines, required this.subtotal});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    final shopName = lines.first.product.shopName ?? '';
    final shopLogoUrl = lines.first.product.shopLogoUrl;
    final grad = shopGradient(shopName);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.hair))),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: (shopLogoUrl != null && shopLogoUrl.isNotEmpty)
                      ? AppImage(
                          url: shopLogoUrl,
                          width: 30,
                          height: 30,
                          thumbnail: true,
                          fit: BoxFit.cover)
                      : Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: grad,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                          ),
                        ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shopName,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              color: AppTheme.ink)),
                      Text(t('delivers_itself'),
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.muted)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    size: 16, color: AppTheme.muted),
              ],
            ),
          ),
          ...lines.map((line) => _CartItemRow(line: line)),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartLine line;

  const _CartItemRow({required this.line});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.hair))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppImage(
              url: line.product.coverImage,
              width: 60,
              height: 60,
              thumbnail: true,
              radius: BorderRadius.circular(15)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.ink)),
                if (line.selectedOption != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    '${line.product.optionName ?? ''}: ${line.selectedOption}'
                        .trim(),
                    style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(Money.format(line.product.price),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.ink)),
                    _Stepper(line: line),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final CartLine line;

  const _Stepper({required this.line});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.hair),
        borderRadius: BorderRadius.circular(11),
        color: AppTheme.panel,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            onTap: () => context
                .read<CartController>()
                .updateQuantity(line.cartKey, line.quantity - 1),
          ),
          SizedBox(
            width: 22,
            child: Text('${line.quantity}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ink)),
          ),
          _StepButton(
            icon: Icons.add,
            onTap: line.quantity >= line.product.stock
                ? null
                : () => context
                    .read<CartController>()
                    .updateQuantity(line.cartKey, line.quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(icon,
              size: 15, color: onTap == null ? AppTheme.muted : AppTheme.ink)),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final CartController cart;
  final String Function(String) t;

  const _SummaryCard({required this.cart, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('order_summary'),
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: AppTheme.ink)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${t('items_count')} (${cart.itemCount})',
                  style: const TextStyle(fontSize: 13, color: AppTheme.muted)),
              Text(t('delivery'),
                  style: const TextStyle(fontSize: 13, color: AppTheme.muted)),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(t('delivery_agreed'),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
          ),
        ],
      ),
    );
  }
}

class _CheckoutSheet extends StatefulWidget {
  final CartController cart;
  final String initialPhone;

  const _CheckoutSheet({required this.cart, required this.initialPhone});

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  final _orderService = OrderService();
  final _catalog = CatalogService();
  final _location = LocationService();

  late final TextEditingController _phone;
  final _address = TextEditingController();

  final Map<String, TextEditingController> _references = {};

  final Map<String, Shop> _shops = {};

  DeviceLocation? _position;
  bool _locating = false;

  String _deliveryMode = 'delivery';
  bool _loadingShops = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController(text: widget.initialPhone);
    for (final shopId in widget.cart.linesByShop.keys) {
      _references[shopId] = TextEditingController();
    }
    _loadShops();
  }

  Future<void> _loadShops() async {
    for (final shopId in widget.cart.linesByShop.keys) {
      final shop = await _catalog.fetchShop(shopId);
      if (shop != null) _shops[shopId] = shop;
    }
    if (mounted) setState(() => _loadingShops = false);
  }

  @override
  void dispose() {
    _phone.dispose();
    _address.dispose();
    for (final c in _references.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _useMyPosition() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    try {
      final position = await _location.currentPosition();
      if (!mounted) return;
      setState(() {
        _position = position;
        _locating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locating = false;
        _error = friendlyError(e, context.read<SettingsController>().t);
      });
    }
  }

  void _usePlace(PlaceResult place) {
    setState(() {
      _position = DeviceLocation(latitude: place.lat, longitude: place.lng);
      _error = null;
      if (_address.text.trim().isEmpty) _address.text = place.label;
    });
  }

  Future<void> _confirm() async {
    final t = context.read<SettingsController>().t;
    final phone = _phone.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = t('checkout_phone_required'));
      return;
    }
    if (_deliveryMode == 'delivery' &&
        _position == null &&
        _address.text.trim().isEmpty) {
      setState(() => _error = t('checkout_share_location_or_address'));
      return;
    }
    final missing = widget.cart.linesByShop.keys
        .any((id) => _references[id]!.text.trim().isEmpty);
    if (missing) {
      setState(() => _error = t('checkout_enter_payment_reference'));
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await _orderService.checkout(
        widget.cart,
        phone: phone,
        paymentReferencesByShop: {
          for (final entry in _references.entries)
            entry.key: entry.value.text.trim(),
        },
        deliveryLat: _position?.latitude,
        deliveryLng: _position?.longitude,
        deliveryAddress: _address.text.trim(),
        deliveryMode: _deliveryMode,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final t = context.read<SettingsController>().t;
      setState(() {
        _submitting = false;

        final raw = e.toString();
        _error = raw.contains('orders_payment_reference_unique') ||
                raw.contains('duplicate key')
            ? t('checkout_reference_already_used')
            : friendlyError(e, t);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shops = widget.cart.linesByShop;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: AppTheme.line,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Confirm order',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink)),
            const SizedBox(height: 6),
            const Text(
              'Pay each shop using its merchant code from your banking app, '
              'then enter below the code your bank sends you back.',
              style: TextStyle(fontSize: 13, color: AppTheme.ink2, height: 1.4),
            ),
            const SizedBox(height: 20),
            const _SectionLabel('Contact'),
            const SizedBox(height: 8),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
            ),
            const SizedBox(height: 20),
            const _SectionLabel('How do you want to receive your order?'),
            const SizedBox(height: 8),
            _DeliveryModeToggle(
              value: _deliveryMode,
              onChanged: (value) => setState(() {
                _deliveryMode = value;
                _error = null;
              }),
            ),
            if (_deliveryMode == 'delivery') ...[
              const SizedBox(height: 16),
              _LocationField(
                position: _position,
                busy: _locating,
                addressController: _address,
                onLocate: _useMyPosition,
                onPlaceSelected: _usePlace,
              ),
              const SizedBox(height: 8),
              const Text(
                "A rider will be offered this delivery once your order is placed, or the "
                "shop may arrange it directly and contact you on WhatsApp.",
                style: TextStyle(
                    fontSize: 12, color: AppTheme.muted, height: 1.35),
              ),
            ],
            const SizedBox(height: 22),
            if (shops.isNotEmpty) const _SectionLabel('Payment'),
            if (shops.isNotEmpty) const SizedBox(height: 8),
            if (_loadingShops)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              ...shops.entries.map((entry) {
                final shopId = entry.key;
                final shop = _shops[shopId];
                final shopName =
                    shop?.name ?? entry.value.first.product.shopName ?? '';
                return _ShopPaymentBlock(
                  shopName: shopName,
                  merchantCode: shop?.merchantCode,
                  merchantProvider: shop?.merchantProvider,
                  amount: Money.format(widget.cart.totalForShop(shopId)),
                  controller: _references[shopId]!,
                );
              }),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Text(_error!,
                  style: const TextStyle(fontSize: 12.5, color: AppTheme.red)),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 6),
            FilledButton(
              onPressed: _submitting ? null : _confirm,
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Confirm order'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: AppTheme.muted),
    );
  }
}

class _DeliveryModeToggle extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _DeliveryModeToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: AppTheme.panel, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Expanded(
            child: _DeliveryModeOption(
              label: 'Delivery',
              icon: Icons.delivery_dining_outlined,
              selected: value == 'delivery',
              onTap: () => onChanged('delivery'),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _DeliveryModeOption(
              label: "I'll pick it up",
              icon: Icons.storefront_outlined,
              selected: value == 'pickup',
              onTap: () => onChanged('pickup'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryModeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _DeliveryModeOption(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppTheme.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16, color: selected ? Colors.white : AppTheme.ink2),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppTheme.ink2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  final DeviceLocation? position;
  final bool busy;
  final TextEditingController addressController;
  final VoidCallback onLocate;
  final ValueChanged<PlaceResult> onPlaceSelected;

  const _LocationField({
    required this.position,
    required this.busy,
    required this.addressController,
    required this.onLocate,
    required this.onPlaceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final located = position != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlaceSearchField(onSelected: onPlaceSelected),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: busy ? null : onLocate,
          icon: busy
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(located ? Icons.check_circle_outline : Icons.my_location,
                  size: 18),
          label:
              Text(located ? 'Location saved' : 'Or use my current location'),
        ),
        if (located) ...[
          const SizedBox(height: 10),
          MiniMap(
              latitude: position!.latitude,
              longitude: position!.longitude,
              height: 130),
        ],
        const SizedBox(height: 10),
        TextField(
          controller: addressController,
          decoration: const InputDecoration(
            labelText: 'Address / landmark (optional)',
            hintText: 'e.g. Tevragh Zeina, near the pharmacy',
          ),
        ),
      ],
    );
  }
}

class _ShopPaymentBlock extends StatelessWidget {
  final String shopName;
  final String? merchantCode;
  final String? merchantProvider;
  final String amount;
  final TextEditingController controller;

  const _ShopPaymentBlock({
    required this.shopName,
    required this.merchantCode,
    required this.merchantProvider,
    required this.amount,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final hasCode = merchantCode != null && merchantCode!.trim().isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(shopName,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ink)),
              ),
              Text(amount,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink)),
            ],
          ),
          const SizedBox(height: 10),
          if (hasCode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                  color: AppTheme.panel,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.storefront_outlined,
                      size: 17, color: AppTheme.ink2),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Merchant code${merchantProvider != null && merchantProvider!.isNotEmpty ? ' · $merchantProvider' : ''}',
                          style: const TextStyle(
                              fontSize: 11.5, color: AppTheme.muted),
                        ),
                        const SizedBox(height: 2),
                        SelectableText(
                          merchantCode!,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppTheme.ink),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy',
                    icon: const Icon(Icons.copy_outlined,
                        size: 18, color: AppTheme.ink2),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: merchantCode!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Merchant code copied.')),
                      );
                    },
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                  color: AppTheme.panel,
                  borderRadius: BorderRadius.circular(12)),
              child: const Text(
                "This shop hasn't registered its merchant code yet. "
                "Contact them on WhatsApp to get their code before paying.",
                style: TextStyle(
                    fontSize: 12.5, color: AppTheme.ink2, height: 1.35),
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Payment reference received',
              hintText: 'The reference your bank gave you',
            ),
          ),
        ],
      ),
    );
  }
}
