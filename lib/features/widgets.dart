import 'dart:async';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../core/errors.dart';
import '../core/money.dart';
import '../core/settings_controller.dart';
import '../core/theme.dart';
import '../services/image_compressor.dart';
import '../services/location_service.dart';
import '../models/models.dart';

const LatLng kMauritaniaCenter = LatLng(20.0, -10.9408);

class MiniMap extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final double height;
  final bool interactive;
  final double zoom;

  const MiniMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 140,
    this.interactive = false,
    this.zoom = 14,
  });

  @override
  Widget build(BuildContext context) {
    final point = (latitude != null && longitude != null)
        ? LatLng(latitude!, longitude!)
        : kMauritaniaCenter;
    final zoomLevel = (latitude != null && longitude != null) ? zoom : 6.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: zoomLevel,
                interactionOptions: InteractionOptions(
                  flags:
                      interactive ? InteractiveFlag.all : InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.marketplace.app',
                ),
                if (latitude != null && longitude != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: point,
                      width: 34,
                      height: 34,
                      child: const Icon(Icons.location_on,
                          color: AppTheme.red, size: 34),
                    ),
                  ]),
              ],
            ),
            Positioned(
              right: 4,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                color: Colors.white70,
                child: const Text('© OpenStreetMap',
                    style: TextStyle(fontSize: 8, color: AppTheme.muted)),
              ),
            ),
            if (latitude == null || longitude == null)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  alignment: Alignment.center,
                  child: const Text(
                    'Location not shared',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AppImage extends StatefulWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? radius;

  final Alignment alignment;

  final double zoom;

  final bool thumbnail;

  const AppImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius,
    this.alignment = Alignment.center,
    this.zoom = 1.0,
    this.thumbnail = false,
  });

  @override
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> {
  Timer? _heartbeat;
  bool _pulse = false;

  @override
  void initState() {
    super.initState();
    _heartbeat = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (!mounted) return;
      setState(() => _pulse = !_pulse);
    });
  }

  @override
  void dispose() {
    _heartbeat?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.url;
    final width = widget.width;
    final height = widget.height;
    final fit = widget.fit;
    final alignment = widget.alignment;
    final zoom = widget.zoom;
    final radius = widget.radius;
    final thumbnail = widget.thumbnail;

    final placeholder = Container(
      width: width,
      height: height,
      color: AppTheme.imageBg,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined,
          color: AppTheme.muted, size: (width ?? 40) * 0.4),
    );

    Widget child;
    if (url == null || url.isEmpty) {
      child = placeholder;
    } else {
      final thumbUrl = thumbnail ? ImageCompressor.thumbUrlFor(url) : null;
      Widget network(String source, {Widget Function()? onError}) =>
          CachedNetworkImage(
            imageUrl: source,
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            placeholder: (_, __) => placeholder,
            errorWidget: (_, __, ___) =>
                onError == null ? placeholder : onError(),
          );
      child = thumbUrl == null || thumbUrl == url
          ? network(url)
          : network(thumbUrl, onError: () => network(url));
    }

    if (zoom != 1.0) {
      child = Transform.scale(scale: zoom, alignment: alignment, child: child);
    }

    if (radius != null) {
      child = ClipRRect(borderRadius: radius, child: child);
    }

    return RepaintBoundary(
      child: Opacity(
        opacity: _pulse ? 0.999 : 1.0,
        child: child,
      ),
    );
  }
}

class PhotoPositionScreen extends StatefulWidget {
  final Uint8List? bytes;
  final String? url;
  final double initialFocalX;
  final double initialFocalY;
  final double initialZoom;
  final double frameAspectRatio;

  const PhotoPositionScreen({
    super.key,
    this.bytes,
    this.url,
    this.initialFocalX = 0.5,
    this.initialFocalY = 0.5,
    this.initialZoom = 1.0,
    this.frameAspectRatio = 0.66,
  });

  static const double minZoom = 1.0;
  static const double maxZoom = 3.0;

  @override
  State<PhotoPositionScreen> createState() => _PhotoPositionScreenState();
}

class _PhotoPositionScreenState extends State<PhotoPositionScreen> {
  late double _focalX = widget.initialFocalX;
  late double _focalY = widget.initialFocalY;
  late double _zoom = widget.initialZoom;
  double _zoomAtGestureStart = 1.0;
  final _frameKey = GlobalKey();

