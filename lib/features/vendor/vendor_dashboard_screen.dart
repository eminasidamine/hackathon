import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/money.dart';
import '../../core/settings_controller.dart';
import '../../core/theme.dart';
import '../../services/analytics_service.dart';
import '../widgets.dart';
import 'business_profile_screen.dart';

class VendorDashboardScreen extends StatefulWidget {
  final String shopId;
  final String shopName;
  final String? shopLogoUrl;

  const VendorDashboardScreen({
    super.key,
    required this.shopId,
    required this.shopName,
    this.shopLogoUrl,
  });

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  final AnalyticsService _analytics = AnalyticsService();
  late Future<VendorAnalytics> _future;
  int _range = 30;

  String Function(String) get _t => context.read<SettingsController>().t;

  @override
  void initState() {
    super.initState();
    _future = _analytics.fetchForShop(widget.shopId, rangeDays: _range, t: _t);
  }

  void _reload({int? range}) {
    setState(() {
      if (range != null) _range = range;
      _future =
          _analytics.fetchForShop(widget.shopId, rangeDays: _range, t: _t);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(t('vendor_activity_title')),
        backgroundColor: AppTheme.bg,
      ),
      body: FutureBuilder<VendorAnalytics>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const _DashboardSkeleton();
          }
          if (snap.hasError) {
            return _DashboardError(onRetry: _reload, t: t);
          }
          final a = snap.data!;
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _Greeting(
                    shop: widget.shopName,
                    shopLogoUrl: widget.shopLogoUrl,
                    t: t),
                const SizedBox(height: 16),
                _RangePicker(
                    value: _range, onChanged: (v) => _reload(range: v), t: t),
                const SizedBox(height: 16),
                if (a.isEmpty)
                  _NoSalesYet(t: t)
                else ...[
                  _KpiGrid(a: a, t: t),
                  const SizedBox(height: 24),
                  _Block(
                    title: t('block_sales_title'),
                    t: t,
                    icon: Icons.show_chart_rounded,
                    child: SalesChart(points: a.salesByDay, t: t),
                  ),
                  const SizedBox(height: 16),
                  _Block(
                    title: t('block_payments_title'),
                    t: t,
                    icon: Icons.account_balance_wallet_outlined,
                    child: _ProviderSplit(a: a, t: t),
                  ),
                  const SizedBox(height: 16),
                  _Block(
                    title: t('block_products_title'),
                    t: t,
                    icon: Icons.shopping_bag_outlined,
                    child: _TopProducts(a: a, t: t),
                  ),
                  const SizedBox(height: 16),
                  _ReadinessBlock(a: a, shopId: widget.shopId, t: t),
                  const SizedBox(height: 16),
                  _InsightsBlock(a: a, t: t),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  final String shop;
  final String? shopLogoUrl;
  final String Function(String) t;
  const _Greeting(
      {required this.shop, required this.shopLogoUrl, required this.t});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ShopAvatar(name: shop, logoUrl: shopLogoUrl, size: 46),
        const SizedBox(width: 12),
        Expanded(
          child: Center(
            child: Text(
              t('vendor_activity_subtitle').replaceAll('{shop}', shop),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.ink2),
            ),
          ),
        ),
      ],
    );
  }
}

class _RangePicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final String Function(String) t;
  const _RangePicker(
      {required this.value, required this.onChanged, required this.t});

  @override
  Widget build(BuildContext context) {
    final options = {7: t('days_7'), 30: t('days_30'), 90: t('days_90')};
    return Row(
      children: options.entries.map((e) {
        final selected = e.key == value;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onChanged(e.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppTheme.ink : AppTheme.panel,
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                border: Border.all(color: AppTheme.line),
              ),
              child: Text(
                e.value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppTheme.bg : AppTheme.ink2,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final VendorAnalytics a;
  final String Function(String) t;
  const _KpiGrid({required this.a, required this.t});

  @override
  Widget build(BuildContext context) {
    final growth = a.revenueGrowthPct;
    return LayoutBuilder(builder: (context, c) {
      final columns = c.maxWidth < 340 ? 1 : 2;
      final width = (c.maxWidth - (columns - 1) * 12) / columns;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
              width: width,
              child: _Kpi(
                  value: Money.format(a.revenue),
                  label: t('kpi_revenue'),
                  emphasis: true)),
          SizedBox(
              width: width,
              child: _Kpi(value: '${a.orderCount}', label: t('kpi_orders'))),
          SizedBox(
              width: width,
              child:
                  _Kpi(value: '${a.customerCount}', label: t('kpi_customers'))),
          SizedBox(
            width: width,
            child: _Kpi(
              value: growth == null
                  ? '—'
                  : '${growth >= 0 ? '+' : ''}${growth.round()}%',
              label: growth == null
                  ? t('kpi_growth_first_period')
                  : t('kpi_growth'),
            ),
          ),
        ],
      );
    });
  }
}

class _Kpi extends StatelessWidget {
  final String value;
  final String label;
  final bool emphasis;
  const _Kpi({required this.value, required this.label, this.emphasis = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: emphasis ? AppTheme.kpiHighlight : AppTheme.panel,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(
            color: emphasis ? AppTheme.kpiHighlightBorder : AppTheme.line),
        boxShadow: emphasis
            ? [
                BoxShadow(
                  color: AppTheme.kpiHighlightBorder.withValues(alpha: 0.5),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: emphasis ? 24 : 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppTheme.ink2)),
        ],
      ),
    );
  }
}

