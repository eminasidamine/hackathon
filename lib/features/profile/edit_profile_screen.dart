import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/settings_controller.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/role_controller.dart';

const List<String> _countryCodes = ['+222', '+221', '+212', '+216', '+213'];

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  String _countryCode = '+222';
  String? _gender;
  bool _dirty = false;
  bool _saving = false;
  bool _signingOut = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthService>().profile;

    final nameParts = (profile?.fullName ?? '').trim().split(RegExp(r'\s+'));
    _firstName = TextEditingController(
        text: nameParts.isNotEmpty ? nameParts.first : '');
    _lastName = TextEditingController(
        text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');

    final rawPhone = (profile?.phone ?? '').trim();
    if (rawPhone.startsWith('+') && rawPhone.contains(' ')) {
      final spaceIndex = rawPhone.indexOf(' ');
      final code = rawPhone.substring(0, spaceIndex);
      _countryCode = _countryCodes.contains(code) ? code : '+222';
      _phone = TextEditingController(
          text: rawPhone.substring(spaceIndex + 1).trim());
    } else {
      _phone = TextEditingController(text: rawPhone);
    }

    _gender = profile?.gender == 'unspecified' ? null : profile?.gender;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _save() async {
    if (!_dirty || _saving) return;
    setState(() => _saving = true);
    final auth = context.read<AuthService>();
    final fullName = [_firstName.text.trim(), _lastName.text.trim()]
        .where((s) => s.isNotEmpty)
        .join(' ');
    final phone =
        _phone.text.trim().isEmpty ? '' : '$_countryCode ${_phone.text.trim()}';
    final error = await auth.updateProfile(
        fullName: fullName, phone: phone, gender: _gender);
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (error == null) _dirty = false;
    });
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile updated.')));
    }
  }

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    await context.read<AuthService>().signOut();
    if (!mounted) return;

    context.read<RoleController>().clear();
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _deleteAccount() async {
    final t = context.read<SettingsController>().t;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text(t('delete_account_title')),
        content: Text(t('delete_account_body')),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t('cancel'))),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t('delete_account_confirm'),
                style: const TextStyle(color: AppTheme.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _deleting = true);
    final error = await context.read<AuthService>().deleteAccount();
    if (!mounted) return;
    if (error != null) {
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  InputDecoration _underline({String? hint}) => InputDecoration(
        isDense: true,
        filled: false,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6F6668), fontSize: 14),
        contentPadding: const EdgeInsets.only(bottom: 10),
        border: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppTheme.line)),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppTheme.line)),
        disabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppTheme.line)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppTheme.ink, width: 1.4)),
      );

  Widget _label(String text, {bool required = true, bool muted = false}) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: muted ? AppTheme.ink.withValues(alpha: 0.55) : AppTheme.ink),
        children: [
          TextSpan(text: text),
          if (required)
            const TextSpan(text: ' *', style: TextStyle(color: AppTheme.mauve)),
        ],
      ),
    );
  }

  Widget _field(
      {required String label, required Widget input, bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label, required: required),
          const SizedBox(height: 9),
          input,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    final profile = context.watch<AuthService>().profile;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: SvgPicture.string(
                        '<svg viewBox="0 0 24 24" fill="none" stroke="#2B2B2B" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 5l-7 7 7 7"/></svg>',
                        width: 22,
                        height: 22,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        t('my_profile'),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                            letterSpacing: -0.2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 26),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 14, bottom: 6),
                      child: Text(
                        t('general_info').toUpperCase(),
                        style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: AppTheme.ink),
                      ),
                    ),
                    _field(
                      label: t('first_name'),
                      input: TextFormField(
                        controller: _firstName,
                        style:
                            const TextStyle(color: AppTheme.ink, fontSize: 14),
                        decoration: _underline(),
                        onChanged: (_) => _markDirty(),
                      ),
                    ),
                    _field(
                      label: t('last_name'),
                      input: TextFormField(
                        controller: _lastName,
                        style:
                            const TextStyle(color: AppTheme.ink, fontSize: 14),
                        decoration: _underline(),
                        onChanged: (_) => _markDirty(),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 102,
                          child: _field(
                            label: t('country_code'),
                            input: DropdownButtonFormField<String>(
                              value: _countryCode,
                              decoration: _underline(),
                              dropdownColor: AppTheme.panel,
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: AppTheme.muted, size: 18),
                              style: const TextStyle(
                                  color: AppTheme.ink, fontSize: 14),
                              items: [
                                for (final c in _countryCodes)
                                  DropdownMenuItem(value: c, child: Text(c))
                              ],
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() => _countryCode = v);
                                _markDirty();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: _field(
                            label: t('phone_number'),
                            input: TextFormField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                  color: AppTheme.ink, fontSize: 14),
                              decoration: _underline(hint: '42 00 00 00'),
                              onChanged: (_) => _markDirty(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    _field(
                      label: t('email_address'),
                      input: TextFormField(
                        initialValue: profile?.email ?? '',
                        readOnly: true,
                        style: TextStyle(
                            color: AppTheme.ink.withValues(alpha: 0.55),
                            fontSize: 14),
                        decoration: _underline(),
                      ),
                    ),
                    _field(
                      label: t('gender'),
                      input: DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: _underline(),
                        dropdownColor: AppTheme.panel,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: AppTheme.muted, size: 18),
                        style:
                            const TextStyle(color: AppTheme.ink, fontSize: 14),
                        items: [
                          DropdownMenuItem(
                              value: 'female', child: Text(t('gender_female'))),
                          DropdownMenuItem(
                              value: 'male', child: Text(t('gender_male'))),
                        ],
                        onChanged: (v) {
                          setState(() => _gender = v);
                          _markDirty();
                        },
                      ),
                    ),
                    const SizedBox(height: 34),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _dirty ? AppTheme.ink : const Color(0xFF5A5153),
                          foregroundColor:
                              _dirty ? Colors.white : const Color(0xFFA39C9E),
                          disabledBackgroundColor: const Color(0xFF5A5153),
                          disabledForegroundColor: const Color(0xFFA39C9E),
                          elevation: 0,
                          shape: const RoundedRectangleBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 17),
                        ),
                        onPressed: (_dirty && !_saving) ? _save : null,
                        child: _saving
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.black))
                            : Text(t('save_changes'),
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0)),
                      ),
                    ),
                    const SizedBox(height: 56),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.ink,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 17),
                        ),
                        onPressed: _signingOut ? null : _signOut,
                        child: _signingOut
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text(t('sign_out_caps'),
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.red,
                          side: const BorderSide(color: AppTheme.red),
                          shape: const RoundedRectangleBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 17),
                        ),
                        onPressed: _deleting ? null : _deleteAccount,
                        child: _deleting
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppTheme.red))
                            : Text(t('delete_account_caps'),
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0)),
                      ),
                    ),
                    const SizedBox(height: 26),
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
