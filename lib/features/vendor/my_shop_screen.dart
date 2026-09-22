import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/errors.dart';
import '../../core/money.dart';
import '../../core/settings_controller.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/catalog_service.dart';
import '../../services/location_service.dart';
import '../../services/storage_service.dart';
import '../../services/vendor_service.dart';
import '../widgets.dart';
import 'vendor_dashboard_screen.dart';

class MyShopScreen extends StatefulWidget {
  final String? initialCategoryId;

  final List<String> initialCategoryIds;

  const MyShopScreen(
      {super.key, this.initialCategoryId, this.initialCategoryIds = const []});

  @override
  State<MyShopScreen> createState() => _MyShopScreenState();
}

class _MyShopScreenState extends State<MyShopScreen> {
  final _vendor = VendorService();
  late Future<Shop?> _future;

  @override
  void initState() {
    super.initState();
    _future = _vendor.fetchMyShop();
  }

  void _refresh() => setState(() => _future = _vendor.fetchMyShop());

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        surfaceTintColor: AppTheme.bg,
        iconTheme: const IconThemeData(color: AppTheme.ink),
        title: Text(t('my_shop_title'),
            style: const TextStyle(color: AppTheme.ink)),
      ),
      body: SafeArea(
        child: FutureBuilder<Shop?>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final shop = snapshot.data;
            if (shop == null) {
              return _CreateShopView(
                vendor: _vendor,
                onCreated: _refresh,
                categoryIds: widget.initialCategoryIds,
              );
            }
            return _MyShopDashboard(
              vendor: _vendor,
              shop: shop,
              onShopUpdated: _refresh,
              initialCategoryId: widget.initialCategoryId,
            );
          },
        ),
      ),
    );
  }
}

class _CreateShopView extends StatefulWidget {
  final VendorService vendor;
  final VoidCallback onCreated;
  final List<String> categoryIds;

  const _CreateShopView(
      {required this.vendor,
      required this.onCreated,
      this.categoryIds = const []});

  @override
  State<_CreateShopView> createState() => _CreateShopViewState();
}

class _CreateShopViewState extends State<_CreateShopView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _city = TextEditingController();
  final _whatsapp = TextEditingController();

  final _merchantCode = TextEditingController();
  String _merchantProvider = _kMerchantProviders.first;
  double? _pickupLat;
  double? _pickupLng;
  final _storage = StorageService();
  Uint8List? _logoBytes;
  String? _logoName;
  bool _saving = false;

  bool _logoMissingError = false;

  Future<void> _pickLogo() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _logoBytes = bytes;
      _logoName = picked.name;
      _logoMissingError = false;
    });
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState!.validate();
    setState(() => _logoMissingError = _logoBytes == null);
    if (!formOk || _logoBytes == null) return;
    setState(() => _saving = true);
    try {
      String? logoUrl;
      if (_logoBytes != null) {
        final ext = (_logoName ?? '').contains('.')
            ? _logoName!.split('.').last
            : 'jpg';
        final path =
            _storage.ownedPath('${DateTime.now().millisecondsSinceEpoch}.$ext');
        logoUrl = await _storage.uploadPublic(
            bucket: 'shop-images', path: path, bytes: _logoBytes!);
      }
      final shop = await widget.vendor.createMyShop(
        name: _name.text.trim(),
        description:
            _description.text.trim().isEmpty ? null : _description.text.trim(),
        logoUrl: logoUrl,
        city: _city.text.trim().isEmpty ? null : _city.text.trim(),
        whatsappPhone:
            _whatsapp.text.trim().isEmpty ? null : _whatsapp.text.trim(),
        merchantCode: _merchantCode.text.trim(),
        merchantProvider: _merchantProvider,
        lat: _pickupLat,
        lng: _pickupLng,
      );

      if (widget.categoryIds.isNotEmpty) {
        await widget.vendor.setMyShopCategories(
            shopId: shop.id, categoryIds: widget.categoryIds);
      }
      widget.onCreated();
    } catch (e) {
      setState(() => _saving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(friendlyError(e, context.read<SettingsController>().t))));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _city.dispose();
    _whatsapp.dispose();
    _merchantCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t('create_shop_title'),
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: AppTheme.ink),
          ),
          const SizedBox(height: 8),
          Text(
            t('create_shop_intro'),
            style: const TextStyle(
                fontSize: 13.5, color: AppTheme.ink2, height: 1.4),
          ),
          const SizedBox(height: 22),
          Center(
            child: GestureDetector(
              onTap: _pickLogo,
              child: Stack(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.panel,
                      border: _logoMissingError
                          ? Border.all(color: AppTheme.red, width: 1.5)
                          : null,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: _logoBytes != null
                        ? Image.memory(_logoBytes!, fit: BoxFit.cover)
                        : const Icon(Icons.storefront_outlined,
                            color: AppTheme.muted, size: 32),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: AppTheme.ink),
                      alignment: Alignment.center,
                      child:
                          const Icon(Icons.add, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_logoMissingError) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(t('photo_required_tap'),
                  style: const TextStyle(fontSize: 12, color: AppTheme.red)),
            ),
          ],
          const SizedBox(height: 26),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: t('shop_name')),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? t('required_field')
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _description,
                    maxLines: 3,
                    decoration:
                        InputDecoration(labelText: t('description_optional'))),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _city,
                    decoration: InputDecoration(labelText: t('city_optional'))),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _whatsapp,
                  keyboardType: TextInputType.phone,
                  decoration:
                      InputDecoration(labelText: t('whatsapp_number_label')),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? t('whatsapp_required_hint')
                      : null,
                ),
                const SizedBox(height: 12),
                _MerchantCodeFields(
                  codeController: _merchantCode,
                  provider: _merchantProvider,
                  onProviderChanged: (v) =>
                      setState(() => _merchantProvider = v),
                ),
                const SizedBox(height: 16),
                _PickupLocationField(
                  initialLat: _pickupLat,
                  initialLng: _pickupLng,
                  onLocated: (pos) => setState(() {
                    _pickupLat = pos.$1;
                    _pickupLng = pos.$2;
                  }),
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(t('create_my_shop_caps')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditShopDialog extends StatefulWidget {
  final VendorService vendor;
  final Shop shop;

  const _EditShopDialog({required this.vendor, required this.shop});

  @override
  State<_EditShopDialog> createState() => _EditShopDialogState();
}

class _EditShopDialogState extends State<_EditShopDialog> {
  final _formKey = GlobalKey<FormState>();
  final _storage = StorageService();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _city;
  late final TextEditingController _whatsapp;
  late final TextEditingController _merchantCode;
  late String _merchantProvider;
  double? _pickupLat;
  double? _pickupLng;
  Uint8List? _newLogoBytes;
  String? _newLogoName;
  bool _saving = false;

  bool _logoMissingError = false;

  bool get _hasLogo =>
      _newLogoBytes != null ||
      (widget.shop.logoUrl != null && widget.shop.logoUrl!.isNotEmpty);

  @override
  void initState() {
    super.initState();
    final s = widget.shop;
    _name = TextEditingController(text: s.name);
    _description = TextEditingController(text: s.description ?? '');
    _city = TextEditingController(text: s.city ?? '');
    _whatsapp = TextEditingController(text: s.whatsappPhone ?? '');
    _merchantCode = TextEditingController(text: s.merchantCode ?? '');
    _merchantProvider = _kMerchantProviders.contains(s.merchantProvider)
        ? s.merchantProvider!
        : _kMerchantProviders.first;
    _pickupLat = s.lat;
    _pickupLng = s.lng;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _city.dispose();
    _whatsapp.dispose();
    _merchantCode.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _newLogoBytes = bytes;
      _newLogoName = picked.name;
      _logoMissingError = false;
    });
  }

  Future<void> _save() async {
    final formOk = _formKey.currentState!.validate();
    setState(() => _logoMissingError = !_hasLogo);
    if (!formOk || !_hasLogo) return;
    setState(() => _saving = true);
    try {
      String? logoUrl;
      if (_newLogoBytes != null) {
        final ext = (_newLogoName ?? '').contains('.')
            ? _newLogoName!.split('.').last
            : 'jpg';
        final path =
            _storage.ownedPath('${DateTime.now().millisecondsSinceEpoch}.$ext');
        logoUrl = await _storage.uploadPublic(
            bucket: 'shop-images', path: path, bytes: _newLogoBytes!);
      }
      await widget.vendor.updateMyShop(
        shopId: widget.shop.id,
        name: _name.text.trim(),
        description: _description.text.trim(),
        logoUrl: logoUrl,
        city: _city.text.trim(),
        whatsappPhone: _whatsapp.text.trim(),
        merchantCode: _merchantCode.text.trim(),
        merchantProvider: _merchantProvider,
        lat: _pickupLat,
        lng: _pickupLng,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _saving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(friendlyError(e, context.read<SettingsController>().t))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    return AlertDialog(
      title: Text(t('shop_edit')),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickLogo,
                    child: Stack(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.panel,
                            border: _logoMissingError
                                ? Border.all(color: AppTheme.red, width: 1.5)
                                : null,
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: _newLogoBytes != null
                              ? Image.memory(_newLogoBytes!, fit: BoxFit.cover)
                              : (widget.shop.logoUrl != null &&
                                      widget.shop.logoUrl!.isNotEmpty)
                                  ? Image.network(widget.shop.logoUrl!,
                                      fit: BoxFit.cover)
                                  : const Icon(Icons.storefront_outlined,
                                      color: AppTheme.muted, size: 28),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: AppTheme.ink),
                            alignment: Alignment.center,
                            child: const Icon(Icons.edit,
                                size: 13, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_logoMissingError) ...[
                  const SizedBox(height: 6),
                  Center(
                    child: Text(t('photo_required_short'),
                        style:
                            const TextStyle(fontSize: 12, color: AppTheme.red)),
                  ),
                ],
                const SizedBox(height: 18),
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: t('shop_name')),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? t('required_field')
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _description,
                    maxLines: 3,
                    decoration:
                        InputDecoration(labelText: t('description_optional'))),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _city,
                    decoration: InputDecoration(labelText: t('city_optional'))),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _whatsapp,
                  keyboardType: TextInputType.phone,
                  decoration:
                      InputDecoration(labelText: t('whatsapp_number_label')),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? t('required_field')
                      : null,
                ),
                const SizedBox(height: 12),
                _MerchantCodeFields(
                  codeController: _merchantCode,
                  provider: _merchantProvider,
                  onProviderChanged: (v) =>
                      setState(() => _merchantProvider = v),
                ),
                const SizedBox(height: 16),
                _PickupLocationField(
                  initialLat: _pickupLat,
                  initialLng: _pickupLng,
                  onLocated: (pos) => setState(() {
                    _pickupLat = pos.$1;
                    _pickupLng = pos.$2;
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
            child: Text(t('cancel'))),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(t('save')),
        ),
      ],
    );
  }
}

