import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/errors.dart';
import '../../core/money.dart';
import '../../core/settings_controller.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/cart_controller.dart';
import '../../services/catalog_service.dart';
import '../auth/login_screen.dart';
import '../shell.dart';
import '../shops/shop_detail_screen.dart';
import '../widgets.dart';

class _SellerSection extends StatelessWidget {
  final Shop shop;
  final String? description;
  final bool isOwner;
  final bool isFollowing;
  final VoidCallback onToggleFollow;

  const _SellerSection({
    required this.shop,
    required this.description,
    required this.isOwner,
    required this.isFollowing,
    required this.onToggleFollow,
  });

  void _openShop(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ShopDetailScreen(shopId: shop.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this product',
          style: AppTheme.system(
              size: 17, weight: FontWeight.w700, letterSpacing: 0),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => _openShop(context),
              customBorder: const CircleBorder(),
              child:
                  ShopAvatar(name: shop.name, logoUrl: shop.logoUrl, size: 62),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: InkWell(
                onTap: () => _openShop(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      shop.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink),
                    ),
                    if (shop.createdAt != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        shopTenureLabel(shop.createdAt!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.muted),
                      ),
                    ] else if (shop.city != null && shop.city!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        shop.city!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.muted),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (!isOwner) ...[
              const SizedBox(width: 10),
              _FollowButton(isFollowing: isFollowing, onTap: onToggleFollow),
            ],
          ],
        ),
        if (description != null && description!.isNotEmpty) ...[
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
                color: AppTheme.panel, borderRadius: BorderRadius.zero),
            child: Text(
              description!,
              style: AppTheme.system(
                  size: 18,
                  weight: FontWeight.w400,
                  color: const Color(0xFF222222),
                  height: 1.4),
            ),
          ),
        ],
      ],
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;

  const _FollowButton({required this.isFollowing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: isFollowing ? Colors.transparent : AppTheme.panel,
          border: Border.all(
              color: isFollowing ? AppTheme.line : Colors.transparent),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          isFollowing ? t('shop_following') : t('shop_follow'),
          style: const TextStyle(
              fontSize: 14.5, fontWeight: FontWeight.w700, color: AppTheme.ink),
        ),
      ),
    );
  }
}

class _WriteToSellerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _WriteToSellerButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 17),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppTheme.panel, borderRadius: BorderRadius.circular(12)),
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.ink),
          ),
        ),
      ),
    );
  }
}

class _DeliveryBand extends StatelessWidget {
  final String label;

  const _DeliveryBand({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.panel,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined,
              size: 19, color: AppTheme.ink2),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 14, color: AppTheme.ink)),
          ),
        ],
      ),
    );
  }
}

class ProductScreen extends StatefulWidget {
  final String productId;

  const ProductScreen({super.key, required this.productId});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _catalog = CatalogService();
  final _imageController = PageController();
  late Future<_ProductData> _future;
  int _quantity = 1;
  int _imagePage = 0;
  bool _isFavorite = false;
  String? _selectedOption;
  String? _optionError;

  String? _shopId;
  bool _isFollowingShop = false;
  bool _followBusy = false;

  String? _reviewableOrderId;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  Future<_ProductData> _load() async {
    final product = await _catalog.fetchProduct(widget.productId);
    final shop =
        product == null ? null : await _catalog.fetchShop(product.shopId);
    _shopId = shop?.id;

    List<Review> reviews = const [];
    try {
      reviews = await _catalog.fetchReviews(widget.productId);
    } catch (e) {
      debugPrint('avis non chargés: $e');
    }

    try {
      final favorites = await _catalog.fetchFavoriteProductIds();
      _isFavorite = favorites.contains(widget.productId);
    } catch (e) {
      debugPrint('favoris non chargés: $e');
    }

    if (shop != null) {
      try {
        _isFollowingShop = await _catalog.isFollowingShop(shop.id);
      } catch (e) {
        debugPrint('abonnement non chargé: $e');
      }
    }

    try {
      _reviewableOrderId =
          await _catalog.fetchReviewableOrderId(widget.productId);
    } catch (e) {
      debugPrint('commande éligible à un avis non vérifiée: $e');
    }

    return _ProductData(product: product, shop: shop, reviews: reviews);
  }