class SalesChart extends StatelessWidget {
  final List<DailyPoint> points;
  final String Function(String) t;
  const SalesChart({super.key, required this.points, required this.t});

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text(t('chart_not_enough_days'),
              style: const TextStyle(fontSize: 13, color: AppTheme.muted)),
        ),
      );
    }
    final max = points.map((p) => p.revenue).reduce((x, y) => x > y ? x : y);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 140,
          width: double.infinity,
          child: CustomPaint(painter: _SalesPainter(points)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_shortDate(points.first.day),
                style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
            Text(t('chart_peak').replaceAll('{x}', Money.formatCompact(max)),
                style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
            Text(_shortDate(points.last.day),
                style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
          ],
        ),
      ],
    );
  }

  static String _shortDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}

class _SalesPainter extends CustomPainter {
  final List<DailyPoint> points;
  _SalesPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final maxRevenue =
        points.map((p) => p.revenue).fold<double>(0, (x, y) => x > y ? x : y);
    final scale = maxRevenue <= 0 ? 1.0 : maxRevenue;

    final firstDay = points.first.day;
    final span = points.last.day.difference(firstDay).inDays;
    double dx(int i) => span == 0
        ? 0
        : points[i].day.difference(firstDay).inDays / span * size.width;
    double dy(int i) =>
        size.height - (points[i].revenue / scale) * (size.height - 8) - 4;

    final line = Path()..moveTo(dx(0), dy(0));
    for (var i = 1; i < points.length; i++) {
      line.lineTo(dx(i), dy(i));
    }

    final fill = Path.from(line)
      ..lineTo(dx(points.length - 1), size.height)
      ..lineTo(dx(0), size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.copper.withValues(alpha: 0.22),
            AppTheme.copper.withValues(alpha: 0.02),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      line,
      Paint()
        ..color = AppTheme.copper
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SalesPainter old) => old.points != points;
}

class _ProviderSplit extends StatelessWidget {
  final VendorAnalytics a;
  final String Function(String) t;
  const _ProviderSplit({required this.a, required this.t});

  @override
  Widget build(BuildContext context) {
    if (a.revenueByProvider.isEmpty || a.revenue <= 0) {
      return Text(t('no_payments_period'),
          style: const TextStyle(fontSize: 13, color: AppTheme.muted));
    }
    final entries = a.revenueByProvider.entries.toList()
      ..sort((x, y) => y.value.compareTo(x.value));
    return Column(
      children: [
        for (final e in entries) ...[
          _Bar(
            label: e.key,
            trailing: '${(e.value / a.revenue * 100).round()}%',
            fraction: e.value / a.revenue,
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 2),
        if (a.awaitingVerification > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              t(a.awaitingVerification > 1
                      ? 'refs_pending_plural'
                      : 'refs_pending_singular')
                  .replaceAll('{n}', '${a.awaitingVerification}'),
              style: const TextStyle(fontSize: 12, color: AppTheme.stockWarn),
            ),
          ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final String trailing;
  final double fraction;
  const _Bar(
      {required this.label, required this.trailing, required this.fraction});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.ink)),
            ),
            const SizedBox(width: 10),
            Text(trailing,
                style: const TextStyle(fontSize: 13, color: AppTheme.ink2)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppTheme.line,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.copper),
          ),
        ),
      ],
    );
  }
}

class _TopProducts extends StatelessWidget {
  final VendorAnalytics a;
  final String Function(String) t;
  const _TopProducts({required this.a, required this.t});