class _MyShopDashboard extends StatefulWidget {
  final VendorService vendor;
  final Shop shop;
  final VoidCallback onShopUpdated;
  final String? initialCategoryId;

  const _MyShopDashboard(
      {required this.vendor,
      required this.shop,
      required this.onShopUpdated,
      this.initialCategoryId});

  @override
  State<_MyShopDashboard> createState() => _MyShopDashboardState();
}

class _MyShopDashboardState extends State<_MyShopDashboard> {
  final _catalog = CatalogService();
  late Future<List<Product>> _productsFuture;
  late Future<List<OrderModel>> _ordersFuture;
  late Future<int> _followerCountFuture;

  int _tab = 0;

  String _orderFilter = 'all';
  final _productSearch = TextEditingController();
  String _productQuery = '';

  @override
  void initState() {
    super.initState();
    _productsFuture = widget.vendor.fetchMyProducts(widget.shop.id);
    _ordersFuture = widget.vendor.fetchMyShopOrders(widget.shop.id);
    _followerCountFuture = _catalog.fetchShopFollowerCount(widget.shop.id);

    if (widget.initialCategoryId != null) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _openAddProduct(initialCategoryId: widget.initialCategoryId));
    }
  }

  @override
  void dispose() {
    _productSearch.dispose();
    super.dispose();
  }

  void _refreshProducts() => setState(
      () => _productsFuture = widget.vendor.fetchMyProducts(widget.shop.id));
  void _refreshOrders() => setState(
      () => _ordersFuture = widget.vendor.fetchMyShopOrders(widget.shop.id));

  Future<void> _editShop() async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => _EditShopDialog(vendor: widget.vendor, shop: widget.shop),
    );
    if (updated == true) widget.onShopUpdated();
  }

  Future<void> _deleteShop() async {
    final t = context.read<SettingsController>().t;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t('shop_delete_confirm_title')),
        content: Text(t('shop_delete_confirm_message')),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t('cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t('shop_delete')),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await widget.vendor.deleteMyShop(widget.shop.id);
      widget.onShopUpdated();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(friendlyError(e, context.read<SettingsController>().t))));
    }
  }

  Future<void> _openOrderDetail(OrderModel order) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _MyOrderDetailDialog(vendor: widget.vendor, order: order),
    );
    if (changed == true) _refreshOrders();
  }

  Future<void> _openAddProduct({String? initialCategoryId}) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (_) => _MyProductScreen(
              vendor: widget.vendor,
              shopId: widget.shop.id,
              initialCategoryId: initialCategoryId)),
    );
    if (created == true) _refreshProducts();
  }

  Future<void> _openEditProduct(Product p) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (_) => _MyProductScreen(
              vendor: widget.vendor, shopId: widget.shop.id, existing: p)),
    );
    if (updated == true) _refreshProducts();
  }

  Future<void> _toggleVisible(Product p) async {
    await widget.vendor.setMyProductVisible(p.id, !p.isVisible);
    _refreshProducts();
  }

  Future<void> _delete(Product p) async {
    final t = context.read<SettingsController>().t;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
            t('delete_product_confirm_title').replaceAll('{name}', p.name)),
        content: Text(t('action_cannot_be_undone')),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t('cancel'))),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(t('delete_action'))),
        ],
      ),
    );
    if (ok != true) return;
    await widget.vendor.deleteMyProduct(p.id);
    _refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    final shop = widget.shop;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShopAvatar(name: shop.name, logoUrl: shop.logoUrl, size: 64),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.name,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink)),
                  const SizedBox(height: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: shop.isVisible
                          ? const Color(0xFFE3F3E9)
                          : const Color(0xFFF3EEE6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      shop.isVisible
                          ? t('shop_active_badge')
                          : t('shop_pending_badge'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: shop.isVisible
                            ? const Color(0xFF2E9C5B)
                            : const Color(0xFF8A6D2F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<int>(
                    future: _followerCountFuture,
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return Text(
                        '$count ${count > 1 ? t('shop_followers') : t('shop_follower')}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.muted),
                      );
                    },
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppTheme.ink2),
              onSelected: (value) {
                if (value == 'edit') _editShop();
                if (value == 'delete') _deleteShop();
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'edit', child: Text(t('shop_edit'))),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(t('shop_delete'),
                      style: const TextStyle(color: AppTheme.red)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        _DashboardCounters(
          productsFuture: _productsFuture,
          ordersFuture: _ordersFuture,
          followersFuture: _followerCountFuture,
        ),
        const SizedBox(height: 16),
        _AnalyticsEntryCard(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VendorDashboardScreen(
                shopId: widget.shop.id,
                shopName: widget.shop.name,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Divider(color: AppTheme.line, height: 1),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _DashboardTabButton(
                    label: t('my_products_tab'),
                    active: _tab == 0,
                    onTap: () => setState(() => _tab = 0))),
            const SizedBox(width: 8),
            Expanded(
                child: _DashboardTabButton(
                    label: t('orders_tab_label'),
                    active: _tab == 1,
                    onTap: () => setState(() => _tab = 1))),
          ],
        ),
        const SizedBox(height: 20),
        if (_tab == 1) ...[
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final entry in [
                  ['all', t('all_chip')],
                  ['pending', t('order_status_pending')],
                  ['confirmed', t('order_status_confirmed')],
                  ['preparing', t('order_status_preparing')],
                  ['delivering', t('order_status_delivering')],
                  ['delivered', t('order_status_delivered')],
                  ['cancelled', t('order_status_cancelled')],
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: entry[1],
                      active: _orderFilter == entry[0],
                      onTap: () => setState(() => _orderFilter = entry[0]),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<OrderModel>>(
            future: _ordersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()));
              }
              final all = snapshot.data ?? [];
              final orders = _orderFilter == 'all'
                  ? all
                  : all.where((o) => o.status == _orderFilter).toList();
              if (orders.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    _orderFilter == 'all'
                        ? t('no_orders_yet')
                        : t('no_orders_in_state'),
                    style: const TextStyle(color: AppTheme.muted, fontSize: 13),
                  ),
                );
              }
              return Column(
                children: orders
                    .map((o) =>
                        _MyOrderRow(order: o, onTap: () => _openOrderDetail(o)))
                    .toList(),
              );
            },
          ),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t('my_products_section_title'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink)),
              TextButton.icon(
                onPressed: _openAddProduct,
                icon: const Icon(Icons.add, size: 18, color: AppTheme.ink),
                label: Text(t('add_action'),
                    style: const TextStyle(
                        color: AppTheme.ink, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _productSearch,
            onChanged: (v) =>
                setState(() => _productQuery = v.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: t('search_my_products_hint'),
              prefixIcon:
                  const Icon(Icons.search, size: 19, color: AppTheme.muted),
              isDense: true,
              suffixIcon: _productQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close,
                          size: 18, color: AppTheme.muted),
                      onPressed: () => setState(() {
                        _productSearch.clear();
                        _productQuery = '';
                      }),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Product>>(
            future: _productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()));
              }
              final all = snapshot.data ?? [];
              final products = _productQuery.isEmpty
                  ? all
                  : all
                      .where(
                          (p) => p.name.toLowerCase().contains(_productQuery))
                      .toList();
              if (products.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    _productQuery.isEmpty
                        ? t('no_products_yet')
                        : t('no_products_match'),
                    style: const TextStyle(color: AppTheme.muted, fontSize: 13),
                  ),
                );
              }
              return Column(
                children: products
                    .map((p) => _MyProductRow(
                          product: p,
                          onToggleVisible: () => _toggleVisible(p),
                          onEdit: () => _openEditProduct(p),
                          onDelete: () => _delete(p),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _DashboardTabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _DashboardTabButton(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: active ? AppTheme.ink : Colors.transparent,
                    width: 2))),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 13.5,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? AppTheme.ink : AppTheme.muted),
        ),
      ),
    );
  }
}

