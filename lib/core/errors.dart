import 'package:supabase_flutter/supabase_flutter.dart';

/// Turns a caught error into text safe to show a user — never the raw
/// database/driver internals (table names, SQL codes, "PostgreSQL").
/// Pass [t] (from SettingsController) to get the message in the user's
/// language; without it, the message falls back to English.
String friendlyError(Object error, [String Function(String)? t]) {
  String tr(String key, String fallback) => t == null ? fallback : t(key);
  if (error is PostgrestException) {
    final code = error.code;
    final lower = error.message.toLowerCase();
    final isPermission = code == '42501' ||
        lower.contains('permission denied') ||
        lower.contains('row-level security');
    if (isPermission) {
      return tr('error_no_permission',
          "You don't have the rights to do this with your account type.");
    }
    // Our own RAISE EXCEPTION business messages are already human-readable.
    if (code == 'P0001') return error.message;
    return tr('error_generic_short', 'Something went wrong. Please try again.');
  }
  if (error is AuthException) return error.message;
  return error.toString().replaceFirst('Exception: ', '');
}
