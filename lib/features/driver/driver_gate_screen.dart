import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/errors.dart';
import '../../core/settings_controller.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/delivery_service.dart';
import '../../services/role_controller.dart';
import 'driver_home_screen.dart';

Future<void> openDriverSpace(BuildContext context) async {
  final role = context.read<RoleController>();
  if (!role.isDriver) {
    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const DriverGateScreen()),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<RoleController>().refresh();
  }
  if (!context.mounted) return;
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
  );
}

const List<String> kVehicleTypes = ['Motorcycle', 'Car'];

class DriverGateScreen extends StatefulWidget {
  const DriverGateScreen({super.key});

  @override
  State<DriverGateScreen> createState() => _DriverGateScreenState();
}

class _DriverGateScreenState extends State<DriverGateScreen> {
  final _delivery = DeliveryService();
  bool _googleLoading = false;
  bool _creating = false;
  String _vehicleType = kVehicleTypes.first;
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

  Future<void> _becomeDriver() async {
    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      await _delivery.becomeDriver(vehicleType: _vehicleType);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _creating = false;
        _error = friendlyError(e, context.read<SettingsController>().t);
      });
    }
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
                    const SizedBox(height: 60),
                    const Text(
                      'Deliver with us',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                          height: 1.1),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Pick up orders from shops nearby and get paid for the delivery. '
                      'Log in or create an account to continue.',
                      style: TextStyle(
                          fontSize: 15, color: AppTheme.ink2, height: 1.4),
                    ),
                    const SizedBox(height: 30),
                    if (auth.isLoggedIn) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: AppTheme.panel,
                            borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          children: [
                            const CircleAvatar(
                                radius: 20,
                                backgroundColor: AppTheme.line,
                                child: Icon(Icons.person_outline,
                                    color: AppTheme.ink2)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t('vendor_gate_connected_as'),
                                      style: const TextStyle(
                                          fontSize: 11.5,
                                          color: AppTheme.muted)),
                                  const SizedBox(height: 2),
                                  Text(
                                    auth.profile?.fullName ??
                                        auth.profile?.email ??
                                        '',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.ink),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text('Vehicle',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.ink)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final v in kVehicleTypes)
                            _VehicleChip(
                              label: v,
                              selected: _vehicleType == v,
                              onTap: () => setState(() => _vehicleType = v),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _creating ? null : _becomeDriver,
                        child: _creating
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('START DELIVERING'),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _switchAccount,
                        child: Text(t('vendor_gate_switch_account'),
                            style: const TextStyle(color: AppTheme.ink2)),
                      ),
                    ] else ...[
                      SizedBox(
                        height: 54,
                        child: FilledButton(
                          onPressed:
                              _googleLoading ? null : _continueWithGoogle,
                          child: _googleLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : Text(t('continue_with_google'),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(_error!,
                          style: const TextStyle(
                              color: AppTheme.red, fontSize: 13)),
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

class _VehicleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _VehicleChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.ink : AppTheme.panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.ink : AppTheme.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.ink,
          ),
        ),
      ),
    );
  }
}