class _MyProductRow extends StatelessWidget {
  final Product product;
  final VoidCallback onToggleVisible;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MyProductRow(
      {required this.product,
      required this.onToggleVisible,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final p = product;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: AppTheme.panel, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
                width: 48,
                height: 48,
                child: AppImage(
                    url: p.coverImage, fit: BoxFit.cover, thumbnail: true)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ink)),
                const SizedBox(height: 2),
                Text(Money.format(p.price),
                    style:
                        const TextStyle(fontSize: 12.5, color: AppTheme.ink2)),
              ],
            ),
          ),
          Switch(
              value: p.isVisible,
              activeColor: AppTheme.ink,
              onChanged: (_) => onToggleVisible()),
          IconButton(
              icon: const Icon(Icons.edit_outlined,
                  size: 18, color: AppTheme.ink2),
              onPressed: onEdit),
          IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: AppTheme.red),
              onPressed: onDelete),
        ],
      ),
    );
  }
}

class _MyProductScreen extends StatefulWidget {
  final VendorService vendor;
  final String shopId;
  final Product? existing;
  final String? initialCategoryId;

  const _MyProductScreen(
      {required this.vendor,
      required this.shopId,
      this.existing,
      this.initialCategoryId});

  @override
  State<_MyProductScreen> createState() => _MyProductScreenState();
}