  void _onScaleStart(ScaleStartDetails details) {
    _zoomAtGestureStart = _zoom;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final box = _frameKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || box.size.width == 0 || box.size.height == 0) return;
    setState(() {
      _zoom = (_zoomAtGestureStart * details.scale)
          .clamp(PhotoPositionScreen.minZoom, PhotoPositionScreen.maxZoom);

      _focalX =
          (_focalX - details.focalPointDelta.dx / (box.size.width * _zoom))
              .clamp(0.0, 1.0);
      _focalY =
          (_focalY - details.focalPointDelta.dy / (box.size.height * _zoom))
              .clamp(0.0, 1.0);
    });
  }

  void _reset() => setState(() {
        _focalX = 0.5;
        _focalY = 0.5;
        _zoom = 1.0;
      });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    final alignment = Alignment(_focalX * 2 - 1, _focalY * 2 - 1);
    final rawImage = widget.bytes != null
        ? Image.memory(widget.bytes!, fit: BoxFit.cover, alignment: alignment)
        : AppImage(url: widget.url, fit: BoxFit.cover, alignment: alignment);
    final image = _zoom == 1.0
        ? rawImage
        : Transform.scale(scale: _zoom, alignment: alignment, child: rawImage);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Drag the photo, and pinch with two fingers to zoom in/out, to choose what should always stay visible, whatever card it appears on in the app.",
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: widget.frameAspectRatio,
                  child: ClipRect(
                    key: _frameKey,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white54, width: 1)),
                      child: GestureDetector(
                        onScaleStart: _onScaleStart,
                        onScaleUpdate: _onScaleUpdate,
                        child: image,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 4),
              child: Text(
                t('photo_position_hint'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(t('cancel'),
                        style: const TextStyle(color: Colors.white70)),
                  ),
                  IconButton(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh, color: Colors.white70)),
                  FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop((_focalX, _focalY, _zoom)),
                    child: Text(t('ok_action')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Color> shopGradient(String seed) {
  const palettes = [
    [Color(0xFFF17C6E), Color(0xFFD33A34)],
    [Color(0xFFC9A227), Color(0xFF7C5A12)],
    [Color(0xFF79B7A0), Color(0xFF2E6B57)],
    [Color(0xFF7FA8D9), Color(0xFF2F5B94)],
    [Color(0xFFE5A0B4), Color(0xFFB0577A)],
    [Color(0xFF8E7BC4), Color(0xFF4B3A85)],
    [Color(0xFFF0B67F), Color(0xFFC4731F)],
  ];
  final idx = seed.isEmpty
      ? 0
      : seed.codeUnits.fold<int>(0, (a, b) => a + b) % palettes.length;
  return palettes[idx];
}

String _initials(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
}

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onAdd;

  final bool showShopName;

  final bool leftAlign;

  final bool showSellerHeader;
  final VoidCallback? onOpenShop;

  final double imageAspectRatio;
  final BorderRadius? borderRadius;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.onAdd,
    this.showShopName = true,
    this.leftAlign = false,
    this.showSellerHeader = false,
    this.onOpenShop,
    this.imageAspectRatio = 0.714,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.showSellerHeader &&
              (product.shopName ?? '').isNotEmpty) ...[
            _SellerMiniHeader(
              name: product.shopName!,
              logoUrl: product.shopLogoUrl,
              onTap: widget.onOpenShop,
            ),
            const SizedBox(height: 10),
          ],
          ClipRRect(
            borderRadius: widget.borderRadius ??
                BorderRadius.circular(AppTheme.radiusSmall),
            child: AspectRatio(
              aspectRatio: widget.imageAspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: AppTheme.imageBg),
                  AppImage(
                    url: product.coverImage,
                    fit: BoxFit.cover,
                    thumbnail: true,
                    alignment: Alignment(product.focalXAt(0) * 2 - 1,
                        product.focalYAt(0) * 2 - 1),
                    zoom: product.zoomAt(0),
                  ),
                  if (widget.onToggleFavorite != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _HeartButton(
                          isFavorite: widget.isFavorite,
                          onTap: widget.onToggleFavorite!),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Column(
              crossAxisAlignment: widget.leftAlign
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                if (widget.showShopName &&
                    product.brandLine.isNotEmpty &&
                    (!widget.showSellerHeader ||
                        (product.brand ?? '').isNotEmpty))
                  Text(
                    product.brandLine.toUpperCase(),
                    maxLines: 1,
                    textAlign:
                        widget.leftAlign ? TextAlign.left : TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.productBrand,
                  ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  maxLines: 1,
                  textAlign:
                      widget.leftAlign ? TextAlign.left : TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.productName,
                ),
                const SizedBox(height: 8),
                _PriceRow(product: product, leftAlign: widget.leftAlign),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final Product product;
  final bool leftAlign;

  const _PriceRow({required this.product, this.leftAlign = false});

  @override
  Widget build(BuildContext context) {
    if (!product.isOnSale) {
      return Text(
        Money.format(product.price),
        textAlign: leftAlign ? TextAlign.left : TextAlign.center,
        style: const TextStyle(
            fontSize: 12.5, fontWeight: FontWeight.w500, color: AppTheme.ink),
      );
    }

    return Column(
      crossAxisAlignment:
          leftAlign ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          Money.format(product.compareAtPrice!),
          textAlign: leftAlign ? TextAlign.left : TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 11,
              color: AppTheme.muted,
              decoration: TextDecoration.lineThrough),
        ),
        Text(
          '${Money.format(product.price)} -${product.discountPercent}%',
          textAlign: leftAlign ? TextAlign.left : TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.ink),
        ),
      ],
    );
  }
}

