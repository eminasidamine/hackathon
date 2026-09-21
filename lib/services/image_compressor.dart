import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageCompressor {
  static const int maxWidth = 1200;
  static const int quality = 82;

  static const int thumbWidth = 500;
  static const int thumbQuality = 78;

  static const String thumbSuffix = '_thumb';

  static const int _skipUnderBytes = 60 * 1024;

  static PreparedImage prepare(Uint8List bytes, String fileName) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        return PreparedImage(bytes: bytes, fileName: fileName, changed: false);
      }

      final base = fileName.contains('.')
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;

      final large = decoded.width > maxWidth
          ? img.copyResize(decoded,
              width: maxWidth, interpolation: img.Interpolation.average)
          : decoded;
      var mainBytes =
          Uint8List.fromList(img.encodeJpg(large, quality: quality));
      var mainName = '$base.jpg';

      final keepOriginal =
          mainBytes.length >= bytes.length && bytes.length <= _skipUnderBytes;
      if (keepOriginal) {
        mainBytes = bytes;
        mainName = fileName;
      }

      final small = decoded.width > thumbWidth
          ? img.copyResize(decoded,
              width: thumbWidth, interpolation: img.Interpolation.average)
          : decoded;
      final thumbBytes =
          Uint8List.fromList(img.encodeJpg(small, quality: thumbQuality));

      return PreparedImage(
        bytes: mainBytes,
        fileName: mainName,
        changed: !keepOriginal,
        thumbBytes: thumbBytes,
        thumbFileName: '$base$thumbSuffix.jpg',
      );
    } catch (_) {
      return PreparedImage(bytes: bytes, fileName: fileName, changed: false);
    }
  }

  static String? thumbUrlFor(String url) {
    final cut = url.lastIndexOf('.');
    if (cut <= 0 || url.length - cut > 6) return null;
    if (url.substring(0, cut).endsWith(thumbSuffix)) return url;
    return '${url.substring(0, cut)}$thumbSuffix.jpg';
  }
}

class PreparedImage {
  final Uint8List bytes;
  final String fileName;
  final bool changed;
  final Uint8List? thumbBytes;
  final String? thumbFileName;

  const PreparedImage({
    required this.bytes,
    required this.fileName,
    required this.changed,
    this.thumbBytes,
    this.thumbFileName,
  });
}