class _MyProductScreenState extends State<_MyProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catalog = CatalogService();
  final _storage = StorageService();
  late final TextEditingController _brand;
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _compareAtPrice;
  late final TextEditingController _stock;
  late final TextEditingController _optionName;
  late final TextEditingController _optionValues;

  bool _noVariants = false;
  String _optionType = 'text';

  final List<String> _selectedHex = [];
  final Set<String> _soldOutHex = {};
  String? _optionsError;
  String? _categoryId;
  List<Category> _categories = [];
  bool _saving = false;
  bool _loadingImages = false;

  List<ProductImage> _existingImages = [];

  final List<Uint8List> _queuedBytes = [];
  final List<String> _queuedNames = [];

  final List<double> _queuedFocalX = [];
  final List<double> _queuedFocalY = [];
  final List<double> _queuedZoom = [];

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _brand = TextEditingController(text: p?.brand ?? '');
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(
        text: p != null ? p.price.toStringAsFixed(0) : '');
    _compareAtPrice = TextEditingController(
        text: p?.compareAtPrice != null
            ? p!.compareAtPrice!.toStringAsFixed(0)
            : '');
    _stock = TextEditingController(text: p != null ? '${p.stock}' : '0');
    _optionName = TextEditingController(text: p?.optionName ?? '');
    _optionValues =
        TextEditingController(text: (p?.optionValues ?? const []).join(', '));
    _optionType = p?.optionType == 'color' ? 'color' : 'text';
    if (p != null && p.optionType == 'color') {
      for (var i = 0; i < p.optionColors.length; i++) {
        final hex = p.optionColors[i];
        _selectedHex.add(hex);
        if (i < p.optionSoldOut.length && p.optionSoldOut[i])
          _soldOutHex.add(hex);
      }
    }

    _noVariants =
        p != null && (p.optionName == null || p.optionName!.trim().isEmpty);
    _categoryId = p?.categoryId ?? widget.initialCategoryId;
    _catalog.fetchCategories().then((cats) {
      if (mounted) setState(() => _categories = cats);
    });
    if (_isEditing) _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() => _loadingImages = true);
    try {
      final images =
          await widget.vendor.fetchMyProductImages(widget.existing!.id);
      if (!mounted) return;
      setState(() {
        _existingImages = images;
        _loadingImages = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingImages = false);
    }
  }

  @override
  void dispose() {
    _brand.dispose();
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _compareAtPrice.dispose();
    _stock.dispose();
    _optionName.dispose();
    _optionValues.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();

    if (!mounted) return;
    final result = await Navigator.of(context).push<(double, double, double)>(
      MaterialPageRoute(builder: (_) => PhotoPositionScreen(bytes: bytes)),
    );
    if (result == null) return;
    if (!_isEditing) {
      setState(() {
        _queuedBytes.add(bytes);
        _queuedNames.add(picked.name);
        _queuedFocalX.add(result.$1);
        _queuedFocalY.add(result.$2);
        _queuedZoom.add(result.$3);
      });
      return;
    }

    setState(() => _loadingImages = true);
    try {
      final ext =
          picked.name.contains('.') ? picked.name.split('.').last : 'jpg';
      final path = _storage.ownedPath(
          '${widget.existing!.id}/${DateTime.now().millisecondsSinceEpoch}.$ext');
      final url = await _storage.uploadPublic(
          bucket: 'product-images', path: path, bytes: bytes);
      await widget.vendor.addMyProductImage(
        productId: widget.existing!.id,
        url: url,
        sortOrder: _existingImages.length,
        focalX: result.$1,
        focalY: result.$2,
        zoom: result.$3,
      );
      await _loadImages();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingImages = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(friendlyError(e, context.read<SettingsController>().t))));
    }
  }

  void _removeQueuedPhoto(int index) {
    setState(() {
      _queuedBytes.removeAt(index);
      _queuedNames.removeAt(index);
      _queuedFocalX.removeAt(index);
      _queuedFocalY.removeAt(index);
      _queuedZoom.removeAt(index);
    });
  }

  void _moveQueuedPhoto(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= _queuedBytes.length) return;
    setState(() {
      _queuedBytes.insert(target, _queuedBytes.removeAt(index));
      _queuedNames.insert(target, _queuedNames.removeAt(index));
      _queuedFocalX.insert(target, _queuedFocalX.removeAt(index));
      _queuedFocalY.insert(target, _queuedFocalY.removeAt(index));
      _queuedZoom.insert(target, _queuedZoom.removeAt(index));
    });
  }

  Future<void> _repositionQueuedPhoto(int index) async {
    final result = await Navigator.of(context).push<(double, double, double)>(
      MaterialPageRoute(
        builder: (_) => PhotoPositionScreen(
          bytes: _queuedBytes[index],
          initialFocalX: _queuedFocalX[index],
          initialFocalY: _queuedFocalY[index],
          initialZoom: _queuedZoom[index],
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _queuedFocalX[index] = result.$1;
      _queuedFocalY[index] = result.$2;
      _queuedZoom[index] = result.$3;
    });
  }

  Future<void> _repositionExistingPhoto(ProductImage image) async {
    final result = await Navigator.of(context).push<(double, double, double)>(
      MaterialPageRoute(
        builder: (_) => PhotoPositionScreen(
          url: image.url,
          initialFocalX: image.focalX,
          initialFocalY: image.focalY,
          initialZoom: image.zoom,
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() => _loadingImages = true);
    try {
      await widget.vendor.updateMyProductImageFocal(
          imageId: image.id,
          focalX: result.$1,
          focalY: result.$2,
          zoom: result.$3);
      await _loadImages();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingImages = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(friendlyError(e, context.read<SettingsController>().t))));
    }
  }

  Future<void> _deleteExistingPhoto(ProductImage image) async {
    final t = context.read<SettingsController>().t;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t('delete_photo_confirm_title')),
        content: Text(t('delete_photo_confirm_message')),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t('cancel'))),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(t('delete_action'))),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _loadingImages = true);
    try {
      await widget.vendor.deleteMyProductImage(image.id);
      final remaining = _existingImages
          .where((i) => i.id != image.id)
          .map((i) => i.id)
          .toList();
      await widget.vendor.reorderMyProductImages(remaining);
      await _loadImages();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingImages = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(friendlyError(e, context.read<SettingsController>().t))));
    }
  }

  Future<void> _moveExistingPhoto(int index, int delta) async {
    final target = index + delta;
    if (target < 0 || target >= _existingImages.length) return;
    final ids = _existingImages.map((i) => i.id).toList();
    ids.insert(target, ids.removeAt(index));
    setState(() => _loadingImages = true);
    try {
      await widget.vendor.reorderMyProductImages(ids);
      await _loadImages();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingImages = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(friendlyError(e, context.read<SettingsController>().t))));
    }
  }

  String? _validateVariants(String Function(String) t) {
    if (_noVariants) return null;
    if (_optionName.text.trim().isEmpty) {
      return t('option_name_required');
    }
    if (_optionType == 'color') {
      if (_selectedHex.isEmpty) return t('select_one_shade');
    } else {
      final values = _optionValues.text
          .split(',')
          .map((v) => v.trim())
          .where((v) => v.isNotEmpty);
      if (values.isEmpty) return t('add_one_choice');
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final t = context.read<SettingsController>().t;

    final variantsError = _validateVariants(t);
    setState(() => _optionsError = variantsError);
    if (variantsError != null) return;
    setState(() => _saving = true);
    try {
      final price = double.parse(_price.text.trim().replaceAll(',', '.'));
      final compareAtText = _compareAtPrice.text.trim();
      final compareAtPrice = compareAtText.isEmpty
          ? null
          : double.tryParse(compareAtText.replaceAll(',', '.'));
      final stock = int.tryParse(_stock.text.trim()) ?? 0;

      final optionNameText = _optionName.text.trim();

      final optionValuesList = _optionType == 'color'
          ? [for (final hex in _selectedHex) swatchName(hex)]
          : _optionValues.text
              .split(',')
              .map((v) => v.trim())
              .where((v) => v.isNotEmpty)
              .toList();
      final optionColorsList =
          _optionType == 'color' ? List<String>.from(_selectedHex) : <String>[];
      final optionSoldOutList = _optionType == 'color'
          ? [for (final hex in _selectedHex) _soldOutHex.contains(hex)]
          : <bool>[];
      final hasOptions = !_noVariants &&
          optionNameText.isNotEmpty &&
          optionValuesList.isNotEmpty;
      final brandText = _brand.text.trim();
      String productId;
      if (widget.existing == null) {
        productId = await widget.vendor.createMyProduct(
          shopId: widget.shopId,
          categoryId: _categoryId,
          name: _name.text.trim(),
          description: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
          price: price,
          compareAtPrice: compareAtPrice,
          stock: stock,
          optionName: hasOptions ? optionNameText : null,
          optionValues: hasOptions ? optionValuesList : const [],
          optionType: hasOptions ? _optionType : 'text',
          optionColors: hasOptions ? optionColorsList : const [],
          optionSoldOut: hasOptions ? optionSoldOutList : const [],
          brand: brandText.isEmpty ? null : brandText,
        );

        for (var i = 0; i < _queuedBytes.length; i++) {
          final name = _queuedNames[i];
          final ext = name.contains('.') ? name.split('.').last : 'jpg';
          final path = _storage.ownedPath(
              '$productId/${DateTime.now().millisecondsSinceEpoch}_$i.$ext');
          final url = await _storage.uploadPublic(
              bucket: 'product-images', path: path, bytes: _queuedBytes[i]);
          await widget.vendor.addMyProductImage(
            productId: productId,
            url: url,
            sortOrder: i,
            focalX: _queuedFocalX[i],
            focalY: _queuedFocalY[i],
            zoom: _queuedZoom[i],
          );
        }
      } else {
        productId = widget.existing!.id;
        await widget.vendor.updateMyProduct(
          id: productId,
          name: _name.text.trim(),
          description: _description.text.trim(),
          price: price,
          compareAtPrice: compareAtPrice,
          clearCompareAtPrice: compareAtPrice == null,
          stock: stock,
          optionName: hasOptions ? optionNameText : '',
          clearOptionName: !hasOptions,
          optionValues: hasOptions ? optionValuesList : const [],
          optionType: hasOptions ? _optionType : 'text',
          optionColors: hasOptions ? optionColorsList : const [],
          optionSoldOut: hasOptions ? optionSoldOutList : const [],
          brand: brandText.isEmpty ? '' : brandText,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _saving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(friendlyError(e, context.read<SettingsController>().t))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.ink),
        title: Text(
          _isEditing ? t('edit_product_title') : t('new_product_title'),
          style: const TextStyle(
              color: AppTheme.ink, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t('photos_label'),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink)),
              const SizedBox(height: 4),
              Text(
                t('photos_instructions'),
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.ink2, height: 1.4),
              ),
              const SizedBox(height: 12),
              _buildPhotosSection(t),
              const SizedBox(height: 24),
              TextFormField(
                controller: _brand,
                decoration:
                    InputDecoration(labelText: t('brand_optional_hint')),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: t('product_name_label')),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? t('required_field')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _description,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: t('description'))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _price,
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: t('price_mru_label')),
                      validator: (v) => (v == null ||
                              double.tryParse(v.trim().replaceAll(',', '.')) ==
                                  null)
                          ? t('invalid_price')
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _stock,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: t('stock_label')),
                      validator: (v) {
                        final n = int.tryParse((v ?? '').trim());
                        if (n == null || n < 0) return t('invalid_stock');
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _compareAtPrice,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: t('compare_price_optional')),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  return double.tryParse(v.trim().replaceAll(',', '.')) == null
                      ? t('invalid_price')
                      : null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _categoryId,
                decoration: InputDecoration(labelText: t('category')),
                items: [
                  DropdownMenuItem(value: null, child: Text(t('none_option'))),
                  ..._categories.map((c) =>
                      DropdownMenuItem(value: c.id, child: Text(c.name))),
                ],
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              const SizedBox(height: 20),
              _buildVariantsSection(t),
              const SizedBox(height: 26),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(t('save_caps')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVariantsSection(String Function(String) t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t('variants_label'),
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink)),
        const SizedBox(height: 4),
        Text(
          t('variants_hint'),
          style:
              const TextStyle(fontSize: 12, color: AppTheme.ink2, height: 1.35),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: _noVariants,
          onChanged: (v) => setState(() {
            _noVariants = v ?? false;
            _optionsError = null;
          }),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(t('no_variants_checkbox'),
              style: const TextStyle(fontSize: 13.5, color: AppTheme.ink)),
        ),
        if (!_noVariants) ...[
          const SizedBox(height: 4),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                  value: 'text',
                  label: Text(t('variant_type_text')),
                  icon: const Icon(Icons.straighten, size: 16)),
              ButtonSegment(
                  value: 'color',
                  label: Text(t('variant_type_color')),
                  icon: const Icon(Icons.palette_outlined, size: 16)),
            ],
            selected: {_optionType},
            onSelectionChanged: (set) => setState(() {
              _optionType = set.first;
              _optionsError = null;

              if (_optionName.text.trim().isEmpty) {
                _optionName.text =
                    _optionType == 'color' ? 'Couleur' : 'Taille';
              }
            }),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _optionName,
            decoration: InputDecoration(labelText: t('option_name_hint')),
          ),
          const SizedBox(height: 12),
          if (_optionType == 'text')
            TextFormField(
              controller: _optionValues,
              decoration: InputDecoration(labelText: t('option_values_hint')),
            )
          else ...[
            Text(
              t('touch_shades_hint'),
              style: const TextStyle(fontSize: 12.5, color: AppTheme.ink2),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final swatch in kSwatchPalette)
                  _PaletteSwatch(
                    swatch: swatch,
                    selected: _selectedHex.contains(swatch.hex),
                    onTap: () => setState(() {
                      if (_selectedHex.contains(swatch.hex)) {
                        _selectedHex.remove(swatch.hex);
                        _soldOutHex.remove(swatch.hex);
                      } else {
                        _selectedHex.add(swatch.hex);
                      }
                      _optionsError = null;
                    }),
                  ),
              ],
            ),
            if (_selectedHex.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                t('chosen_shades_label'),
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ink),
              ),
              const SizedBox(height: 8),
              for (final hex in _selectedHex)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: hexToColor(hex),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.line),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(swatchName(hex),
                              style: const TextStyle(
                                  fontSize: 13.5, color: AppTheme.ink))),
                      Text(t('out_of_stock_label'),
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.muted)),
                      Checkbox(
                        value: _soldOutHex.contains(hex),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _soldOutHex.add(hex);
                          } else {
                            _soldOutHex.remove(hex);
                          }
                        }),
                      ),
                      IconButton(
                        tooltip: t('remove_tooltip'),
                        icon: const Icon(Icons.close,
                            size: 18, color: AppTheme.muted),
                        onPressed: () => setState(() {
                          _selectedHex.remove(hex);
                          _soldOutHex.remove(hex);
                        }),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ],
        if (_optionsError != null) ...[
          const SizedBox(height: 8),
          Text(_optionsError!,
              style: const TextStyle(fontSize: 12.5, color: AppTheme.red)),
        ],
      ],
    );
  }

  Widget _buildPhotosSection(String Function(String) t) {
    final tiles = <Widget>[];
    if (_isEditing) {
      for (var i = 0; i < _existingImages.length; i++) {
        final image = _existingImages[i];
        tiles.add(_PhotoTile(
          bytes: null,
          url: image.url,
          alignment: Alignment(image.focalX * 2 - 1, image.focalY * 2 - 1),
          zoom: image.zoom,
          isCover: i == 0,
          coverLabel: t('cover_badge'),
          onMoveLeft: i > 0 ? () => _moveExistingPhoto(i, -1) : null,
          onMoveRight: i < _existingImages.length - 1
              ? () => _moveExistingPhoto(i, 1)
              : null,
          onDelete: () => _deleteExistingPhoto(image),
          onReposition: () => _repositionExistingPhoto(image),
        ));
      }
    } else {
      for (var i = 0; i < _queuedBytes.length; i++) {
        tiles.add(_PhotoTile(
          bytes: _queuedBytes[i],
          url: null,
          alignment:
              Alignment(_queuedFocalX[i] * 2 - 1, _queuedFocalY[i] * 2 - 1),
          zoom: _queuedZoom[i],
          isCover: i == 0,
          coverLabel: t('cover_badge'),
          onMoveLeft: i > 0 ? () => _moveQueuedPhoto(i, -1) : null,
          onMoveRight:
              i < _queuedBytes.length - 1 ? () => _moveQueuedPhoto(i, 1) : null,
          onDelete: () => _removeQueuedPhoto(i),
          onReposition: () => _repositionQueuedPhoto(i),
        ));
      }
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...tiles,
        GestureDetector(
          onTap: _loadingImages ? null : _pickPhoto,
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppTheme.panel,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.line),
            ),
            alignment: Alignment.center,
            child: _loadingImages
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.add_a_photo_outlined,
                    color: AppTheme.muted, size: 24),
          ),
        ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final Uint8List? bytes;
  final String? url;
  final Alignment alignment;
  final double zoom;
  final bool isCover;
  final String coverLabel;
  final VoidCallback? onMoveLeft;
  final VoidCallback? onMoveRight;
  final VoidCallback onDelete;
  final VoidCallback onReposition;

  const _PhotoTile({
    required this.bytes,
    required this.url,
    required this.alignment,
    required this.zoom,
    required this.isCover,
    required this.coverLabel,
    required this.onMoveLeft,
    required this.onMoveRight,
    required this.onDelete,
    required this.onReposition,
  });

  @override
  Widget build(BuildContext context) {
    final image = bytes != null
        ? Image.memory(bytes!, fit: BoxFit.cover, alignment: alignment)
        : Image.network(url!, fit: BoxFit.cover, alignment: alignment);
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isCover ? AppTheme.ink : AppTheme.line,
            width: isCover ? 1.5 : 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: onReposition,
            child: zoom == 1.0
                ? image
                : Transform.scale(
                    scale: zoom, alignment: alignment, child: image),
          ),
          if (isCover)
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(vertical: 2),
                alignment: Alignment.center,
                child: Text(coverLabel,
                    style: const TextStyle(
                        fontSize: 8.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.black54),
                alignment: Alignment.center,
                child: const Icon(Icons.close, size: 13, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            left: 2,
            bottom: 2,
            child: IgnorePointer(
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.black54),
                alignment: Alignment.center,
                child: const Icon(Icons.control_camera,
                    size: 12, color: Colors.white),
              ),
            ),
          ),
          if (onMoveLeft != null || onMoveRight != null)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _arrowButton(Icons.chevron_left, onMoveLeft),
                  _arrowButton(Icons.chevron_right, onMoveRight),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback? onTap) {
    if (onTap == null) return const SizedBox(width: 18, height: 18);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 18,
        height: 18,
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: Colors.black45),
        alignment: Alignment.center,
        child: Icon(icon, size: 13, color: Colors.white),
      ),
    );
  }
}

