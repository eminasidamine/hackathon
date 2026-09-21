library models;

class AppSettings {
  final String? contactPhone;
  final String? websiteUrl;

  AppSettings({this.contactPhone, this.websiteUrl});

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      contactPhone: map['contact_phone'] as String?,
      websiteUrl: map['website_url'] as String?,
    );
  }
}

class Profile {
  final String id;
  final String? email;
  final String? fullName;
  final String? phone;
  final String? city;
  final String? address;
  final String? avatarUrl;
  final String role;
  final String? gender;

  Profile({
    required this.id,
    this.email,
    this.fullName,
    this.phone,
    this.city,
    this.address,
    this.avatarUrl,
    this.role = 'client',
    this.gender,
  });

  bool get isVendor => role == 'vendor';
  bool get isAdmin => role == 'admin';

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
        id: map['id'] as String,
        email: map['email'] as String?,
        fullName: map['full_name'] as String?,
        phone: map['phone'] as String?,
        city: map['city'] as String?,
        address: map['address'] as String?,
        avatarUrl: map['avatar_url'] as String?,
        role: (map['role'] as String?) ?? 'client',
        gender: map['gender'] as String?,
      );
}

class Shop {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? coverUrl;
  final String? city;
  final String? whatsappPhone;

  final String? merchantCode;
  final String? merchantProvider;

  final double? lat;
  final double? lng;
  final bool isVisible;

  final DateTime? createdAt;
  final bool? womenLed;

  Shop({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.logoUrl,
    this.coverUrl,
    this.city,
    this.whatsappPhone,
    this.merchantCode,
    this.merchantProvider,
    this.lat,
    this.lng,
    this.isVisible = false,
    this.createdAt,
    this.womenLed,
  });

  factory Shop.fromMap(Map<String, dynamic> map) => Shop(
        id: map['id'] as String,
        ownerId: map['owner_id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        logoUrl: map['logo_url'] as String?,
        coverUrl: map['cover_url'] as String?,
        city: map['city'] as String?,
        whatsappPhone: map['whatsapp_phone'] as String?,
        merchantCode: map['merchant_code'] as String?,
        merchantProvider: map['merchant_provider'] as String?,
        lat: (map['lat'] as num?)?.toDouble(),
        lng: (map['lng'] as num?)?.toDouble(),
        isVisible: (map['is_visible'] as bool?) ?? false,
        createdAt: map['created_at'] != null
            ? DateTime.tryParse(map['created_at'] as String)
            : null,
        womenLed: map['women_led'] as bool?,
      );
}

const double kCategoryImageAspectRatio = 1920 / 480;

class Category {
  final String id;
  final String? parentId;
  final String name;
  final String? imageUrl;
  final int sortOrder;
  final bool isVisible;

  final double focalX;
  final double focalY;
  final double zoom;

  final String gender;

  Category({
    required this.id,
    this.parentId,
    required this.name,
    this.imageUrl,
    this.sortOrder = 0,
    this.isVisible = true,
    this.focalX = 0.5,
    this.focalY = 0.5,
    this.zoom = 1.0,
    this.gender = '*',
  });

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'] as String,
        parentId: map['parent_id'] as String?,
        name: map['name'] as String,
        imageUrl: map['image_url'] as String?,
        sortOrder: (map['sort_order'] as int?) ?? 0,
        isVisible: (map['is_visible'] as bool?) ?? true,
        focalX: (map['focal_x'] as num?)?.toDouble() ?? 0.5,
        focalY: (map['focal_y'] as num?)?.toDouble() ?? 0.5,
        zoom: (map['zoom'] as num?)?.toDouble() ?? 1.0,
        gender: (map['gender'] as String?) ?? '*',
      );
}

class Product {
  final String id;
  final String shopId;
  final String? categoryId;
  final String name;
  final String? description;
  final double price;
  final double? compareAtPrice;
  final int stock;
  final bool isVisible;
  final List<String> imageUrls;
  final String? shopName;
  final String? shopLogoUrl;

