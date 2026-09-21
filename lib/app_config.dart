class AppConfig {
  AppConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://TON-PROJET.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'TON-ANON-KEY',
  );

  static const bool useR2 = bool.fromEnvironment('USE_R2', defaultValue: false);

  static const String r2PublicBaseUrl = String.fromEnvironment(
    'R2_PUBLIC_BASE_URL',
    defaultValue: '',
  );

  static const String currencyCode = 'MRU';
  static const String currencySymbol = 'UM';
  static const int pageSize = 20;

  static bool get isConfigured =>
      !supabaseUrl.contains('TON-PROJET') &&
      !supabaseAnonKey.contains('TON-ANON-KEY');
}