class _MyOrderRow extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const _MyOrderRow({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.panel, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.clientFullName,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.ink)),
                  const SizedBox(height: 3),
                  Text(Money.format(order.total),
                      style: const TextStyle(
                          fontSize: 12.5, color: AppTheme.ink2)),
                ],
              ),
            ),
            OrderStatusChip(
                status: order.status, label: t('order_status_${order.status}')),
          ],
        ),
      ),
    );
  }
}

class _MyOrderDetailDialog extends StatefulWidget {
  final VendorService vendor;
  final OrderModel order;

  const _MyOrderDetailDialog({required this.vendor, required this.order});

  @override
  State<_MyOrderDetailDialog> createState() => _MyOrderDetailDialogState();
}

class _MyOrderDetailDialogState extends State<_MyOrderDetailDialog> {
  static const _statuses = [
    'pending',
    'confirmed',
    'preparing',
    'delivering',
    'delivered',
    'cancelled'
  ];

  late Future<List<OrderItemModel>> _itemsFuture;
  late String _status;
  late String _paymentStatus;
  double? _amountReceived;
  bool _saving = false;
  String? _proofSignedUrl;
  bool _loadingProof = false;

  @override
  void initState() {
    super.initState();
    _itemsFuture = widget.vendor.fetchOrderItems(widget.order.id);
    _status = widget.order.status;
    _paymentStatus = widget.order.paymentStatus;
    _amountReceived = widget.order.paymentAmountReceived;
  }