class _HeartButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _HeartButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            isFavorite ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
            size: 20,
            color: isFavorite ? AppTheme.red : const Color(0xFF111111),
          ),
        ),
      ),
    );
  }
}

class ShopAvatar extends StatelessWidget {
  final String name;
  final String? logoUrl;
  final double size;

  const ShopAvatar(
      {super.key, required this.name, this.logoUrl, this.size = 22});

  @override
  Widget build(BuildContext context) {
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return AppImage(
          url: logoUrl,
          width: size,
          height: size,
          thumbnail: true,
          radius: BorderRadius.circular(size / 2));
    }
    final grad = shopGradient(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
            colors: grad, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      alignment: Alignment.center,
      child: Text(_initials(name),
          style: TextStyle(
              fontSize: size * 0.38,
              fontWeight: FontWeight.w700,
              color: Colors.white)),
    );
  }
}

class ProductFeedCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onShopTap;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final double imageAspectRatio;
  final BorderRadius? borderRadius;

  const ProductFeedCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onShopTap,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.imageAspectRatio = 0.714,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  State<ProductFeedCard> createState() => _ProductFeedCardState();
}

class _ProductFeedCardState extends State<ProductFeedCard> {
  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: widget.onShopTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                ShopAvatar(
                    name: product.shopName ?? '', logoUrl: product.shopLogoUrl),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    product.shopName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ink),
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: widget.borderRadius ??
                    BorderRadius.circular(AppTheme.radiusSmall),
                child: AspectRatio(
                  aspectRatio: widget.imageAspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: AppTheme.imageBg),
                      AppImage(
                        url: product.coverImage,
                        fit: BoxFit.cover,
                        thumbnail: true,
                        alignment: Alignment(product.focalXAt(0) * 2 - 1,
                            product.focalYAt(0) * 2 - 1),
                        zoom: product.zoomAt(0),
                      ),
                      if (widget.onToggleFavorite != null)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: _HeartButton(
                              isFavorite: widget.isFavorite,
                              onTap: widget.onToggleFavorite!),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    if (product.brandLine.isNotEmpty) ...[
                      Text(
                        product.brandLine.toUpperCase(),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.productBrand,
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      product.name,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.productName,
                    ),
                    const SizedBox(height: 8),
                    _PriceRow(product: product),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ShopCard extends StatelessWidget {
  final Shop shop;
  final VoidCallback onTap;
  final String? tags;

  const ShopCard(
      {super.key, required this.shop, required this.onTap, this.tags});

  @override
  Widget build(BuildContext context) {
    final grad = shopGradient(shop.name);
    return Material(
      color: AppTheme.panel,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              shop.logoUrl != null && shop.logoUrl!.isNotEmpty
                  ? AppImage(
                      url: shop.logoUrl,
                      width: 58,
                      height: 58,
                      thumbnail: true,
                      radius: BorderRadius.circular(17))
                  : Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        gradient: LinearGradient(
                            colors: grad,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _initials(shop.name),
                        style: AppTheme.brand(size: 20, color: Colors.white),
                      ),
                    ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.25,
                          color: AppTheme.ink),
                    ),
                    if (tags != null && tags!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(tags!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.muted)),
                    ],
                    if (shop.city != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: AppTheme.muted),
                          const SizedBox(width: 3),
                          Text(shop.city!,
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.muted)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellerMiniHeader extends StatelessWidget {
  final String name;
  final String? logoUrl;
  final VoidCallback? onTap;

  const _SellerMiniHeader({required this.name, this.logoUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ShopAvatar(name: name, logoUrl: logoUrl, size: 30),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.ink),
                ),
                Text(
                  'Boutique',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Swatch {
  final String name;
  final String hex;
  const Swatch(this.name, this.hex);
}

const List<Swatch> kSwatchPalette = [
  Swatch('Porcelain', '#F7E7DA'),
  Swatch('Ivory', '#F2DCC8'),
  Swatch('Light beige', '#EBD0B7'),
  Swatch('Beige', '#E2BFA1'),
  Swatch('Sand', '#D9AE8B'),
  Swatch('Honey', '#CE9A73'),
  Swatch('Golden', '#C08A5F'),
  Swatch('Caramel', '#B0764C'),
  Swatch('Hazelnut', '#9C6440'),
  Swatch('Cinnamon', '#8A5334'),
  Swatch('Mocha', '#75432B'),
  Swatch('Chocolate', '#5E3422'),
  Swatch('Espresso', '#4A2819'),
  Swatch('Ebony', '#361C12'),
  Swatch('Pale pink', '#F6D5DA'),
  Swatch('Powder pink', '#EFBFC8'),
  Swatch('Soft pink', '#E8A6B4'),
  Swatch('Bright pink', '#DE8398'),
  Swatch('Indian pink', '#D06A83'),
  Swatch('Fuchsia', '#C44D74'),
  Swatch('Raspberry', '#B03A60'),
  Swatch('Rosy plum', '#96335A'),
  Swatch('Rosy nude', '#D9A79C'),
  Swatch('Beige nude', '#C99483'),
  Swatch('Brown nude', '#B57B66'),
  Swatch('Coral', '#E9705C'),
  Swatch('Light red', '#D9534F'),
  Swatch('Red', '#C62F32'),
  Swatch('Deep red', '#A81F26'),
  Swatch('Burgundy', '#8C1D2C'),
  Swatch('Brick', '#9E4034'),
  Swatch('Terracotta', '#B25A43'),
  Swatch('Rosy brown', '#A5685F'),
  Swatch('Brown', '#7E4A3E'),
  Swatch('Plum', '#6E2D45'),
  Swatch('Aubergine', '#4E2036'),
  Swatch('Champagne', '#E8D3B5'),
  Swatch('Bronze', '#A9743B'),
  Swatch('Copper', '#B5622C'),
  Swatch('Gold', '#D4AF37'),
  Swatch('Silver', '#C0C0C0'),
  Swatch('Taupe', '#8B7B6B'),
  Swatch('Khaki', '#6E6B4A'),
  Swatch('Green', '#2E9C5B'),
  Swatch('Emerald', '#1E7A5A'),
  Swatch('Turquoise', '#00A9A5'),
  Swatch('Sky blue', '#7FB3E3'),
  Swatch('Blue', '#1F4FD8'),
  Swatch('Midnight blue', '#1B2A5B'),
  Swatch('Purple', '#8E44AD'),
  Swatch('Lavender', '#B9A7DA'),
  Swatch('Yellow', '#F2C94C'),
  Swatch('Orange', '#EE6C2B'),
  Swatch('Black', '#000000'),
  Swatch('White', '#FFFFFF'),
  Swatch('Cream', '#F3EDE3'),
  Swatch('Grey', '#8E8E8E'),
  Swatch('Charcoal grey', '#4A4A4A'),
  Swatch('Camel', '#C19A6B'),
  Swatch('Cognac', '#9A5B33'),
  Swatch('Dark burgundy', '#5E1F28'),
  Swatch('Navy', '#1F2A44'),
  Swatch('Nude', '#D8C3AC'),
];

String swatchName(String hex) {
  final clean = hex.toUpperCase();
  for (final s in kSwatchPalette) {
    if (s.hex.toUpperCase() == clean) return s.name;
  }
  return hex;
}

Color hexToColor(String hex) {
  final cleaned = hex.replaceAll('#', '').trim();
  if (cleaned.length != 6) return const Color(0xFFCCCCCC);
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) return const Color(0xFFCCCCCC);
  return Color(0xFF000000 | value);
}

double productGridAspectRatio(double cellWidth,
    {bool withSellerHeader = false, double imageRatio = 0.714}) {
  const textHeight = 90.0;
  const headerHeight = 50.0;
  final height = cellWidth / imageRatio +
      textHeight +
      (withSellerHeader ? headerHeight : 0);
  return cellWidth / height;
}

String shopTenureLabel(DateTime createdAt) {
  final now = DateTime.now();
  var months = (now.year - createdAt.year) * 12 + (now.month - createdAt.month);
  if (now.day < createdAt.day) months -= 1;
  if (months <= 0) return 'less than a month';
  if (months < 12) return months == 1 ? '1 month' : '$months months';
  final years = months ~/ 12;
  final rem = months % 12;
  final yearsLabel = years > 1 ? '$years years' : '1 year';
  if (rem == 0) return yearsLabel;
  return '$yearsLabel $rem ${rem > 1 ? 'months' : 'month'}';
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppTheme.muted),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppTheme.ink),
                textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!,
                  style: const TextStyle(color: AppTheme.muted),
                  textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final String seeAllLabel;
  final String? subtitle;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.seeAllLabel = '',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.45,
                        color: AppTheme.ink)),
                if (subtitle != null)
                  Text(subtitle!,
                      style:
                          const TextStyle(fontSize: 12, color: AppTheme.muted)),
              ],
            ),
          ),
          if (onSeeAll != null)
            InkWell(
              onTap: onSeeAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  seeAllLabel,
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.ink,
                      letterSpacing: 0.6,
                      decoration: TextDecoration.underline),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const StarRating({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.round();
        return Icon(filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size, color: AppTheme.amber);
      }),
    );
  }
}