  @override
  Widget build(BuildContext context) {
    if (a.topProducts.isEmpty) {
      return Text(t('no_products_sold_period'),
          style: const TextStyle(fontSize: 13, color: AppTheme.muted));
    }
    final best = a.topProducts.first.revenue;
    return Column(
      children: [
        for (final p in a.topProducts) ...[
          _Bar(
            label: p.name,
            trailing: '${p.quantity} · ${Money.formatCompact(p.revenue)}',
            fraction: best <= 0 ? 0 : p.revenue / best,
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ReadinessBlock extends StatelessWidget {
  final VendorAnalytics a;
  final String shopId;
  final String Function(String) t;
  const _ReadinessBlock(
      {required this.a, required this.shopId, required this.t});

  @override
  Widget build(BuildContext context) {
    final score = a.readinessScore.round();
    return _Block(
      title: t('readiness_title'),
      subtitle: t('readiness_subtitle'),
      shopId: shopId,
      t: t,
      icon: Icons.speed_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: CircularProgressIndicator(
                        value: (score / 100).clamp(0.0, 1.0),
                        strokeWidth: 6,
                        backgroundColor: AppTheme.line,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.copper),
                      ),
                    ),
                    Text('$score',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Text('/ 100',
                  style: TextStyle(fontSize: 16, color: AppTheme.ink2)),
            ],
          ),
          const SizedBox(height: 16),
          for (final part in a.readinessParts) ...[
            _Bar(
              label: part.label,
              trailing: '${part.score.round()} / 25',
              fraction: part.score / 25,
            ),
            const SizedBox(height: 2),
            Text(part.detail,
                style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.panel,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Text(
              t('readiness_disclaimer'),
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.ink2, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightsBlock extends StatelessWidget {
  final VendorAnalytics a;
  final String Function(String) t;
  const _InsightsBlock({required this.a, required this.t});

  @override
  Widget build(BuildContext context) {
    final insights = BoutigueInsights.from(a, t);
    if (insights.isEmpty) return const SizedBox.shrink();
    return _Block(
      title: t('block_insights_title'),
      t: t,
      icon: Icons.auto_awesome_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final i in insights) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  i.isSuggestion
                      ? Icons.lightbulb_outline
                      : Icons.insights_outlined,
                  size: 16,
                  color: i.isSuggestion ? AppTheme.copper : AppTheme.ink2,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.ink, height: 1.4),
                      children: [
                        TextSpan(
                          text: i.isSuggestion
                              ? t('insight_suggestion_prefix')
                              : t('insight_observation_prefix'),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.ink2),
                        ),
                        TextSpan(text: i.text),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Text(
            t('insights_footer'),
            style: const TextStyle(fontSize: 11, color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final String? shopId;
  final String Function(String) t;
  final IconData? icon;

  const _Block(
      {required this.title,
      this.subtitle,
      required this.child,
      this.shopId,
      required this.t,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.line),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ink.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.copper.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 15, color: AppTheme.copper),
                ),
                const SizedBox(width: 10),
              ],
              Text(title.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: AppTheme.ink)),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
          ],
          const SizedBox(height: 16),
          child,
          if (shopId != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BusinessProfileScreen(shopId: shopId!),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.ink,
                  side: const BorderSide(color: AppTheme.line),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                ),
                icon: const Icon(Icons.description_outlined, size: 18),
                label: Text(t('generate_business_profile'),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NoSalesYet extends StatelessWidget {
  final String Function(String) t;
  const _NoSalesYet({required this.t});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: EmptyState(
        icon: Icons.storefront_outlined,
        title: t('no_sales_yet_title'),
        subtitle: t('no_sales_yet_subtitle'),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  final VoidCallback onRetry;
  final String Function(String) t;
  const _DashboardError({required this.onRetry, required this.t});

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
            Text(t('dashboard_load_error_title'),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink)),
            const SizedBox(height: 6),
            Text(t('check_connection_retry'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppTheme.ink2)),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: Text(t('retry'))),
          ],
        ),
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget box(double height, {double width = double.infinity}) => Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: AppTheme.panel,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
        );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        box(24, width: 180),
        const SizedBox(height: 8),
        box(14, width: 240),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: box(86)),
          const SizedBox(width: 12),
          Expanded(child: box(86)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: box(86)),
          const SizedBox(width: 12),
          Expanded(child: box(86)),
        ]),
        const SizedBox(height: 24),
        box(200),
        const SizedBox(height: 16),
        box(160),
      ],
    );
  }
}