  Future<double?> _askAmount() async {
    final t = context.read<SettingsController>().t;
    final controller = TextEditingController(
      text: widget.order.total.toStringAsFixed(0),
    );
    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('amount_received_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('amount_received_prompt')
                  .replaceAll('{total}', Money.format(widget.order.total)),
              style: const TextStyle(
                  fontSize: 13, height: 1.4, color: AppTheme.ink2),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  InputDecoration(labelText: t('amount_received_title')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t('cancel')),
          ),
          FilledButton(
            onPressed: () {
              final v =
                  double.tryParse(controller.text.trim().replaceAll(',', '.'));
              Navigator.of(context).pop(v);
            },
            child: Text(t('confirm')),
          ),
        ],
      ),
    );
  }

  Future<void> _setPayment(String status) async {
    double? amount;
    if (status == 'verified') {
      amount = await _askAmount();
      if (amount == null || !mounted) return;
    }
    final previous = _paymentStatus;
    final previousAmount = _amountReceived;
    setState(() {
      _paymentStatus = status;
      _amountReceived = status == 'verified' ? amount : null;
    });
    try {
      await widget.vendor
          .setPaymentStatus(widget.order.id, status, amountReceived: amount);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _paymentStatus = previous;
        _amountReceived = previousAmount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(friendlyError(e, context.read<SettingsController>().t))),
      );
    }
  }

  Future<void> _loadProof() async {
    final path = widget.order.paymentProofUrl;
    if (path == null || path.isEmpty) return;
    setState(() => _loadingProof = true);
    try {
      final url = await StorageService().signedPaymentProofUrl(path);
      if (mounted) setState(() => _proofSignedUrl = url);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(friendlyError(e, context.read<SettingsController>().t))));
    } finally {
      if (mounted) setState(() => _loadingProof = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.vendor.updateOrderStatus(widget.order.id, _status);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _saving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(friendlyError(e, context.read<SettingsController>().t))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    final order = widget.order;
    return AlertDialog(
      title: Text(order.clientFullName),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.clientPhone,
                  style: const TextStyle(fontSize: 13, color: AppTheme.ink2)),
              if ((order.clientCity ?? '').isNotEmpty ||
                  (order.clientAddress ?? '').isNotEmpty)
                Text(
                  [order.clientAddress, order.clientCity]
                      .where((s) => s != null && s.isNotEmpty)
                      .join(', '),
                  style: const TextStyle(fontSize: 13, color: AppTheme.ink2),
                ),
              const SizedBox(height: 16),
              Text(t('items_label'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppTheme.ink)),
              const SizedBox(height: 6),
              FutureBuilder<List<OrderItemModel>>(
                future: _itemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: LinearProgressIndicator());
                  }
                  final items = snapshot.data ?? [];
                  return Column(
                    children: [
                      for (final item in items)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                      '${item.productName} × ${item.quantity}',
                                      style: const TextStyle(
                                          fontSize: 13, color: AppTheme.ink))),
                              Text(Money.format(item.subtotal),
                                  style: const TextStyle(
                                      fontSize: 13, color: AppTheme.ink)),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
              const Divider(height: 20, color: AppTheme.line),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(t('total'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.ink)),
                  Text(Money.format(order.total),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.ink)),
                ],
              ),
              const SizedBox(height: 16),
              Text(t('payment_reference_title'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppTheme.ink)),
              const SizedBox(height: 6),
              if (order.paymentReference == null ||
                  order.paymentReference!.isEmpty)
                Text(t('no_code_order_message'),
                    style:
                        const TextStyle(fontSize: 12.5, color: AppTheme.muted))
              else
                Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        order.paymentReference!,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: AppTheme.ink),
                      ),
                    ),
                    IconButton(
                      tooltip: t('copy_tooltip'),
                      icon: const Icon(Icons.copy_outlined,
                          size: 18, color: AppTheme.ink2),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: order.paymentReference!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(t('code_copied'))),
                        );
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Text(t('payment_status_label'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppTheme.ink)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    switch (_paymentStatus) {
                      'verified' => Icons.check_circle,
                      'rejected' => Icons.cancel,
                      _ => Icons.hourglass_top_outlined,
                    },
                    size: 16,
                    color: switch (_paymentStatus) {
                      'verified' => AppTheme.whatsapp,
                      'rejected' => AppTheme.red,
                      _ => AppTheme.stockWarn,
                    },
                  ),
                  const SizedBox(width: 6),
                  Text(
                    switch (_paymentStatus) {
                      'verified' => t('payment_verified_label') +
                          (_amountReceived != null
                              ? t('payment_verified_amount').replaceAll(
                                  '{x}', Money.format(_amountReceived!))
                              : ''),
                      'rejected' => t('payment_rejected_label'),
                      _ => t('payment_submitted_label'),
                    },
                    style: const TextStyle(fontSize: 13, color: AppTheme.ink2),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _paymentStatus == 'verified'
                          ? null
                          : () => _setPayment('verified'),
                      child: Text(t('verify_action')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _paymentStatus == 'rejected'
                          ? null
                          : () => _setPayment('rejected'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.red),
                      child: Text(t('reject_action')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(t('delivery_label'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppTheme.ink)),
              const SizedBox(height: 6),
              if (order.deliveryMapUrl == null)
                Text(t('no_location_shared'),
                    style:
                        const TextStyle(fontSize: 12.5, color: AppTheme.muted))
              else
                OutlinedButton.icon(
                  onPressed: () => launchUrl(Uri.parse(order.deliveryMapUrl!),
                      mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: Text(t('open_in_google_maps')),
                ),
              const SizedBox(height: 16),
              if (order.paymentProofUrl != null &&
                  order.paymentProofUrl!.isNotEmpty) ...[
                Text(t('payment_screenshot_old_order'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.ink)),
                const SizedBox(height: 6),
                if (_proofSignedUrl == null)
                  OutlinedButton.icon(
                    onPressed: _loadingProof ? null : _loadProof,
                    icon: _loadingProof
                        ? const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.image_outlined, size: 18),
                    label: Text(t('view_screenshot')),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      _proofSignedUrl!,
                      height: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Text(t('image_not_found'),
                          style: const TextStyle(
                              color: AppTheme.muted, fontSize: 12)),
                    ),
                  ),
              ],
              const SizedBox(height: 16),
              Text(t('status_label'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppTheme.ink)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _status,
                items: [
                  for (final s in _statuses)
                    DropdownMenuItem(
                        value: s, child: Text(t('order_status_$s')))
                ],
                onChanged: (v) => setState(() => _status = v ?? _status),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
            child: Text(t('close_action'))),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(t('save_status_action')),
        ),
      ],
    );
  }
}