  Future<void> _refreshReviews() async {
    try {
      final reviews = await _catalog.fetchReviews(widget.productId);
      final reviewableOrderId =
          await _catalog.fetchReviewableOrderId(widget.productId);
      if (!mounted) return;
      final current = await _future;
      setState(() {
        _reviewableOrderId = reviewableOrderId;
        _future = Future.value(_ProductData(
            product: current.product, shop: current.shop, reviews: reviews));
      });
    } catch (_) {}
  }

  Future<void> _openWriteReview(String orderId, String productId) async {
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _WriteReviewSheet(
          catalog: _catalog, productId: productId, orderId: orderId),
    );
    if (submitted == true) await _refreshReviews();
  }

  Future<void> _toggleFollowShop() async {
    final shopId = _shopId;
    if (shopId == null || _followBusy) return;
    _requireLogin(() async {
      final next = !_isFollowingShop;
      setState(() {
        _isFollowingShop = next;
        _followBusy = true;
      });
      try {
        await _catalog.toggleFollowShop(shopId, next);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isFollowingShop = !next);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(context.read<SettingsController>().t('error_generic'))),
        );
      } finally {
        if (mounted) setState(() => _followBusy = false);
      }
    });
  }

  void _requireLogin(VoidCallback action) {
    final auth = context.read<AuthService>();
    if (!auth.isLoggedIn) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    action();
  }

  Future<void> _toggleFavorite() async {
    _requireLogin(() async {
      setState(() => _isFavorite = !_isFavorite);
      await _catalog.toggleFavoriteProduct(widget.productId, _isFavorite);
    });
  }

  void _addToCart(Product product) {
    if (product.hasOptions && _selectedOption == null) {
      setState(() => _optionError =
          '${product.optionName} — choose an option before adding to bag.');
      return;
    }

    final capped = context
        .read<CartController>()
        .add(product, quantity: _quantity, selectedOption: _selectedOption);
    if (capped) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Only ${product.stock} in stock — your bag was adjusted to what\'s available.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) =>
          _AddedToBagSheet(product: product, option: _selectedOption),
    );
  }

  Future<void> _openWhatsapp(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: FutureBuilder<_ProductData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          final product = data?.product;
          if (product == null) {
            return Scaffold(
              appBar: AppBar(),
              body: EmptyState(
                icon: Icons.error_outline,
                title: snapshot.hasError ? t('error_generic') : t('no_results'),
                subtitle: snapshot.hasError
                    ? friendlyError(snapshot.error!, t)
                    : null,
              ),
            );
          }
          final shop = data!.shop;
          final avgRating = data.reviews.isEmpty
              ? 0.0
              : data.reviews.fold<int>(0, (sum, r) => sum + r.rating) /
                  data.reviews.length;
          final images = product.imageUrls.isEmpty
              ? const <String?>[null]
              : product.imageUrls;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _ProductImageHeader(
                  images: images,
                  controller: _imageController,
                  page: _imagePage,
                  onPageChanged: (i) => setState(() => _imagePage = i),
                  onBack: () => Navigator.of(context).maybePop(),
                  isFavorite: _isFavorite,
                  onToggleFavorite: _toggleFavorite,
                  isOnSale: product.isOnSale,
                  isNew: product.isNew,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (shop != null && product.brandLine.isNotEmpty)
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    ShopDetailScreen(shopId: shop.id)),
                          ),
                          child: Text(
                            product.brandLine,
                            style: AppTheme.system(
                                size: 19,
                                weight: FontWeight.w400,
                                color: const Color(0xFF1A1A1A)),
                          ),
                        ),
                      const SizedBox(height: 5),
                      Text(
                        product.name,
                        style: AppTheme.system(
                            size: 14,
                            weight: FontWeight.w400,
                            color: const Color(0xFF1A1A1A)),
                      ),
                      const SizedBox(height: 3),
                      if (product.isOnSale)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              Money.format(product.compareAtPrice!),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.muted,
                                  decoration: TextDecoration.lineThrough),
                            ),
                            Text(
                              '${Money.format(product.price)} -${product.discountPercent}%',
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A)),
                            ),
                          ],
                        )
                      else
                        Text(
                          Money.format(product.price),
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A)),
                        ),
                      if (data.reviews.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(children: [
                          StarRating(rating: avgRating),
                          const SizedBox(width: 6),
                          Text('(${data.reviews.length})',
                              style: const TextStyle(
                                  color: AppTheme.muted, fontSize: 13)),
                        ]),
                      ],
                      if (product.hasOptions) ...[
                        const SizedBox(height: 22),
                        _OptionPicker(
                          label: product.optionName!,
                          values: product.optionType == 'color' &&
                                  product.optionValues.length !=
                                      product.optionColors.length
                              ? [
                                  for (final hex in product.optionColors)
                                    swatchName(hex)
                                ]
                              : product.optionValues,
                          colors: product.optionColors,
                          soldOut: product.optionSoldOut,
                          isColor: product.optionType == 'color',
                          selected: _selectedOption,
                          onSelect: (v) {
                            setState(() {
                              _selectedOption = v;
                              _optionError = null;
                            });

                            if (product.optionType == 'color') {
                              final displayValues = product
                                          .optionValues.length ==
                                      product.optionColors.length
                                  ? product.optionValues
                                  : [
                                      for (final hex in product.optionColors)
                                        swatchName(hex)
                                    ];
                              final idx = displayValues.indexOf(v);
                              if (idx >= 0 && idx < product.imageUrls.length) {
                                _imageController.animateToPage(
                                  idx,
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOut,
                                );
                              }
                            }
                          },
                        ),
                        if (_optionError != null) ...[
                          const SizedBox(height: 8),
                          Text(_optionError!,
                              style: const TextStyle(
                                  fontSize: 12.5, color: AppTheme.red)),
                        ],
                      ],
                      const SizedBox(height: 26),
                    ],
                  ),
                ),
              ),
              if (shop != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
                    child: _SellerSection(
                      shop: shop,
                      description: product.description,
                      isOwner: context.watch<AuthService>().currentUser?.id ==
                          shop.ownerId,
                      isFollowing: _isFollowingShop,
                      onToggleFollow: _toggleFollowShop,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (shop != null &&
                          shop.whatsappPhone != null &&
                          shop.whatsappPhone!.isNotEmpty) ...[
                        _WriteToSellerButton(
                          label: t('write_to_seller'),
                          onTap: () => _openWhatsapp(shop.whatsappPhone!),
                        ),
                        const SizedBox(height: 26),
                      ],
                      if (shop == null &&
                          product.description != null &&
                          product.description!.isNotEmpty) ...[
                        Text(t('description'),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppTheme.ink)),
                        const SizedBox(height: 6),
                        Text(product.description!,
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.ink,
                                height: 1.45)),
                        const SizedBox(height: 26),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: Text(t('reviews'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppTheme.ink)),
                          ),
                          if (_reviewableOrderId != null)
                            TextButton(
                              onPressed: () => _openWriteReview(
                                  _reviewableOrderId!, product.id),
                              child: const Text('Write a review'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (data.reviews.isEmpty)
                        Text(t('no_results'),
                            style: const TextStyle(
                                color: AppTheme.muted, fontSize: 13))
                      else
                        ...data.reviews.map((r) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Text(r.authorName ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: AppTheme.ink)),
                                    const SizedBox(width: 8),
                                    StarRating(
                                        rating: r.rating.toDouble(), size: 14),
                                  ]),
                                  if (r.comment != null &&
                                      r.comment!.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(r.comment!,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.ink2)),
                                  ],
                                ],
                              ),
                            )),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<_ProductData>(
        future: _future,
        builder: (context, snapshot) {
          final product = snapshot.data?.product;
          if (product == null) return const SizedBox.shrink();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.line),
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                          icon: const Icon(Icons.remove, size: 18),
                        ),
                        SizedBox(
                            width: 20,
                            child: Text('$_quantity',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.ink))),
                        IconButton(
                          onPressed: _quantity < product.stock
                              ? () => setState(() => _quantity++)
                              : null,
                          icon: const Icon(Icons.add, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed:
                          product.stock <= 0 ? null : () => _addToCart(product),
                      child: Text(t('add_to_cart').toUpperCase(),
                          style: const TextStyle(letterSpacing: 0.6)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductImageHeader extends StatelessWidget {
  final List<String?> images;
  final PageController controller;
  final int page;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onBack;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final bool isOnSale;
  final bool isNew;

  const _ProductImageHeader({
    required this.images,
    required this.controller,
    required this.page,
    required this.onPageChanged,
    required this.onBack,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.isOnSale,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.94,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: AppTheme.imageBg),
          PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: images.length,
            itemBuilder: (context, i) =>
                AppImage(url: images[i], fit: BoxFit.contain),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 12,
            child: _RoundIconButton(icon: Icons.arrow_back, onTap: onBack),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            right: 12,
            child: _RoundIconButton(
              icon: isFavorite
                  ? CupertinoIcons.bookmark_fill
                  : CupertinoIcons.bookmark,
              onTap: onToggleFavorite,
              color: isFavorite ? AppTheme.red : AppTheme.ink,
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 14,
              left: 16,
              right: 16,
              child: Row(
                children: List.generate(images.length, (i) {
                  final on = i == page;
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.only(
                          right: i == images.length - 1 ? 0 : 5),
                      decoration: BoxDecoration(
                        color: on ? AppTheme.ink : AppTheme.pagerOff,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  final bool flipHorizontal;

  const _RoundIconButton(
      {required this.icon,
      required this.onTap,
      this.color = AppTheme.ink,
      this.flipHorizontal = false});

  @override
  Widget build(BuildContext context) {
    Widget child = Icon(icon, size: 19, color: color);
    if (flipHorizontal) {
      child = Transform.flip(flipX: true, child: child);
    }
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: child,
        ),
      ),
    );
  }
}

class _OptionPicker extends StatelessWidget {
  final String label;
  final List<String> values;
  final List<String> colors;
  final List<bool> soldOut;
  final bool isColor;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _OptionPicker({
    required this.label,
    required this.values,
    required this.selected,
    required this.onSelect,
    this.colors = const [],
    this.soldOut = const [],
    this.isColor = false,
  });

  bool _isSoldOut(int i) => i < soldOut.length && soldOut[i];

  @override
  Widget build(BuildContext context) {
    if (isColor) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink)),
              if (selected != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selected!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 13.5, color: AppTheme.ink2),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < values.length; i++)
                _Swatch(
                  hex: i < colors.length ? colors[i] : '#CCCCCC',
                  selected: values[i] == selected,
                  soldOut: _isSoldOut(i),
                  onTap: _isSoldOut(i) ? null : () => onSelect(values[i]),
                ),
            ],
          ),
        ],
      );
    }
    return _SizeDropdownField(
      label: label,
      values: values,
      soldOut: soldOut,
      selected: selected,
      onSelect: onSelect,
    );
  }
}

