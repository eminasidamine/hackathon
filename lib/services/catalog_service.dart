import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_config.dart';
import '../models/models.dart';

class CatalogService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Shop>> fetchShops({int page = 0, String? search}) async {
    var query = _client.from('shops').select().eq('is_visible', true);
    if (search != null && search.isNotEmpty) {
      query = query.ilike('name', '%$search%');
    }
    final rows = await query.order('created_at', ascending: false).range(
        page * AppConfig.pageSize,
        page * AppConfig.pageSize + AppConfig.pageSize - 1);
    return rows.map((r) => Shop.fromMap(r)).toList();
  }

  Future<Shop?> fetchShop(String shopId) async {
    final row =
        await _client.from('shops').select().eq('id', shopId).maybeSingle();
    return row == null ? null : Shop.fromMap(row);
  }

  Future<List<Category>> fetchCategories({String? gender}) async {
    var query = _client
        .from('categories')
        .select()
        .eq('is_visible', true)
        .filter('parent_id', 'is', null);
    if (gender != null) {
      query = query.or('gender.eq.$gender,gender.eq.*');
    }
    final rows = await query.order('sort_order');
    return rows.map((r) => Category.fromMap(r)).toList();
  }

  Future<List<Category>> fetchAllCategories() async {
    final rows = await _client
        .from('categories')
        .select()
        .eq('is_visible', true)
        .order('sort_order');
    return rows.map((r) => Category.fromMap(r)).toList();
  }

  static const String _productSelect =
      'id, shop_id, category_id, name, description, price, compare_at_price, stock, is_visible, '
      'created_at, option_name, option_values, option_type, option_colors, option_sold_out, brand, '
      'product_images(url, sort_order, focal_x, focal_y, zoom), shops(id, name, logo_url, is_visible)';

  Future<List<Product>> fetchProducts({
    int page = 0,
    String? shopId,
    String? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    String sort = 'newest',
  }) async {
    var query =
        _client.from('products').select(_productSelect).eq('is_visible', true);
    if (shopId != null) query = query.eq('shop_id', shopId);
    if (categoryId != null) query = query.eq('category_id', categoryId);
    if (search != null && search.isNotEmpty)
      query = query.ilike('name', '%$search%');
    if (minPrice != null) query = query.gte('price', minPrice);
    if (maxPrice != null) query = query.lte('price', maxPrice);
    final ordered = switch (sort) {
      'price_asc' => query.order('price', ascending: true),
      'price_desc' => query.order('price', ascending: false),
      _ => query.order('created_at', ascending: false),
    };
    final rows = await ordered.range(page * AppConfig.pageSize,
        page * AppConfig.pageSize + AppConfig.pageSize - 1);
    return rows.map((r) => Product.fromMap(r)).toList();
  }

  Future<Product?> fetchProduct(String productId) async {
    final row = await _client
        .from('products')
        .select(_productSelect)
        .eq('id', productId)
        .maybeSingle();
    return row == null ? null : Product.fromMap(row);
  }

  Future<List<Review>> fetchReviews(String productId) async {
    final rows = await _client
        .from('reviews')
        .select(
            'id, product_id, client_id, rating, comment, created_at, review_authors(full_name)')
        .eq('product_id', productId)
        .eq('is_visible', true)
        .order('created_at', ascending: false);
    return rows.map((r) => Review.fromMap(r)).toList();
  }

  Future<String?> fetchReviewableOrderId(String productId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final purchased = await _client
        .from('order_items')
        .select('order_id, orders!inner(client_id)')
        .eq('product_id', productId)
        .eq('orders.client_id', userId);
    if (purchased.isEmpty) return null;
    final orderIds = purchased.map((r) => r['order_id'] as String).toSet();
    final reviewed = await _client
        .from('reviews')
        .select('order_id')
        .eq('product_id', productId)
        .eq('client_id', userId);
    final reviewedIds = reviewed
        .map((r) => r['order_id'] as String?)
        .whereType<String>()
        .toSet();
    final remaining = orderIds.difference(reviewedIds);
    return remaining.isEmpty ? null : remaining.first;
  }

  Future<void> createReview({
    required String productId,
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('reviews').insert({
      'product_id': productId,
      'client_id': userId,
      'order_id': orderId,
      'rating': rating,
      'comment':
          (comment == null || comment.trim().isEmpty) ? null : comment.trim(),
    });
  }

  Future<List<Review>> fetchShopReviews(List<String> productIds) async {
    if (productIds.isEmpty) return [];
    final rows = await _client
        .from('reviews')
        .select(
            'id, product_id, client_id, rating, comment, created_at, review_authors(full_name)')
        .inFilter('product_id', productIds)
        .eq('is_visible', true)
        .order('created_at', ascending: false);
    return rows.map((r) => Review.fromMap(r)).toList();
  }

  Future<void> submitReview({
    required String productId,
    required int rating,
    String? comment,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('reviews').insert({
      'product_id': productId,
      'client_id': userId,
      'rating': rating,
      'comment': comment,
    });
  }

  Future<void> toggleFavoriteProduct(String productId, bool isFavorite) async {
    final userId = _client.auth.currentUser!.id;
    if (isFavorite) {
      await _client
          .from('favorite_products')
          .insert({'user_id': userId, 'product_id': productId});
    } else {
      await _client
          .from('favorite_products')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);
    }
  }

  Future<Set<String>> fetchFavoriteProductIds() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return {};
    final rows = await _client
        .from('favorite_products')
        .select('product_id')
        .eq('user_id', userId);
    return rows.map((r) => r['product_id'] as String).toSet();
  }

  Future<void> toggleFollowShop(String shopId, bool isFollowing) async {
    final userId = _client.auth.currentUser!.id;
    if (isFollowing) {
      await _client
          .from('favorite_shops')
          .insert({'user_id': userId, 'shop_id': shopId});
    } else {
      await _client
          .from('favorite_shops')
          .delete()
          .eq('user_id', userId)
          .eq('shop_id', shopId);
    }
  }

  Future<bool> isFollowingShop(String shopId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;
    final row = await _client
        .from('favorite_shops')
        .select('shop_id')
        .eq('user_id', userId)
        .eq('shop_id', shopId)
        .maybeSingle();
    return row != null;
  }

  Future<int> fetchShopFollowerCount(String shopId) async {
    final count = await _client
        .rpc('shop_follower_count', params: {'target_shop_id': shopId});
    return (count as num?)?.toInt() ?? 0;
  }

  Future<List<HomeBanner>> fetchActiveBanners({String? categoryId}) async {
    var query = _client.from('home_banners').select().eq('is_visible', true);
    if (categoryId == null) {
      query = query.filter('category_id', 'is', null);
    } else {
      query = query.eq('category_id', categoryId);
    }
    final rows = await query.order('sort_order');
    return rows.map((r) => HomeBanner.fromMap(r)).toList();
  }

  Future<List<Product>> fetchDiscountedProducts({int limit = 12}) async {
    final rows = await _client
        .from('products')
        .select(_productSelect)
        .eq('is_visible', true)
        .not('compare_at_price', 'is', null)
        .order('created_at', ascending: false)
        .limit(limit * 2);
    return rows
        .map((r) => Product.fromMap(r))
        .where((p) => p.isOnSale)
        .take(limit)
        .toList();
  }

  Future<AppSettings> fetchAppSettings() async {
    final row =
        await _client.from('app_settings').select().eq('id', 1).maybeSingle();
    return row == null ? AppSettings() : AppSettings.fromMap(row);
  }

  Future<int> fetchShopProductCount(String shopId) async {
    final rows = await _client
        .from('products')
        .select('id')
        .eq('shop_id', shopId)
        .eq('is_visible', true);
    return rows.length;
  }

  Future<void> recordShopVisit(String shopId) async {
    try {
      await _client
          .rpc('record_shop_visit', params: {'target_shop_id': shopId});
    } catch (_) {}
  }

  Future<List<HomeCollection>> fetchHomeCollections() async {
    final rows = await _client
        .from('home_collections')
        .select()
        .eq('is_visible', true)
        .order('sort_order');
    return rows.map((r) => HomeCollection.fromMap(r)).toList();
  }

  Future<List<Product>> fetchCollectionProducts(
      {String? categoryId, required int limit}) async {
    var query =
        _client.from('products').select(_productSelect).eq('is_visible', true);
    if (categoryId != null) query = query.eq('category_id', categoryId);
    final rows = await query.order('created_at', ascending: false).limit(limit);
    return rows.map((r) => Product.fromMap(r)).toList();
  }
}