  final DateTime? createdAt;

  final String? brand;

  final String? optionName;
  final List<String> optionValues;

  final String optionType;
  final List<String> optionColors;
  final List<bool> optionSoldOut;

  final List<double> imageFocalX;
  final List<double> imageFocalY;

  final List<double> imageZoom;

  Product({
    required this.id,
    required this.shopId,
    this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.compareAtPrice,
    this.stock = 0,
    this.isVisible = true,
    this.imageUrls = const [],
    this.shopName,
    this.shopLogoUrl,
    this.createdAt,
    this.optionName,
    this.optionValues = const [],
    this.optionType = 'text',
    this.optionColors = const [],
    this.optionSoldOut = const [],
    this.brand,
    this.imageFocalX = const [],
    this.imageFocalY = const [],
    this.imageZoom = const [],
  });

  String? get coverImage => imageUrls.isNotEmpty ? imageUrls.first : null;

  double focalXAt(int index) =>
      (index >= 0 && index < imageFocalX.length) ? imageFocalX[index] : 0.5;
  double focalYAt(int index) =>
      (index >= 0 && index < imageFocalY.length) ? imageFocalY[index] : 0.5;
  double zoomAt(int index) =>
      (index >= 0 && index < imageZoom.length) ? imageZoom[index] : 1.0;

  String get brandLine =>
      (brand != null && brand!.trim().isNotEmpty) ? brand! : (shopName ?? '');

  bool get isOnSale => compareAtPrice != null && compareAtPrice! > price;

  int get discountPercent => isOnSale
      ? (((compareAtPrice! - price) / compareAtPrice!) * 100).round()
      : 0;

  bool get isNew =>
      createdAt != null && DateTime.now().difference(createdAt!).inDays <= 14;

  bool get hasOptions {
    final named = optionName != null && optionName!.trim().isNotEmpty;
    if (!named) return false;
    if (optionType == 'color') return optionColors.isNotEmpty;
    return optionValues.isNotEmpty;
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    final imagesRaw = map['product_images'] as List<dynamic>?;

    final sortedImages = (imagesRaw ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList()
      ..sort((a, b) => ((a['sort_order'] as int?) ?? 0)
          .compareTo((b['sort_order'] as int?) ?? 0));
    final images = sortedImages.map((e) => e['url'] as String).toList();
    final focalXs = sortedImages
        .map((e) => (e['focal_x'] as num?)?.toDouble() ?? 0.5)
        .toList();
    final focalYs = sortedImages
        .map((e) => (e['focal_y'] as num?)?.toDouble() ?? 0.5)
        .toList();
    final zooms = sortedImages
        .map((e) => (e['zoom'] as num?)?.toDouble() ?? 1.0)
        .toList();
    final shop = map['shops'] as Map<String, dynamic>?;
    final compareAt = map['compare_at_price'];
    final optionValuesRaw = map['option_values'] as List<dynamic>?;
    return Product(
      id: map['id'] as String,
      shopId: map['shop_id'] as String,
      categoryId: map['category_id'] as String?,
      name: map['name'] as String,
      description: map['description'] as String?,
      price: (map['price'] as num).toDouble(),
      compareAtPrice: compareAt == null ? null : (compareAt as num).toDouble(),
      stock: (map['stock'] as int?) ?? 0,
      isVisible: (map['is_visible'] as bool?) ?? true,
      imageUrls: images,
      imageFocalX: focalXs,
      imageFocalY: focalYs,
      imageZoom: zooms,
      shopName: shop != null ? shop['name'] as String? : null,
      shopLogoUrl: shop != null ? shop['logo_url'] as String? : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      optionName: map['option_name'] as String?,
      optionValues: (optionValuesRaw ?? []).map((e) => e as String).toList(),
      optionType: (map['option_type'] as String?) ?? 'text',
      optionColors: ((map['option_colors'] as List<dynamic>?) ?? [])
          .map((e) => e as String)
          .toList(),
      optionSoldOut: ((map['option_sold_out'] as List<dynamic>?) ?? [])
          .map((e) => e == true)
          .toList(),
      brand: map['brand'] as String?,
    );
  }
}

class ProductImage {
  final String id;
  final String url;
  final int sortOrder;