class _SizeDropdownField extends StatelessWidget {
  final String label;
  final List<String> values;
  final List<bool> soldOut;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _SizeDropdownField({
    required this.label,
    required this.values,
    required this.soldOut,
    required this.selected,
    required this.onSelect,
  });

  bool _isSoldOut(int i) => i < soldOut.length && soldOut[i];

  Future<void> _openPicker(BuildContext context) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select your ${label.toLowerCase()}',
                      style: AppTheme.system(size: 17, weight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.close, size: 22, color: AppTheme.ink),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: values.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppTheme.hair),
                itemBuilder: (context, i) {
                  final isSoldOut = _isSoldOut(i);
                  final isSelected = values[i] == selected;
                  return ListTile(
                    enabled: !isSoldOut,
                    title: Text(
                      values[i],
                      style: AppTheme.system(
                        size: 15,
                        weight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSoldOut ? AppTheme.muted : AppTheme.ink,
                      ).copyWith(
                          decoration:
                              isSoldOut ? TextDecoration.lineThrough : null),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, size: 18, color: AppTheme.ink)
                        : null,
                    onTap: isSoldOut
                        ? null
                        : () => Navigator.of(context).pop(values[i]),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
    if (chosen != null) onSelect(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = selected != null && selected!.isNotEmpty;
    return InkWell(
      onTap: () => _openPicker(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.ink, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasSelection ? selected! : 'Select your ${label.toLowerCase()}',
                overflow: TextOverflow.ellipsis,
                style: AppTheme.system(
                  size: 15,
                  weight: FontWeight.w400,
                  color: hasSelection ? AppTheme.ink : AppTheme.ink2,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down,
                size: 22, color: AppTheme.ink),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final String hex;
  final bool selected;
  final bool soldOut;
  final VoidCallback? onTap;

  const _Swatch(
      {required this.hex,
      required this.selected,
      required this.soldOut,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: hexToColor(hex),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected ? AppTheme.ink : AppTheme.line,
              width: selected ? 2.5 : 1,
            ),
          ),
          child: soldOut
              ? const CustomPaint(painter: _SoldOutLinePainter())
              : (selected
                  ? const Icon(Icons.check,
                      size: 14,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 4)])
                  : null),
        ),
      ),
    );
  }
}

