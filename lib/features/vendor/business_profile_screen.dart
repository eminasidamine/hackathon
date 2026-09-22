import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../core/money.dart';
import '../../core/settings_controller.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/analytics_service.dart';
import '../../services/business_profile_pdf.dart';
import '../../services/vendor_service.dart';

class BusinessProfileScreen extends StatefulWidget {
  final String shopId;
  const BusinessProfileScreen({super.key, required this.shopId});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _analytics = AnalyticsService();
  final _vendor = VendorService();
  late Future<(Shop?, VendorAnalytics)> _future;
  bool _sharing = false;

  String Function(String) get _t => context.read<SettingsController>().t;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(Shop?, VendorAnalytics)> _load() async {
    final analytics =
        await _analytics.fetchForShop(widget.shopId, rangeDays: 365, t: _t);
    final shop = await _vendor.fetchMyShop();
    return (shop, analytics);
  }

  Future<void> _share(
      Shop? shop, VendorAnalytics a, String Function(String) t) async {
    setState(() => _sharing = true);
    try {
      final bytes = await BusinessProfilePdf.build(shop: shop, a: a, t: t);
      final name = (shop?.name ?? 'shop')
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-|-$'), '');
      await Printing.sharePdf(
        bytes: Uint8List.fromList(bytes),
        filename: 'business-profile-$name.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(t('could_not_generate_file').replaceAll('{e}', '$e'))),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  static String _repeatRate(VendorAnalytics a) => a.customerCount == 0
      ? '—'
      : (a.orderCount / a.customerCount).toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        surfaceTintColor: AppTheme.bg,
        iconTheme: const IconThemeData(color: AppTheme.ink),
        title: Text(t('business_profile_title'),
            style: const TextStyle(color: AppTheme.ink)),
      ),
      body: FutureBuilder<(Shop?, VendorAnalytics)>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _Error(
                onRetry: () => setState(() => _future = _load()), t: t);
          }
          final (shop, a) = snap.data!;

          if (a.isEmpty) {
            return _NothingYet(t: t);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _Header(shop: shop, t: t),
              const SizedBox(height: 16),
              _Section(
                title: t('marketplace_history_title'),
                rows: [
                  (t('orders_fulfilled'), '${a.orderCount}'),
                  (t('sales_volume'), Money.format(a.revenue)),
                  (t('avg_order_value'), Money.format(a.averageOrderValue)),
                  (t('distinct_customers'), '${a.customerCount}'),
                  (t('orders_per_customer'), _repeatRate(a)),
                ],
              ),
              const SizedBox(height: 12),
              _PaymentsSection(analytics: a, t: t),
              const SizedBox(height: 12),
              _ReadinessSection(analytics: a, t: t),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.panel,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  t('business_profile_disclaimer'),
                  style: const TextStyle(
                      fontSize: 11.5, height: 1.45, color: AppTheme.ink2),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.ink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    ),
                  ),
                  onPressed: _sharing ? null : () => _share(shop, a, t),
                  icon: _sharing
                      ? const SizedBox(
                          height: 17,
                          width: 17,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.picture_as_pdf_outlined, size: 18),
                  label: Text(
                      _sharing
                          ? t('generating_ellipsis')
                          : t('download_profile_pdf'),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                t('share_control_note'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11.5, height: 1.35, color: AppTheme.muted),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Shop? shop;
  final String Function(String) t;
  const _Header({required this.shop, required this.t});

  @override
  Widget build(BuildContext context) {
    final s = shop;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('business_profile_label'),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppTheme.ink2)),
          const SizedBox(height: 8),
          Text(s?.name ?? '',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              if (s?.city != null && s!.city!.isNotEmpty)
                _Meta(icon: Icons.place_outlined, text: s.city!),
              if (s?.createdAt != null)
                _Meta(
                    icon: Icons.calendar_today_outlined,
                    text: t('active_since').replaceAll('{date}',
                        '${t('month_${s!.createdAt!.month}')} ${s.createdAt!.year}')),
              if (s?.merchantProvider != null &&
                  s!.merchantProvider!.isNotEmpty)
                _Meta(
                    icon: Icons.account_balance_outlined,
                    text: s.merchantProvider!),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.ink2),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.ink2)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<(String, String)> rows;
  const _Section({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppTheme.ink)),
          const SizedBox(height: 14),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(row.$1,
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.ink2)),
                  ),
                  const SizedBox(width: 12),
                  Text(row.$2,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentsSection extends StatelessWidget {
  final VendorAnalytics analytics;
  final String Function(String) t;
  const _PaymentsSection({required this.analytics, required this.t});

  @override
  Widget build(BuildContext context) {
    final a = analytics;
    final providers = a.revenueByProvider.entries.toList()
      ..sort((x, y) => y.value.compareTo(x.value));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('digital_payments_label'),
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppTheme.ink)),
          const SizedBox(height: 4),
          Text(
            t('payments_found_in_history')
                .replaceAll('{n}', '${a.verifiedCount}')
                .replaceAll('{total}', '${a.orderCount}'),
            style: const TextStyle(
                fontSize: 11.5, height: 1.3, color: AppTheme.muted),
          ),
          const SizedBox(height: 14),
          if (providers.isEmpty)
            Text(t('no_payments_recorded'),
                style: const TextStyle(fontSize: 13, color: AppTheme.muted))
          else
            for (final e in providers)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(e.key,
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.ink2)),
                    ),
                    Text(Money.format(e.value),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink)),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _ReadinessSection extends StatelessWidget {
  final VendorAnalytics analytics;
  final String Function(String) t;
  const _ReadinessSection({required this.analytics, required this.t});

  @override
  Widget build(BuildContext context) {
    final a = analytics;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(t('readiness_title').toUpperCase(),
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppTheme.ink)),
              ),
              Text('${a.readinessScore.round()}',
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.copper)),
              const Text(' / 100',
                  style: TextStyle(fontSize: 13, color: AppTheme.ink2)),
            ],
          ),
          const SizedBox(height: 14),
          for (final p in a.readinessParts) ...[
            Row(
              children: [
                Expanded(
                  child: Text(p.label,
                      style:
                          const TextStyle(fontSize: 13, color: AppTheme.ink)),
                ),
                Text('${p.score.round()} / 25',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink)),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (p.score / 25).clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: AppTheme.line,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.copper),
              ),
            ),
            const SizedBox(height: 3),
            Text(p.detail,
                style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _NothingYet extends StatelessWidget {
  final String Function(String) t;
  const _NothingYet({required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.description_outlined,
                size: 40, color: AppTheme.muted),
            const SizedBox(height: 12),
            Text(t('no_profile_yet_title'),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink)),
            const SizedBox(height: 6),
            Text(
              t('no_profile_yet_subtitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, height: 1.4, color: AppTheme.ink2),
            ),
          ],
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final VoidCallback onRetry;
  final String Function(String) t;
  const _Error({required this.onRetry, required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined,
                size: 40, color: AppTheme.muted),
            const SizedBox(height: 12),
            Text(t('could_not_load_business_profile'),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink)),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: Text(t('retry'))),
          ],
        ),
      ),
    );
  }
}
