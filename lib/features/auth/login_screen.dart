import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/settings_controller.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/role_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

    if (error != null) {
      setState(() => _error = error);
    } else if (auth.isLoggedIn) {
      await context.read<RoleController>().refresh();
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    return Scaffold(
      appBar: AppBar(title: Text(t('login'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Text(
                t('vendor_gate_subtitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.ink2, height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _googleLoading ? null : _continueWithGoogle,
                  icon: _googleLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const _GoogleLogo(size: 18),
                  label: Text(t('continue_with_google'),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(_error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.red, fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
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
            color: const Color(0xFF4285F4),
          ),
        ),
      ),
    );
  }
}
