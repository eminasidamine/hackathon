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
  bool _emailLoading = false;
  bool _isRegister = false;
  String? _error;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

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

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in your email and password.');
      return;
    }
    if (_isRegister &&
        (_fullNameController.text.trim().isEmpty ||
            _phoneController.text.trim().isEmpty)) {
      setState(() => _error = 'Please fill in your name and phone.');
      return;
    }

    setState(() {
      _emailLoading = true;
      _error = null;
    });
    final auth = context.read<AuthService>();
    final error = _isRegister
        ? await auth.signUp(
            email: email,
            password: password,
            fullName: _fullNameController.text.trim(),
            phone: _phoneController.text.trim(),
          )
        : await auth.signIn(email: email, password: password);
    if (!mounted) return;
    setState(() => _emailLoading = false);

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
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppTheme.line)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(t('or_divider'),
                        style: const TextStyle(
                            color: AppTheme.ink2, fontSize: 12)),
                  ),
                  const Expanded(child: Divider(color: AppTheme.line)),
                ],
              ),
              const SizedBox(height: 20),
              _field(
                  controller: _emailController,
                  label: t('email'),
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _field(
                  controller: _passwordController,
                  label: t('password'),
                  obscure: true),
              if (_isRegister) ...[
                const SizedBox(height: 16),
                _field(controller: _fullNameController, label: t('full_name')),
                const SizedBox(height: 16),
                _field(
                    controller: _phoneController,
                    label: t('phone'),
                    keyboardType: TextInputType.phone),
              ],
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _emailLoading ? null : _submitEmail,
                  child: _emailLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_isRegister ? t('register') : t('login'),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    _isRegister = !_isRegister;
                    _error = null;
                  }),
                  child:
                      Text(_isRegister ? t('have_account') : t('no_account')),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 6),
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

  Widget _field({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.ink)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.only(bottom: 10),
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.line)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.line)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.ink, width: 1.4)),
          ),
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
            color: const Color(0xFF4285F4),
          ),
        ),
      ),
    );
  }
}