  final double focalX;
  final double focalY;

  final double zoom;

  ProductImage({
    required this.id,
    required this.url,
    this.sortOrder = 0,
    this.focalX = 0.5,
    this.focalY = 0.5,
    this.zoom = 1.0,
  });

  factory ProductImage.fromMap(Map<String, dynamic> map) => ProductImage(
        id: map['id'] as String,
        url: map['url'] as String,
        sortOrder: (map['sort_order'] as int?) ?? 0,
        focalX: (map['focal_x'] as num?)?.toDouble() ?? 0.5,
        focalY: (map['focal_y'] as num?)?.toDouble() ?? 0.5,
        zoom: (map['zoom'] as num?)?.toDouble() ?? 1.0,
      );
}

class HomeCollection {
  final String id;
  final String imageUrl;
  final String title;
  final String? subtitle;
  final String? categoryId;
  final String? categoryName;
  final int productLimit;
  final int sortOrder;
  final bool isVisible;

  HomeCollection({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.categoryId,
    this.categoryName,
    this.productLimit = 8,
    this.sortOrder = 0,
    this.isVisible = true,
  });

  factory HomeCollection.fromMap(Map<String, dynamic> map) {
    final category = map['categories'] as Map<String, dynamic>?;
    return HomeCollection(
      id: map['id'] as String,
      imageUrl: map['image_url'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String?,
      categoryId: map['category_id'] as String?,
      categoryName: category != null ? category['name'] as String? : null,
      productLimit: (map['product_limit'] as int?) ?? 8,
      sortOrder: (map['sort_order'] as int?) ?? 0,
      isVisible: (map['is_visible'] as bool?) ?? true,
    );
  }
}

class CartLine {
  final Product product;
  int quantity;

  final String? selectedOption;

  CartLine({required this.product, this.quantity = 1, this.selectedOption});

  double get subtotal => product.price * quantity;

  String get cartKey =>
      selectedOption == null ? product.id : '${product.id}::$selectedOption';
}

class OrderModel {
  final String id;
  final String shopId;
  final String status;
  final double total;
  final DateTime createdAt;
  final String? shopName;

  final String clientFullName;
  final String clientPhone;
  final String? clientCity;
  final String? clientAddress;
  final String? paymentProofUrl;

  final String? paymentReference;
  final double? deliveryLat;
  final double? deliveryLng;

  final String deliveryMode;

  final String paymentStatus;
  final String? paymentProvider;
  final DateTime? paymentVerifiedAt;
  final double? paymentAmountReceived;

  OrderModel({
    required this.id,
    required this.shopId,
    required this.status,
    required this.total,
    required this.createdAt,
    this.shopName,
    this.clientFullName = '',
    this.clientPhone = '',
    this.clientCity,
    this.clientAddress,
    this.paymentProofUrl,
    this.paymentReference,
    this.deliveryLat,
    this.deliveryLng,
    this.deliveryMode = 'pickup',
    this.paymentStatus = 'submitted',
    this.paymentProvider,
    this.paymentVerifiedAt,
    this.paymentAmountReceived,
  });

  bool get isDelivery => deliveryMode == 'delivery';

  String? get deliveryMapUrl => deliveryLat == null || deliveryLng == null
      ? null
      : 'https://www.google.com/maps/search/?api=1&query=$deliveryLat,$deliveryLng';

  bool get isPaymentVerified => paymentStatus == 'verified';
  bool get isPaymentRejected => paymentStatus == 'rejected';

