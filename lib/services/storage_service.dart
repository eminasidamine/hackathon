import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_config.dart';
import 'image_compressor.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;

  String publicUrl(String bucket, String path) {
    if (AppConfig.useR2 && AppConfig.r2PublicBaseUrl.isNotEmpty) {
      return '${AppConfig.r2PublicBaseUrl}/$path';
    }
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  String ownedPath(String fileName) {
    final uid = _client.auth.currentUser?.id;
    return uid == null ? fileName : '$uid/$fileName';
  }

  Future<String> uploadPublic({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    final prepared = ImageCompressor.prepare(bytes, path);

    await _client.storage.from(bucket).uploadBinary(
          prepared.fileName,
          prepared.bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: prepared.changed ? 'image/jpeg' : contentType,
          ),
        );

    if (prepared.thumbBytes != null && prepared.thumbFileName != null) {
      try {
        await _client.storage.from(bucket).uploadBinary(
              prepared.thumbFileName!,
              prepared.thumbBytes!,
              fileOptions:
                  const FileOptions(upsert: true, contentType: 'image/jpeg'),
            );
      } catch (_) {}
    }

    return publicUrl(bucket, prepared.fileName);
  }

  Future<String> uploadPaymentProof({
    required String userId,
    required String orderId,
    required Uint8List bytes,
    String extension = 'jpg',
  }) async {
    final path = '$userId/$orderId.$extension';
    await _client.storage.from('payment-proofs').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return path;
  }

  Future<String> signedPaymentProofUrl(String path,
      {int expiresInSeconds = 3600}) {
    return _client.storage
        .from('payment-proofs')
        .createSignedUrl(path, expiresInSeconds);
  }
}