const List<String> _kMerchantProviders = [
  'Bankily',
  'Masrvi',
  'Sedad',
  'Autre'
];

class _MerchantCodeFields extends StatelessWidget {
  final TextEditingController codeController;
  final String provider;
  final ValueChanged<String> onProviderChanged;

  const _MerchantCodeFields({
    required this.codeController,
    required this.provider,
    required this.onProviderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          value: provider,
          decoration: InputDecoration(labelText: t('mobile_bank_label')),
          items: [
            for (final p in _kMerchantProviders)
              DropdownMenuItem(value: p, child: Text(p))
          ],
          onChanged: (v) => onProviderChanged(v ?? _kMerchantProviders.first),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: codeController,
          decoration: InputDecoration(
            labelText: t('merchant_code_label'),
            helperText: t('merchant_code_helper'),
            helperMaxLines: 2,
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? t('merchant_code_required_hint')
              : null,
        ),
      ],
    );
  }
}

class _PickupLocationField extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final ValueChanged<(double, double)> onLocated;

  const _PickupLocationField(
      {required this.initialLat,
      required this.initialLng,
      required this.onLocated});

  @override
  State<_PickupLocationField> createState() => _PickupLocationFieldState();
}

class _PickupLocationFieldState extends State<_PickupLocationField> {
  final _location = LocationService();
  double? _lat;
  double? _lng;
  bool _locating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _lat = widget.initialLat;
    _lng = widget.initialLng;
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
        _lat = position.latitude;
        _lng = position.longitude;
        _locating = false;
      });
      widget.onLocated((position.latitude, position.longitude));
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
      _lat = place.lat;
      _lng = place.lng;
      _error = null;
    });
    widget.onLocated((place.lat, place.lng));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    final located = _lat != null && _lng != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t('pickup_location_label'),
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.ink),
        ),
        const SizedBox(height: 4),
        Text(
          t('pickup_location_hint'),
          style:
              const TextStyle(fontSize: 12, color: AppTheme.muted, height: 1.3),
        ),
        const SizedBox(height: 8),
        PlaceSearchField(
            onSelected: _usePlace, hintText: t('search_shop_address_hint')),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _locating ? null : _useMyPosition,
          icon: _locating
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(located ? Icons.check_circle_outline : Icons.my_location,
                  size: 18),
          label: Text(located
              ? t('location_saved_template')
                  .replaceAll('{lat}', _lat!.toStringAsFixed(5))
                  .replaceAll('{lng}', _lng!.toStringAsFixed(5))
              : t('use_current_location_action')),
        ),
        if (_error != null) ...[
          const SizedBox(height: 6),
          Text(_error!,
              style: const TextStyle(fontSize: 12, color: AppTheme.red)),
        ],
      ],
    );
  }
}