class _SoldOutLinePainter extends CustomPainter {
  const _SoldOutLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3D3D3D)
      ..strokeWidth = 1.6;
    canvas.drawLine(Offset(size.width * 0.12, size.height * 0.12),
        Offset(size.width * 0.88, size.height * 0.88), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TextChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final bool soldOut;
  final VoidCallback? onTap;

  const _TextChoice(
      {required this.label,
      required this.selected,
      required this.soldOut,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.ink : Colors.transparent,
          border: Border.all(color: selected ? AppTheme.ink : AppTheme.line),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: soldOut
                ? AppTheme.muted
                : (selected ? Colors.white : AppTheme.ink),
            decoration: soldOut ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}

class _WriteReviewSheet extends StatefulWidget {
  final CatalogService catalog;
  final String productId;
  final String orderId;

  const _WriteReviewSheet(
      {required this.catalog, required this.productId, required this.orderId});

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  int _rating = 5;
  final _comment = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.catalog.createReview(
        productId: widget.productId,
        orderId: widget.orderId,
        rating: _rating,
        comment: _comment.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = friendlyError(e, context.read<SettingsController>().t);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 18, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Write a review',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    onPressed: () => setState(() => _rating = i),
                    icon: Icon(
                      i <= _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 30,
                      color: i <= _rating ? AppTheme.ink : AppTheme.muted,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _comment,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Share a few words about this product (optional)',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!,
                  style: const TextStyle(color: AppTheme.red, fontSize: 12.5)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Submit review'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductData {
  final Product? product;
  final Shop? shop;
  final List<Review> reviews;

  _ProductData(
      {required this.product, required this.shop, required this.reviews});
}

class _AddedToBagSheet extends StatelessWidget {
  final Product product;
  final String? option;

  const _AddedToBagSheet({required this.product, required this.option});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    final brand = (product.brand?.isNotEmpty ?? false)
        ? product.brand!
        : (product.shopName ?? '');
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 18, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    t('added_to_bag_title'),
                    style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 22, color: AppTheme.ink),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppImage(
                    url: product.imageUrls.isNotEmpty
                        ? product.imageUrls.first
                        : null,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (brand.isNotEmpty)
                        Text(brand.toUpperCase(), style: AppTheme.productBrand),
                      const SizedBox(height: 3),
                      Text(product.name,
                          style: AppTheme.productName.copyWith(fontSize: 14)),
                      if (option != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          '${product.optionName ?? 'Option'} $option',
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.ink2),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(Money.format(product.price),
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.ink)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((r) => r.isFirst);
                Shell.navKey.currentState?.goToBag();
              },
              child: Text(t('go_to_bag').toUpperCase(),
                  style: const TextStyle(letterSpacing: 0.6)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t('keep_shopping'),
                  style: const TextStyle(color: AppTheme.ink2)),
            ),
          ],
        ),
      ),
    );
  }
}