  double? get paymentGap =>
      paymentAmountReceived == null ? null : paymentAmountReceived! - total;

  bool get hasPaymentGap {
    final gap = paymentGap;
    return gap != null && gap.abs() > 1;
  }

  String get paymentLabel => switch (paymentStatus) {
        'verified' => 'Payment confirmed',
        'rejected' => 'Reference not found',
        _ => 'Reference submitted — pending verification',
      };

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    final shop = map['shops'] as Map<String, dynamic>?;
    return OrderModel(
      id: map['id'] as String,
      shopId: map['shop_id'] as String,
      status: map['status'] as String,
      total: (map['total'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      shopName: shop != null ? shop['name'] as String? : null,
      clientFullName: (map['client_full_name'] as String?) ?? '',
      clientPhone: (map['client_phone'] as String?) ?? '',
      clientCity: map['client_city'] as String?,
      clientAddress: map['client_address'] as String?,
      paymentProofUrl: map['payment_proof_url'] as String?,
      paymentReference: map['payment_reference'] as String?,
      deliveryLat: (map['delivery_lat'] as num?)?.toDouble(),
      deliveryLng: (map['delivery_lng'] as num?)?.toDouble(),
      deliveryMode: (map['delivery_mode'] as String?) ?? 'pickup',
      paymentStatus: (map['payment_status'] as String?) ?? 'submitted',
      paymentProvider: map['payment_provider'] as String?,
      paymentVerifiedAt: map['payment_verified_at'] != null
          ? DateTime.tryParse(map['payment_verified_at'] as String)
          : null,
      paymentAmountReceived:
          (map['payment_amount_received'] as num?)?.toDouble(),
    );
  }
}

class OrderItemModel {
  final String id;
  final String? productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double subtotal;

  OrderItemModel({
    required this.id,
    this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) => OrderItemModel(
        id: map['id'] as String,
        productId: map['product_id'] as String?,
        productName: map['product_name'] as String,
        unitPrice: (map['unit_price'] as num).toDouble(),
        quantity: map['quantity'] as int,
        subtotal: (map['subtotal'] as num).toDouble(),
      );
}

class VendorApplication {
  final String id;
  final String applicantId;
  final String shopName;
  final String? description;
  final String phone;
  final String? city;
  final String status;
  final DateTime createdAt;
  final String? applicantName;
  final String? applicantEmail;

  VendorApplication({
    required this.id,
    required this.applicantId,
    required this.shopName,
    this.description,
    required this.phone,
    this.city,
    this.status = 'pending',
    required this.createdAt,
    this.applicantName,
    this.applicantEmail,
  });

  factory VendorApplication.fromMap(Map<String, dynamic> map) {
    final applicant = map['profiles'] as Map<String, dynamic>?;
    return VendorApplication(
      id: map['id'] as String,
      applicantId: map['applicant_id'] as String,
      shopName: map['shop_name'] as String,
      description: map['description'] as String?,
      phone: map['phone'] as String,
      city: map['city'] as String?,
      status: (map['status'] as String?) ?? 'pending',
      createdAt: DateTime.parse(map['created_at'] as String),
      applicantName:
          applicant != null ? applicant['full_name'] as String? : null,
      applicantEmail: applicant != null ? applicant['email'] as String? : null,
    );
  }
}

class HomeBanner {
  final String id;
  final String imageUrl;
  final int sortOrder;
  final bool isVisible;
  final String? categoryId;
  final String? categoryName;

  HomeBanner({
    required this.id,
    required this.imageUrl,
    this.sortOrder = 0,
    this.isVisible = true,
    this.categoryId,
    this.categoryName,
  });

  bool get isHomeBanner => categoryId == null;

