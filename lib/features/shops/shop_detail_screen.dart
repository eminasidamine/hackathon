import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/errors.dart';
import '../../core/settings_controller.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/catalog_service.dart';
import '../product/product_screen.dart';
import '../widgets.dart';

class ShopDetailScreen extends StatefulWidget {
  final String shopId;

  const ShopDetailScreen({super.key, required this.shopId});

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

enum _ShopTab { products, reviews }

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  final _catalog = CatalogService();
  late Future<_ShopData> _future;
  final Set<String> _favoriteIds = {};
  bool _isFollowing = false;
  bool _followLoading = false;
  int? _followerCount;
  _ShopTab _activeTab = _ShopTab.products;
  String? _categoryFilter;
  bool _favoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _catalog.recordShopVisit(widget.shopId);
    _catalog.fetchFavoriteProductIds().then((ids) {
      if (mounted) setState(() => _favoriteIds.addAll(ids));
    });
    _catalog.isFollowingShop(widget.shopId).then((v) {
      if (mounted) setState(() => _isFollowing = v);
    });
    _catalog.fetchShopFollowerCount(widget.shopId).then((v) {
      if (mounted) setState(() => _followerCount = v);
    });
  }

  Future<void> _toggleFollow() async {
    if (_followLoading) return;
    final next = !_isFollowing;
    setState(() {
      _isFollowing = next;
      _followerCount = (_followerCount ?? 0) + (next ? 1 : -1);
      _followLoading = true;
    });
    try {
      await _catalog.toggleFollowShop(widget.shopId, next);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFollowing = !next;
        _followerCount = (_followerCount ?? 0) + (next ? -1 : 1);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(friendlyError(e, context.read<SettingsController>().t))));
    } finally {
      if (mounted) setState(() => _followLoading = false);
    }
  }

  Future<_ShopData> _load() async {
    final shop = await _catalog.fetchShop(widget.shopId);
    if (shop == null) {
      return _ShopData(
          shop: null,
          products: const [],
          productCount: 0,
          reviews: const [],
          categories: const []);
    }
    final products = await _catalog.fetchProducts(shopId: widget.shopId);
    final count = await _catalog.fetchShopProductCount(widget.shopId);
    final reviews =
        await _catalog.fetchShopReviews(products.map((p) => p.id).toList());

    final allCategories = await _catalog.fetchCategories();
    final nameById = {for (final c in allCategories) c.id: c.name};
    final seen = <String>{};
    final categories = <_CategoryOption>[];
    for (final p in products) {
      final cid = p.categoryId;
      if (cid == null || seen.contains(cid)) continue;
      seen.add(cid);
      categories.add(_CategoryOption(id: cid, name: nameById[cid] ?? '?'));
    }

    return _ShopData(
        shop: shop,
        products: products,
        productCount: count,
        reviews: reviews,
        categories: categories);
  }

  Future<void> _toggleFavorite(Product product) async {
    final isFav = _favoriteIds.contains(product.id);
    setState(() {
      if (isFav) {
        _favoriteIds.remove(product.id);
      } else {
        _favoriteIds.add(product.id);
      }
    });
    await _catalog.toggleFavoriteProduct(product.id, !isFav);
  }

  Future<void> _openCityMap(String city) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(city)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _tenureLabel(DateTime createdAt) =>
      'Resale Store • ${shopTenureLabel(createdAt)} with us';

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: FutureBuilder<_ShopData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null || data.shop == null) {
            return Scaffold(
              backgroundColor: AppTheme.bg,
              appBar: AppBar(),
              body: EmptyState(
                  icon: Icons.storefront_outlined, title: t('no_results')),
            );
          }
          final shop = data.shop!;
          final isOwner =
              context.watch<AuthService>().currentUser?.id == shop.ownerId;

          var products = data.products;
          if (_categoryFilter != null) {
            products =
                products.where((p) => p.categoryId == _categoryFilter).toList();
          }
          if (_favoritesOnly) {
            products =
                products.where((p) => _favoriteIds.contains(p.id)).toList();
          }

          return CustomScrollView(
            cacheExtent: 800,
            slivers: [
              SliverAppBar(
                backgroundColor: AppTheme.bg,
                surfaceTintColor: AppTheme.bg,
                pinned: true,
                centerTitle: true,
                title: Text(shop.name,
                    style: const TextStyle(
                        color: AppTheme.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                iconTheme: const IconThemeData(color: AppTheme.ink),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ShopAvatar(
                              name: shop.name, logoUrl: shop.logoUrl, size: 72),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _ShopStat(
                                    value: '${data.productCount}',
                                    label: data.productCount > 1
                                        ? 'items'
                                        : 'item'),
                                _ShopStat(
                                  value: '${_followerCount ?? ''}',
                                  label: (_followerCount ?? 0) > 1
                                      ? t('shop_followers')
                                      : t('shop_follower'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (shop.createdAt != null)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _tenureLabel(shop.createdAt!),
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.ink2,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      if (shop.city != null && shop.city!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: AppTheme.muted),
                            const SizedBox(width: 3),
                            Text(shop.city!,
                                style: const TextStyle(
                                    fontSize: 13, color: AppTheme.muted)),
                          ],
                        ),
                      ],
                      if (shop.description != null &&
                          shop.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(shop.description!,
                            style: const TextStyle(
                                fontSize: 13.5,
                                color: AppTheme.ink2,
                                height: 1.4)),
                      ],
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _PillButton(
                              label: 'Wishlist',
                              active: _favoritesOnly,
                              onTap: () => setState(
                                  () => _favoritesOnly = !_favoritesOnly),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _PillButton(
                              label: 'Locate',
                              enabled:
                                  shop.city != null && shop.city!.isNotEmpty,
                              onTap: () => _openCityMap(shop.city!),
                            ),
                          ),
                        ],
                      ),
                      if (!isOwner) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: _isFollowing
                              ? OutlinedButton(
                                  onPressed: _toggleFollow,
                                  style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: AppTheme.line)),
                                  child: Text(t('shop_following'),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.ink)),
                                )
                              : FilledButton(
                                  onPressed: _toggleFollow,
                                  style: FilledButton.styleFrom(
                                      backgroundColor: AppTheme.ink),
                                  child: Text(t('shop_follow'),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _ShopTabBar(
                  active: _activeTab,
                  reviewCount: data.reviews.length,
                  onSelect: (tab) => setState(() => _activeTab = tab),
                ),
              ),
              if (_activeTab == _ShopTab.products && data.categories.length > 1)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      children: [
                        _CategoryChip(
                            label: 'All',
                            selected: _categoryFilter == null,
                            onTap: () =>
                                setState(() => _categoryFilter = null)),
                        for (final c in data.categories) ...[
                          const SizedBox(width: 8),
                          _CategoryChip(
                              label: c.name,
                              selected: _categoryFilter == c.id,
                              onTap: () =>
                                  setState(() => _categoryFilter = c.id)),
                        ],
                      ],
                    ),
                  ),
                ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Divider(height: 1, color: AppTheme.line),
                ),
              ),
              if (_activeTab == _ShopTab.products)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
                  sliver: products.isEmpty
                      ? SliverToBoxAdapter(
                          child: EmptyState(
                              icon: Icons.inventory_2_outlined,
                              title: t('no_results')))
                      : SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 12,
                            childAspectRatio: productGridAspectRatio(
                              (MediaQuery.of(context).size.width - 36) / 2,
                              withSellerHeader: true,
                            ),
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final product = products[i];
                              return ProductCard(
                                key: ValueKey(product.id),
                                product: product,
                                showShopName: false,
                                showSellerHeader: true,
                                isFavorite: _favoriteIds.contains(product.id),
                                onToggleFavorite: () =>
                                    _toggleFavorite(product),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ProductScreen(productId: product.id)),
                                ),
                              );
                            },
                            childCount: products.length,
                          ),
                        ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: data.reviews.isEmpty
                      ? SliverToBoxAdapter(
                          child: EmptyState(
                              icon: Icons.rate_review_outlined,
                              title: t('no_results')))
                      : SliverList.separated(
                          itemCount: data.reviews.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final review = data.reviews[i];
                            final productName = data.products
                                .firstWhere(
                                  (p) => p.id == review.productId,
                                  orElse: () => Product(
                                      id: '', shopId: '', name: '', price: 0),
                                )
                                .name;
                            return _ReviewCard(
                                review: review, productName: productName);
                          },
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ShopData {
  final Shop? shop;
  final List<Product> products;
  final int productCount;
  final List<Review> reviews;
  final List<_CategoryOption> categories;

  _ShopData({
    required this.shop,
    required this.products,
    required this.productCount,
    required this.reviews,
    required this.categories,
  });
}