class OrderStatusChip extends StatelessWidget {
  final String status;
  final String label;

  const OrderStatusChip({super.key, required this.status, required this.label});

  Color _color() {
    switch (status) {
      case 'delivered':
        return const Color(0xFF57BB7E);
      case 'cancelled':
        return AppTheme.red;
      case 'confirmed':
      case 'preparing':
      case 'delivering':
        return AppTheme.stockWarn;
      default:
        return AppTheme.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

class AppSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onCameraTap;
  final Widget? trailing;

  final Color? fillColor;
  final Color? iconColor;
  final Color? hintColor;
  final double height;
  final double radius;
  final double fontSize;
  final double iconSize;
  final bool autofocus;

  const AppSearchField({
    super.key,
    this.controller,
    required this.hint,
    this.onSubmitted,
    this.onChanged,
    this.onCameraTap,
    this.trailing,
    this.fillColor,
    this.iconColor,
    this.hintColor,
    this.height = 46,
    this.radius = 14,
    this.fontSize = 14.5,
    this.iconSize = 19,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: fillColor ?? AppTheme.searchFill,
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Icon(Icons.search,
              size: iconSize, color: iconColor ?? AppTheme.searchPlaceholder),
          const SizedBox(width: 11),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              onChanged: onChanged,
              style: TextStyle(fontSize: fontSize, color: AppTheme.ink),
              decoration: InputDecoration(
                filled: false,
                hintText: hint,
                hintStyle: TextStyle(
                    fontSize: fontSize,
                    color: hintColor ?? AppTheme.searchPlaceholder),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          if (onCameraTap != null) ...[
            const SizedBox(width: 11),
            Container(width: 1, height: 22, color: AppTheme.searchSep),
            const SizedBox(width: 11),
            InkWell(
              onTap: onCameraTap,
              child: const Icon(Icons.camera_alt_outlined,
                  size: 21, color: AppTheme.ink),
            ),
          ],
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class PlaceSearchField extends StatefulWidget {
  final ValueChanged<PlaceResult> onSelected;
  final String hintText;

  const PlaceSearchField({
    super.key,
    required this.onSelected,
    this.hintText = 'Search for an address or place',
  });

  @override
  State<PlaceSearchField> createState() => _PlaceSearchFieldState();
}

class _PlaceSearchFieldState extends State<PlaceSearchField> {
  final _controller = TextEditingController();
  final _location = LocationService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await _location.searchPlaces(query);
      if (!mounted) return;
      setState(() => _loading = false);
      if (results.isEmpty) {
        setState(() => _error = 'No results. Try a more specific address.');
        return;
      }
      final chosen = await showModalBottomSheet<PlaceResult>(
        context: context,
        backgroundColor: AppTheme.card,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => SafeArea(
          top: false,
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: results.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppTheme.hair),
            itemBuilder: (context, i) => ListTile(
              leading: const Icon(Icons.place_outlined, color: AppTheme.ink2),
              title: Text(results[i].label,
                  style: const TextStyle(fontSize: 13.5, color: AppTheme.ink)),
              onTap: () => Navigator.of(context).pop(results[i]),
            ),
          ),
        ),
      );
      if (chosen != null) widget.onSelected(chosen);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = friendlyError(e, context.read<SettingsController>().t);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    onPressed: _search,
                  ),
          ),
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