  factory HomeBanner.fromMap(Map<String, dynamic> map) {
    final category = map['categories'] as Map<String, dynamic>?;
    return HomeBanner(
      id: map['id'] as String,
      imageUrl: map['image_url'] as String,
      sortOrder: (map['sort_order'] as int?) ?? 0,
      isVisible: (map['is_visible'] as bool?) ?? true,
      categoryId: map['category_id'] as String?,
      categoryName: category != null ? category['name'] as String? : null,
    );
  }
}

class Review {
  final String id;
  final String productId;
  final String clientId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String? authorName;

  Review({
    required this.id,
    required this.productId,
    required this.clientId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.authorName,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    final author =
        (map['review_authors'] ?? map['profiles']) as Map<String, dynamic>?;
    return Review(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      clientId: map['client_id'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      authorName: author != null ? author['full_name'] as String? : null,
    );
  }
}

class AppNotification {
  final String id;
  final String kind;
  final String title;
  final String? body;
  final String? orderId;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    this.body,
    this.orderId,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) => AppNotification(
        id: map['id'] as String,
        kind: (map['kind'] as String?) ?? '',
        title: (map['title'] as String?) ?? '',
        body: map['body'] as String?,
        orderId: map['order_id'] as String?,
        isRead: (map['is_read'] as bool?) ?? false,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

class DriverProfile {
  final String id;
  final String? vehicleType;
  final bool isAvailable;

  final String status;

  DriverProfile(
      {required this.id,
      this.vehicleType,
      this.isAvailable = false,
      this.status = 'pending'});

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  factory DriverProfile.fromMap(Map<String, dynamic> map) => DriverProfile(
        id: map['id'] as String,
        vehicleType: map['vehicle_type'] as String?,
        isAvailable: (map['is_available'] as bool?) ?? false,
        status: (map['status'] as String?) ?? 'pending',
      );
}

class DeliveryRequest {
  final String id;
  final String orderId;
  final String shopId;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final double? distanceKm;
  final String status;
  final String? driverId;
  final DateTime createdAt;

  final String? shopName;
  final String? shopCity;
  final double? orderTotal;

  DeliveryRequest({
    required this.id,
    required this.orderId,
    required this.shopId,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    this.distanceKm,
    this.status = 'pending',
    this.driverId,
    required this.createdAt,
    this.shopName,
    this.shopCity,
    this.orderTotal,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDelivered => status == 'delivered';

  String? get deliveryMapUrl => dropoffLat == null || dropoffLng == null
      ? null
      : 'https://www.google.com/maps/search/?api=1&query=$dropoffLat,$dropoffLng';

  factory DeliveryRequest.fromMap(Map<String, dynamic> map) => DeliveryRequest(
        id: map['id'] as String,
        orderId: map['order_id'] as String,
        shopId: map['shop_id'] as String,
        pickupLat: (map['pickup_lat'] as num?)?.toDouble(),
        pickupLng: (map['pickup_lng'] as num?)?.toDouble(),
        dropoffLat: (map['dropoff_lat'] as num?)?.toDouble(),
        dropoffLng: (map['dropoff_lng'] as num?)?.toDouble(),
        distanceKm: (map['distance_km'] as num?)?.toDouble(),
        status: (map['status'] as String?) ?? 'pending',
        driverId: map['driver_id'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
        shopName:
            (map['shops'] is Map) ? (map['shops']['name'] as String?) : null,
        shopCity:
            (map['shops'] is Map) ? (map['shops']['city'] as String?) : null,
        orderTotal: (map['orders'] is Map)
            ? ((map['orders']['total'] as num?)?.toDouble())
            : null,
      );
}

class DeliveryContact {
  final String fullName;
  final String phone;
  final String? address;
  final String? city;

  DeliveryContact(
      {required this.fullName, required this.phone, this.address, this.city});

  factory DeliveryContact.fromMap(Map<String, dynamic> map) => DeliveryContact(
        fullName: (map['client_full_name'] as String?) ?? '',
        phone: (map['client_phone'] as String?) ?? '',
        address: map['client_address'] as String?,
        city: map['client_city'] as String?,
      );
}
