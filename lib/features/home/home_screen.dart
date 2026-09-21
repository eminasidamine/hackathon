import 'dart:async';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/settings_controller.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/catalog_service.dart';
import '../../services/notification_service.dart';
import '../notifications/notifications_screen.dart';
import '../product/product_screen.dart';
import '../products/all_products_screen.dart';
import '../profile/favorites_screen.dart';
import '../shops/shop_detail_screen.dart';
import '../widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _catalog = CatalogService();
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HomeData> _load() async {
    final products = await _catalog.fetchProducts();
    final favorites = await _catalog.fetchFavoriteProductIds();
    final banners = await _catalog.fetchActiveBanners();
    final discounted = await _catalog.fetchDiscountedProducts();

    final collections = await _catalog.fetchHomeCollections();
    final collectionProducts = <String, List<Product>>{};
    for (final c in collections) {
      final limit = c.productLimit > 8 ? 8 : c.productLimit;
      collectionProducts[c.id] = await _catalog.fetchCollectionProducts(
          categoryId: c.categoryId, limit: limit);
    }
    return _HomeData(
      products: products,
      favoriteIds: favorites,
      banners: banners,
      discounted: discounted,
      collections: collections,
      collectionProducts: collectionProducts,
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  void _openSearch(String query) {
    if (query.trim().isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => AllProductsScreen(search: query.trim())),
    );
  }

  Future<void> _openSearchSheet() async {
    final controller = TextEditingController();
    final t = context.read<SettingsController>().t;
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(sheetContext).viewInsets.bottom + 16),
        child: AppSearchField(
          controller: controller,
          hint: t('search_hint'),
          onSubmitted: (q) {
            Navigator.of(sheetContext).pop();
            _openSearch(q);
          },
        ),
      ),
    );
  }

  void _openAllProducts() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AllProductsScreen()));
  }

  void _openFavorites() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const FavoritesScreen()));
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    if (mounted) context.read<NotificationsController>().refresh();
  }

  void _openShop(String shopId) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ShopDetailScreen(shopId: shopId)));
  }

  Future<void> _toggleFavorite(_HomeData data, Product product) async {
    final isFav = data.favoriteIds.contains(product.id);
    setState(() {
      if (isFav) {
        data.favoriteIds.remove(product.id);
      } else {
        data.favoriteIds.add(product.id);
      }
    });
    await _catalog.toggleFavoriteProduct(product.id, !isFav);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        body: FutureBuilder<_HomeData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return SafeArea(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(children: [
                    const SizedBox(height: 120),
                    EmptyState(
                      icon: Icons.error_outline,
                      title: t('error_generic'),
                      action: FilledButton(
                          onPressed: _refresh, child: Text(t('retry'))),
                    ),
                  ]),
                ),
              );
            }
            final data = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refresh,
              child: SafeArea(
                top: false,
                child: ListView(
                  cacheExtent: 800,
                  children: [
                    _BrandHeaderBar(
                      onSearchTap: _openSearchSheet,
                      onNotificationsTap: _openNotifications,
                      onFavoritesTap: _openFavorites,
                    ),
                    const SizedBox(height: 6),
                    _PromoBanner(
                      imageUrls: data.banners.map((b) => b.imageUrl).toList(),
                      onTap: _openAllProducts,
                    ),
                    if (data.products.isNotEmpty)
                      RepaintBoundary(
                        child: _ProductShowcaseRow(
                          products: data.products,
                          favoriteIds: data.favoriteIds,
                          onToggleFavorite: (p) => _toggleFavorite(data, p),
                          seeAllLabel: t('see_all'),
                          onSeeAll: _openAllProducts,
                        ),
                      ),
                    for (final collection in data.collections)
                      if ((data.collectionProducts[collection.id] ?? const [])
                          .isNotEmpty)
                        RepaintBoundary(
                          child: _CollectionSection(
                            collection: collection,
                            products: data.collectionProducts[collection.id]!,
                            favoriteIds: data.favoriteIds,
                            onToggleFavorite: (p) => _toggleFavorite(data, p),
                            onOpenShop: _openShop,
                          ),
                        ),
                    if (data.discounted.isNotEmpty)
                      RepaintBoundary(
                        child: _ThemedProductRow(
                          title: 'Discounts',
                          products: data.discounted,
                          favoriteIds: data.favoriteIds,
                          onToggleFavorite: (p) => _toggleFavorite(data, p),
                          onOpenShop: _openShop,
                        ),
                      ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandHeaderBar extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onFavoritesTap;

  const _BrandHeaderBar({
    required this.onSearchTap,
    required this.onNotificationsTap,
    required this.onFavoritesTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Image.asset('assets/images/boutigui_logo.png', height: 34),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.search, color: AppTheme.ink, size: 22),
                onPressed: onSearchTap,
              ),
              _NotificationBell(onTap: onNotificationsTap, color: AppTheme.ink),
              IconButton(
                icon: const Icon(CupertinoIcons.heart,
                    color: AppTheme.ink, size: 21),
                onPressed: onFavoritesTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoBanner extends StatefulWidget {
  final List<String> imageUrls;
  final VoidCallback onTap;

  const _PromoBanner({
    required this.imageUrls,
    required this.onTap,
  });

  @override
  State<_PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<_PromoBanner> {
  final _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _startAutoplay();
  }

  void _startAutoplay() {
    _timer?.cancel();
    if (widget.imageUrls.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_page + 1) % widget.imageUrls.length;
      _controller.animateToPage(next,
          duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
    });
  }

  @override
  void didUpdateWidget(covariant _PromoBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrls.length != widget.imageUrls.length) _startAutoplay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;

    final hasMultiple = urls.length >= 2;

    final height = MediaQuery.sizeOf(context).height * 0.56;

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            urls.isEmpty
                ? Image.asset('assets/images/home_banner.jpg',
                    fit: BoxFit.cover, width: double.infinity)
                : PageView.builder(
                    controller: _controller,
                    itemCount: urls.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) => AppImage(
                        url: urls[i], fit: BoxFit.cover, height: height),
                  ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 140,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.38),
                        Colors.black.withValues(alpha: 0.0)
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (hasMultiple)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(urls.length, (i) {
                    final on = i == _page;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: on ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: on
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductShowcaseRow extends StatelessWidget {
  final List<Product> products;
  final Set<String> favoriteIds;
  final ValueChanged<Product> onToggleFavorite;
  final String seeAllLabel;
  final VoidCallback onSeeAll;

  const _ProductShowcaseRow({
    required this.products,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.seeAllLabel,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final shown = products.take(10).toList();

    final cardWidth = MediaQuery.sizeOf(context).width * 0.4;
    const imageRatio = 0.714;

    final cardHeight =
        cardWidth / productGridAspectRatio(cardWidth, imageRatio: imageRatio) +
            16;
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: ClipRect(
        child: SizedBox(
          height: cardHeight,
          child: ListView.builder(
            cacheExtent: 800,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: shown.length + 1,
            itemBuilder: (context, i) {
              if (i == shown.length) {
                return SizedBox(
                    key: const ValueKey('view_all'),
                    width: cardWidth,
                    child: _ViewAllCard(label: seeAllLabel, onTap: onSeeAll));
              }
              final product = shown[i];
              return Padding(
                key: ValueKey(product.id),
                padding: const EdgeInsets.only(right: 6),
                child: SizedBox(
                  width: cardWidth,
                  child: ProductCard(
                    product: product,
                    leftAlign: true,
                    imageAspectRatio: imageRatio,
                    borderRadius: BorderRadius.zero,
                    isFavorite: favoriteIds.contains(product.id),
                    onToggleFavorite: () => onToggleFavorite(product),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => ProductScreen(productId: product.id)),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ViewAllCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ViewAllCard({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.ink,
              decoration: TextDecoration.underline),
        ),
      ),
    );
  }
}

class _CollectionSection extends StatelessWidget {
  final HomeCollection collection;
  final List<Product> products;
  final Set<String> favoriteIds;
  final ValueChanged<Product> onToggleFavorite;
  final ValueChanged<String> onOpenShop;

  const _CollectionSection({
    required this.collection,
    required this.products,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.onOpenShop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 15),
          child: ClipRRect(
            borderRadius: BorderRadius.zero,
            child: AspectRatio(
              aspectRatio: 1.25,
              child: LayoutBuilder(
                builder: (context, constraints) => AppImage(
                  url: collection.imageUrl,
                  fit: BoxFit.cover,
                  height: constraints.maxHeight,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(17, 0, 17, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                collection.title,
                style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: AppTheme.ink),
              ),
              if (collection.subtitle != null &&
                  collection.subtitle!.trim().isNotEmpty) ...[
                const SizedBox(height: 17),
                Text(
                  collection.subtitle!,
                  style: const TextStyle(
                      fontSize: 13.5, color: AppTheme.ink, height: 1.4),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
          child: Column(
            children: [
              for (var i = 0; i < products.length; i += 2) ...[
                if (i > 0) const SizedBox(height: 26),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _collectionCard(context, products[i])),
                    const SizedBox(width: 14),
                    Expanded(
                      child: i + 1 < products.length
                          ? _collectionCard(context, products[i + 1])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _collectionCard(BuildContext context, Product product) {
    return ProductCard(
      product: product,
      leftAlign: true,
      showSellerHeader: true,
      onOpenShop: () => onOpenShop(product.shopId),
      isFavorite: favoriteIds.contains(product.id),
      onToggleFavorite: () => onToggleFavorite(product),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductScreen(productId: product.id)),
      ),
    );
  }
}

class _ThemedProductRow extends StatelessWidget {
  final String title;
  final List<Product> products;
  final Set<String> favoriteIds;
  final ValueChanged<Product> onToggleFavorite;
  final ValueChanged<String> onOpenShop;

  const _ThemedProductRow({
    required this.title,
    required this.products,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.onOpenShop,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.sizeOf(context).width * 0.4;
    const imageRatio = 0.714;

    final cardHeight =
        cardWidth / productGridAspectRatio(cardWidth, imageRatio: imageRatio) +
            30 +
            16;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 34, 20, 14),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: AppTheme.ink)),
        ),
        ClipRect(
          child: SizedBox(
            height: cardHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16),
              itemCount: products.length,
              itemBuilder: (context, i) {
                final product = products[i];
                return Padding(
                  key: ValueKey(product.id),
                  padding: const EdgeInsets.only(right: 6),
                  child: SizedBox(
                    width: cardWidth,
                    child: RepaintBoundary(
                      child: ProductFeedCard(
                        product: product,
                        imageAspectRatio: imageRatio,
                        borderRadius: BorderRadius.zero,
                        isFavorite: favoriteIds.contains(product.id),
                        onToggleFavorite: () => onToggleFavorite(product),
                        onShopTap: () => onOpenShop(product.shopId),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  ProductScreen(productId: product.id)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeData {
  final List<Product> products;
  final Set<String> favoriteIds;
  final List<HomeBanner> banners;
  final List<Product> discounted;
  final List<HomeCollection> collections;
  final Map<String, List<Product>> collectionProducts;

  _HomeData({
    required this.products,
    required this.favoriteIds,
    required this.banners,
    required this.discounted,
    required this.collections,
    required this.collectionProducts,
  });
}

class _NotificationBell extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;

  const _NotificationBell({required this.onTap, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationsController>().unread;
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: color, size: 22),
          onPressed: onTap,
        ),
        if (unread > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16),
              decoration: BoxDecoration(
                color: AppTheme.red,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                unread > 9 ? '9+' : '$unread',
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