class _CategoryOption {
  final String id;
  final String name;

  _CategoryOption({required this.id, required this.name});
}

class _ShopStat extends StatelessWidget {
  final String value;
  final String label;

  const _ShopStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink)),
        Text(label,
            style: const TextStyle(fontSize: 13.5, color: AppTheme.ink)),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool enabled;

  const _PillButton(
      {required this.label,
      required this.onTap,
      this.active = false,
      this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppTheme.ink : AppTheme.panel,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppTheme.ink),
          ),
        ),
      ),
    );
  }
}

class _ShopTabBar extends StatelessWidget {
  final _ShopTab active;
  final int reviewCount;
  final ValueChanged<_ShopTab> onSelect;

  const _ShopTabBar(
      {required this.active,
      required this.reviewCount,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _ShopTabItem(
              label: 'Items',
              selected: active == _ShopTab.products,
              onTap: () => onSelect(_ShopTab.products)),
          const SizedBox(width: 24),
          _ShopTabItem(
              label: 'Reviews ($reviewCount)',
              selected: active == _ShopTab.reviews,
              onTap: () => onSelect(_ShopTab.reviews)),
        ],
      ),
    );
  }
}

class _ShopTabItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ShopTabItem(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppTheme.ink : AppTheme.muted,
              ),
            ),
            const SizedBox(height: 6),
            Container(
                height: 2,
                width: 26,
                color: selected ? AppTheme.ink : Colors.transparent),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppTheme.ink : AppTheme.panel,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppTheme.ink2),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  final String productName;

  const _ReviewCard({required this.review, required this.productName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.authorName ?? 'Customer',
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.ink),
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 15,
                    color: const Color(0xFFE0A34D),
                  ),
                ),
              ),
            ],
          ),
          if (productName.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text('On "$productName"',
                style: const TextStyle(fontSize: 11.5, color: AppTheme.muted)),
          ],
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.comment!,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.ink2, height: 1.4)),
          ],
        ],
      ),
    );
  }
}
