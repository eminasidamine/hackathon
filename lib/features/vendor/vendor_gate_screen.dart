import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/settings_controller.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/vendor_service.dart';
import 'my_shop_screen.dart';

Future<void> openMyShop(
  BuildContext context, {
  String? initialCategoryId,
  List<String> categoryIds = const [],
}) async {
  final existingShop = await VendorService().fetchMyShop();
  if (!context.mounted) return;
  if (existingShop == null) {
    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const VendorGateScreen()),
    );
    if (confirmed != true || !context.mounted) return;
  }
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => MyShopScreen(
          initialCategoryId: initialCategoryId,
          initialCategoryIds: categoryIds),
    ),
  );
}

class VendorGateScreen extends StatefulWidget {
  const VendorGateScreen({super.key});

  @override
  State<VendorGateScreen> createState() => _VendorGateScreenState();
}

class _VendorGateScreenState extends State<VendorGateScreen> {
  bool _googleLoading = false;
  String? _error;

  Future<void> _continueWithGoogle() async {
    setState(() {
      _googleLoading = true;
      _error = null;
    });
    final auth = context.read<AuthService>();
    final error = await auth.signInWithGoogle();
    if (!mounted) return;
    setState(() => _googleLoading = false);
    if (error != null) setState(() => _error = error);
  }

  Future<void> _switchAccount() async {
    await context.read<AuthService>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppTheme.ink, size: 26),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 90),
                    Text(
                      t('vendor_gate_title'),
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                          height: 1.1),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      t('vendor_gate_subtitle'),
                      style: const TextStyle(
                          fontSize: 15, color: AppTheme.ink2, height: 1.4),
                    ),
                    const SizedBox(height: 30),
                    if (auth.isLoggedIn)
                      _ConnectedCard(
                          auth: auth, onSwitchAccount: _switchAccount)
                    else ...[
                      SizedBox(
                        height: 54,
                        child: FilledButton.icon(
                          onPressed:
                              _googleLoading ? null : _continueWithGoogle,
                          icon: _googleLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const _GoogleLogo(size: 18),
                          label: Text(
                            t('continue_with_google'),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        Text(_error!,
                            style: const TextStyle(
                                color: AppTheme.red, fontSize: 13)),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectedCard extends StatelessWidget {
  final AuthService auth;
  final Future<void> Function() onSwitchAccount;

  const _ConnectedCard({required this.auth, required this.onSwitchAccount});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    final label = auth.profile?.fullName ?? auth.profile?.email ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppTheme.panel, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.line,
                  child: Icon(Icons.person_outline, color: AppTheme.ink2)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('vendor_gate_connected_as'),
                        style: const TextStyle(
                            fontSize: 11.5, color: AppTheme.muted)),
                    const SizedBox(height: 2),
                    Text(label,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(t('vendor_gate_continue')),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: onSwitchAccount,
          child: Text(t('vendor_gate_switch_account'),
              style: const TextStyle(color: AppTheme.ink2)),
        ),
      ],
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  final double size;

  const _GoogleLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
              fontSize: size,
              height: 1,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4285F4)),
        ),
      ),
    );
  }
}
