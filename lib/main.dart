import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_config.dart';
import 'core/settings_controller.dart';
import 'core/theme.dart';
import 'features/not_configured_screen.dart';
import 'features/shell.dart';
import 'services/auth_service.dart';
import 'services/cart_controller.dart';
import 'services/notification_service.dart';
import 'services/role_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PaintingBinding.instance.imageCache.maximumSizeBytes = 32 * 1024 * 1024;
  PaintingBinding.instance.imageCache.maximumSize = 90;

  if (AppConfig.isConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
  }

  runApp(const MarketplaceApp());
}

class MarketplaceApp extends StatelessWidget {
  const MarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.isConfigured) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: NotConfiguredScreen(),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(
            create: (_) => NotificationsController()..start()),
        ChangeNotifierProvider(create: (_) => RoleController()..refresh()),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Shop',
            theme: AppTheme.light(),
            themeMode: ThemeMode.light,
            locale: Locale(settings.locale),
            builder: (context, child) => Directionality(
              textDirection: settings.textDirection,
              child: child!,
            ),
            home: Shell(),
          );
        },
      ),
    );
  }
}