class _PaletteSwatch extends StatelessWidget {
  final Swatch swatch;
  final bool selected;
  final VoidCallback onTap;

  const _PaletteSwatch(
      {required this.swatch, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: swatch.name,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: hexToColor(swatch.hex),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: selected ? AppTheme.ink : AppTheme.line,
              width: selected ? 3 : 1,
            ),
          ),
          child: selected
              ? const Icon(Icons.check,
                  size: 18,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 3)])
              : null,
        ),
      ),
    );
  }
}

class _AnalyticsEntryCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AnalyticsEntryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.panel,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: AppTheme.line),
        ),
        child: Row(
          children: [
            const Icon(Icons.show_chart, size: 20, color: AppTheme.copper),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('vendor_activity_title'),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink)),
                  const SizedBox(height: 2),
                  Text(t('activity_entry_subtitle'),
                      style:
                          const TextStyle(fontSize: 12, color: AppTheme.ink2)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppTheme.muted),
          ],
        ),
      ),
    );
  }
}

class _DashboardCounters extends StatelessWidget {
  final Future<List<Product>> productsFuture;
  final Future<List<OrderModel>> ordersFuture;
  final Future<int> followersFuture;

  const _DashboardCounters({
    required this.productsFuture,
    required this.ordersFuture,
    required this.followersFuture,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    return Row(
      children: [
        Expanded(
          child: FutureBuilder<List<Product>>(
            future: productsFuture,
            builder: (context, snapshot) => _CounterTile(
              value: snapshot.hasData ? '${snapshot.data!.length}' : '—',
              label: t('counter_products'),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FutureBuilder<List<OrderModel>>(
            future: ordersFuture,
            builder: (context, snapshot) {
              final pending = snapshot.hasData
                  ? snapshot.data!.where((o) => o.status == 'pending').length
                  : null;
              return _CounterTile(
                value: pending == null ? '—' : '$pending',
                label: t('counter_to_process'),
                highlight: (pending ?? 0) > 0,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FutureBuilder<int>(
            future: followersFuture,
            builder: (context, snapshot) => _CounterTile(
              value: snapshot.hasData ? '${snapshot.data}' : '—',
              label: t('shop_followers'),
            ),
          ),
        ),
      ],
    );
  }
}

class _CounterTile extends StatelessWidget {
  final String value;
  final String label;
  final bool highlight;

  const _CounterTile(
      {required this.value, required this.label, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: highlight ? AppTheme.ink : AppTheme.panel,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: highlight ? Colors.white : AppTheme.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
                fontSize: 11.5,
                color: highlight ? Colors.white70 : AppTheme.muted),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppTheme.ink : AppTheme.panel,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppTheme.ink,
          ),
        ),
      ),
    );
  }
}
