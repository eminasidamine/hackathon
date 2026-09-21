import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class AdminShopRow {
  final Shop shop;
  final String? ownerName;
  final String? ownerEmail;

  AdminShopRow({required this.shop, this.ownerName, this.ownerEmail});

  factory AdminShopRow.fromMap(Map<String, dynamic> map) {
    final owner = map['profiles'] as Map<String, dynamic>?;
    return AdminShopRow(
      shop: Shop.fromMap(map),
      ownerName: owner != null ? owner['full_name'] as String? : null,
      ownerEmail: owner != null ? owner['email'] as String? : null,
    );
  }
}

class AdminService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Category>> fetchCategories() async {
    final rows = await _client.from('categories').select().order('sort_order');
    return rows.map((r) => Category.fromMap(r)).toList();
  }

  Future<void> createCategory({
    required String name,
    String? imageUrl,
    double focalX = 0.5,
    double focalY = 0.5,
    double zoom = 1.0,
    String gender = '*',
  }) async {
    final current = await fetchCategories();
    final nextOrder = current.isEmpty
        ? 0
        : current.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    await _client.from('categories').insert({
      'name': name,
      'parent_id': null,
      'image_url': imageUrl,
      'sort_order': nextOrder,
      'focal_x': focalX,
      'focal_y': focalY,
      'zoom': zoom,
      'gender': gender,
    });
  }

  Future<void> setCategoryGender(String id, String gender) async {
    await _client.from('categories').update({'gender': gender}).eq('id', id);
  }

  Future<void> swapCategoryOrder(Category a, Category b) async {
    await _client
        .from('categories')
        .update({'sort_order': b.sortOrder}).eq('id', a.id);
    await _client
        .from('categories')
        .update({'sort_order': a.sortOrder}).eq('id', b.id);
  }

  Future<void> renameCategory(String id, String name) async {
    await _client.from('categories').update({'name': name}).eq('id', id);
  }

  Future<void> setCategoryImage(String id, String imageUrl,
      {double focalX = 0.5, double focalY = 0.5, double zoom = 1.0}) async {
    await _client.from('categories').update({
      'image_url': imageUrl,
      'focal_x': focalX,
      'focal_y': focalY,
      'zoom': zoom,
    }).eq('id', id);
  }

  Future<void> updateCategoryImagePosition({
    required String id,
    required double focalX,
    required double focalY,
    required double zoom,
  }) async {
    await _client.from('categories').update(
        {'focal_x': focalX, 'focal_y': focalY, 'zoom': zoom}).eq('id', id);
  }

  Future<void> setCategoryVisible(String id, bool visible) async {
    await _client
        .from('categories')
        .update({'is_visible': visible}).eq('id', id);
  }

  Future<List<Category>> fetchAllCategoriesFlat() => fetchCategories();

  Future<void> deleteCategory(String id) async {
    await _client.from('categories').delete().eq('id', id);
  }

  Future<List<AdminShopRow>> fetchAllShops() async {
    final shopRows = await _client
        .from('shops')
        .select()
        .order('is_visible', ascending: true)
        .order('created_at', ascending: false);
    final shops = shopRows.map((r) => Shop.fromMap(r)).toList();
    if (shops.isEmpty) return [];

    final ownerIds = shops.map((s) => s.ownerId).toSet().toList();
    final profileRows = await _client
        .from('profiles')
        .select('id, full_name, email')
        .inFilter('id', ownerIds);
    final profileById = {for (final p in profileRows) p['id'] as String: p};

    return shops.map((s) {
      final owner = profileById[s.ownerId];
      return AdminShopRow(
        shop: s,
        ownerName: owner != null ? owner['full_name'] as String? : null,
        ownerEmail: owner != null ? owner['email'] as String? : null,
      );
    }).toList();
  }

  Future<void> setShopVisible(String id, bool visible) async {
    await _client.from('shops').update({'is_visible': visible}).eq('id', id);
  }

  Future<void> deleteShop(String id) async {
    await _client.from('shops').delete().eq('id', id);
  }

  Future<void> createShop({
    required String ownerId,
    required String name,
    String? city,
    String? whatsappPhone,
    String? description,
    bool isVisible = true,
  }) async {
    await _client.from('shops').insert({
      'owner_id': ownerId,
      'name': name,
      'city': city,
      'whatsapp_phone': whatsappPhone,
      'description': description,
      'is_visible': isVisible,
    });
  }

  Future<List<Profile>> fetchProfiles({String? search}) async {
    var query = _client.from('profiles').select();
    if (search != null && search.isNotEmpty) {
      query = query.or('full_name.ilike.%$search%,email.ilike.%$search%');
    }
    final rows = await query.order('created_at', ascending: false).limit(50);
    return rows.map((r) => Profile.fromMap(r)).toList();
  }

  static const String _productSelect =
      'id, shop_id, category_id, name, description, price, compare_at_price, stock, is_visible, '
      'brand, product_images(url, sort_order, focal_x, focal_y, zoom), shops(id, name, logo_url, is_visible)';

  Future<List<Product>> fetchAllProducts(
      {String? shopId, String? search}) async {
    var query = _client.from('products').select(_productSelect);
    if (shopId != null) query = query.eq('shop_id', shopId);
    if (search != null && search.isNotEmpty)
      query = query.ilike('name', '%$search%');
    final rows = await query.order('created_at', ascending: false).limit(200);
    return rows.map((r) => Product.fromMap(r)).toList();
  }

  Future<String> createProduct({
    required String shopId,
    String? categoryId,
    required String name,
    String? description,
    required double price,
    double? compareAtPrice,
    int stock = 0,
    bool isVisible = true,
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
          'is_visible': isVisible,
          'brand': brand,
        })
        .select()
        .single();
    return row['id'] as String;
  }

  Future<void> updateProduct({
    required String id,
    String? name,
    String? description,
    double? price,
    double? compareAtPrice,
    bool clearCompareAtPrice = false,
    int? stock,
    String? categoryId,
    String? brand,
  }) async {
    await _client.from('products').update({
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (compareAtPrice != null) 'compare_at_price': compareAtPrice,
      if (clearCompareAtPrice) 'compare_at_price': null,
      if (stock != null) 'stock': stock,
      if (categoryId != null) 'category_id': categoryId,
      if (brand != null) 'brand': brand.isEmpty ? null : brand,
    }).eq('id', id);
  }

  Future<void> setProductVisible(String id, bool visible) async {
    await _client.from('products').update({'is_visible': visible}).eq('id', id);
  }

  Future<void> deleteProduct(String id) async {
    await _client.from('products').delete().eq('id', id);
  }

  Future<void> addProductImage(
      {required String productId,
      required String url,
      int sortOrder = 0}) async {
    await _client
        .from('product_images')
        .insert({'product_id': productId, 'url': url, 'sort_order': sortOrder});
  }

  Future<AppSettings> fetchAppSettings() async {
    final row =
        await _client.from('app_settings').select().eq('id', 1).maybeSingle();
    return row == null ? AppSettings() : AppSettings.fromMap(row);
  }

  Future<void> updateAppSettings(
      {String? contactPhone, String? websiteUrl}) async {
    await _client.from('app_settings').update({
      'contact_phone': contactPhone,
      'website_url': websiteUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', 1);
  }

  Future<List<VendorApplication>> fetchVendorApplications(
      {String? status}) async {
    var query = _client
        .from('vendor_applications')
        .select('*, profiles(full_name, email)');
    if (status != null) query = query.eq('status', status);
    final rows = await query.order('created_at', ascending: false);
    return rows.map((r) => VendorApplication.fromMap(r)).toList();
  }

  Future<void> approveVendorApplication(VendorApplication application) async {
    await createShop(
      ownerId: application.applicantId,
      name: application.shopName,
      city: application.city,
      whatsappPhone: application.phone,
      description: application.description,
      isVisible: true,
    );

    await _client
        .from('profiles')
        .update({'role': 'vendor'}).eq('id', application.applicantId);
    await _client.from('vendor_applications').update({
      'status': 'approved',
      'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', application.id);
  }

  Future<void> rejectVendorApplication(String id) async {
    await _client.from('vendor_applications').update({
      'status': 'rejected',
      'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  static const int maxBanners = 5;

  Future<List<HomeBanner>> fetchBanners({String? categoryId}) async {
    var query = _client.from('home_banners').select('*, categories(name)');
    if (categoryId == null) {
      query = query.filter('category_id', 'is', null);
    } else {
      query = query.eq('category_id', categoryId);
    }
    final rows = await query.order('sort_order');
    return rows.map((r) => HomeBanner.fromMap(r)).toList();
  }

  Future<void> addBanner(String imageUrl, {String? categoryId}) async {
    final current = await fetchBanners(categoryId: categoryId);
    if (current.length >= maxBanners) {
      throw Exception(
          'Maximum $maxBanners photos pour cet emplacement — supprime-en une avant d\'en ajouter une nouvelle.');
    }
    final nextOrder = current.isEmpty
        ? 0
        : current.map((b) => b.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    await _client.from('home_banners').insert({
      'image_url': imageUrl,
      'sort_order': nextOrder,
      'category_id': categoryId
    });
  }

  Future<void> setBannerVisible(String id, bool visible) async {
    await _client
        .from('home_banners')
        .update({'is_visible': visible}).eq('id', id);
  }

  Future<void> deleteBanner(String id) async {
    await _client.from('home_banners').delete().eq('id', id);
  }

  Future<void> swapBannerOrder(HomeBanner a, HomeBanner b) async {
    await _client
        .from('home_banners')
        .update({'sort_order': b.sortOrder}).eq('id', a.id);
    await _client
        .from('home_banners')
        .update({'sort_order': a.sortOrder}).eq('id', b.id);
  }

  Future<List<HomeCollection>> fetchCollections() async {
    final rows = await _client
        .from('home_collections')
        .select('*, categories(name)')
        .order('sort_order');
    return rows.map((r) => HomeCollection.fromMap(r)).toList();
  }

  Future<void> createCollection({
    required String imageUrl,
    required String title,
    String? subtitle,
    String? categoryId,
    int productLimit = 8,
  }) async {
    final current = await fetchCollections();
    final nextOrder = current.isEmpty
        ? 0
        : current.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    await _client.from('home_collections').insert({
      'image_url': imageUrl,
      'title': title,
      'subtitle': subtitle,
      'category_id': categoryId,
      'product_limit': productLimit,
      'sort_order': nextOrder,
    });
  }

  Future<void> updateCollection({
    required String id,
    String? imageUrl,
    String? title,
    String? subtitle,
    bool clearSubtitle = false,
    String? categoryId,
    bool clearCategoryId = false,
    int? productLimit,
  }) async {
    await _client.from('home_collections').update({
      if (imageUrl != null) 'image_url': imageUrl,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (clearSubtitle) 'subtitle': null,
      if (categoryId != null) 'category_id': categoryId,
      if (clearCategoryId) 'category_id': null,
      if (productLimit != null) 'product_limit': productLimit,
    }).eq('id', id);
  }

  Future<void> setCollectionVisible(String id, bool visible) async {
    await _client
        .from('home_collections')
        .update({'is_visible': visible}).eq('id', id);
  }

  Future<void> deleteCollection(String id) async {
    await _client.from('home_collections').delete().eq('id', id);
  }

  Future<void> swapCollectionOrder(HomeCollection a, HomeCollection b) async {
    await _client
        .from('home_collections')
        .update({'sort_order': b.sortOrder}).eq('id', a.id);
    await _client
        .from('home_collections')
        .update({'sort_order': a.sortOrder}).eq('id', b.id);
  }

  Future<List<OrderModel>> fetchOrders({String? status}) async {
    var query = _client.from('orders').select('*, shops(name)');
    if (status != null) query = query.eq('status', status);
    final rows = await query.order('created_at', ascending: false).limit(300);
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
}
