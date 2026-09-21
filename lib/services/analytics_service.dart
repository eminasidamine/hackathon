import 'package:supabase_flutter/supabase_flutter.dart';

class DailyPoint {
  final DateTime day;
  final double revenue;
  final int orders;
  const DailyPoint(
      {required this.day, required this.revenue, required this.orders});
}

class ProductPerf {
  final String name;
  final int quantity;
  final double revenue;
  const ProductPerf(
      {required this.name, required this.quantity, required this.revenue});
}

class ReadinessPart {
  final String label;
  final double score;
  final String detail;
  const ReadinessPart(
      {required this.label, required this.score, required this.detail});
}

class VendorAnalytics {
  final int rangeDays;
  final double revenue;
  final int orderCount;
  final int customerCount;
  final double averageOrderValue;
  final double? revenueGrowthPct;
  final List<DailyPoint> salesByDay;
  final Map<String, double> revenueByProvider;
  final List<ProductPerf> topProducts;
  final List<ProductPerf> slowProducts;
  final Map<int, int> ordersByWeekday;
  final int awaitingVerification;
  final int verifiedCount;
  final int mismatchCount;
  final List<ReadinessPart> readinessParts;

  const VendorAnalytics({
    required this.rangeDays,
    required this.revenue,
    required this.orderCount,
    required this.customerCount,
    required this.averageOrderValue,
    required this.revenueGrowthPct,
    required this.salesByDay,
    required this.revenueByProvider,
    required this.topProducts,
    required this.slowProducts,
    required this.ordersByWeekday,
    required this.awaitingVerification,
    required this.verifiedCount,
    required this.mismatchCount,
    required this.readinessParts,
  });

  bool get isEmpty => orderCount == 0;

  double get readinessScore =>
      readinessParts.fold<double>(0, (sum, p) => sum + p.score);

  int? get busiestWeekday {
    if (orderCount < 5 || ordersByWeekday.isEmpty) return null;
    final sorted = ordersByWeekday.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.length > 1 && sorted[0].value == sorted[1].value) return null;
    return sorted.first.key;
  }
}

class AnalyticsService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<VendorAnalytics> fetchForShop(
    String shopId, {
    int rangeDays = 30,
    required String Function(String) t,
  }) async {
    final now = DateTime.now();
    final periodStart = now.subtract(Duration(days: rangeDays));
    final previousStart = now.subtract(Duration(days: rangeDays * 2));
    final rows = await _client
        .from('orders')
        .select('*, order_items(product_name, quantity, subtotal)')
        .eq('shop_id', shopId)
        .gte('created_at', previousStart.toIso8601String())
        .order('created_at', ascending: false);
    final shopRow = await _client
        .from('shops')
        .select(
            'name, description, logo_url, city, whatsapp_phone, merchant_code, merchant_provider, lat, created_at')
        .eq('id', shopId)
        .maybeSingle();
    return _build(
      rows: List<Map<String, dynamic>>.from(rows),
      shop: shopRow,
      now: now,
      periodStart: periodStart,
      rangeDays: rangeDays,
      t: t,
    );
  }

  VendorAnalytics _build({
    required List<Map<String, dynamic>> rows,
    required Map<String, dynamic>? shop,
    required DateTime now,
    required DateTime periodStart,
    required int rangeDays,
    required String Function(String) t,
  }) {
    double revenue = 0;
    double previousRevenue = 0;
    int orderCount = 0;
    int awaiting = 0;
    int verified = 0;
    int mismatch = 0;
    final customers = <String>{};
    final byDay = <DateTime, DailyPoint>{};
    final byProvider = <String, double>{};
    final byWeekday = <int, int>{};
    final byProduct = <String, ProductPerf>{};
    final activeWeeks = <int>{};

    for (final row in rows) {
      final createdAt = DateTime.tryParse(row['created_at'] as String? ?? '');
      if (createdAt == null) continue;
      final status = row['status'] as String? ?? 'pending';
      final paymentStatus = row['payment_status'] as String? ?? 'submitted';
      final counts = status != 'cancelled' && paymentStatus != 'rejected';
      final total = (row['total'] as num?)?.toDouble() ?? 0;
      if (createdAt.isBefore(periodStart)) {
        if (counts) previousRevenue += total;
        continue;
      }
      if (!counts) continue;
      orderCount++;
      revenue += total;
      if (paymentStatus == 'verified') {
        verified++;
        final received = (row['payment_amount_received'] as num?)?.toDouble();
        if (received != null && (received - total).abs() > 1) mismatch++;
      } else if (paymentStatus == 'submitted') {
        awaiting++;
      }
      final clientId = row['client_id'] as String?;
      if (clientId != null) customers.add(clientId);
      final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
      final existing = byDay[day];
      byDay[day] = DailyPoint(
        day: day,
        revenue: (existing?.revenue ?? 0) + total,
        orders: (existing?.orders ?? 0) + 1,
      );
      byWeekday[createdAt.weekday] = (byWeekday[createdAt.weekday] ?? 0) + 1;
      activeWeeks.add(now.difference(day).inDays ~/ 7);
      final provider = (row['payment_provider'] as String?)?.trim();
      final providerKey = provider == null || provider.isEmpty
          ? t('payment_provider_other')
          : provider;
      byProvider[providerKey] = (byProvider[providerKey] ?? 0) + total;
      for (final item in (row['order_items'] as List? ?? const [])) {
        final map = item as Map<String, dynamic>;
        final name =
            (map['product_name'] as String? ?? '').split(' — ').first.trim();
        if (name.isEmpty) continue;
        final qty = (map['quantity'] as num?)?.toInt() ?? 0;
        final sub = (map['subtotal'] as num?)?.toDouble() ?? 0;
        final prev = byProduct[name];
        byProduct[name] = ProductPerf(
          name: name,
          quantity: (prev?.quantity ?? 0) + qty,
          revenue: (prev?.revenue ?? 0) + sub,
        );
      }
    }

    final points = byDay.values.toList()
      ..sort((a, b) => a.day.compareTo(b.day));
    final products = byProduct.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    return VendorAnalytics(
      rangeDays: rangeDays,
      revenue: revenue,
      orderCount: orderCount,
      customerCount: customers.length,
      averageOrderValue: orderCount == 0 ? 0 : revenue / orderCount,
      revenueGrowthPct: previousRevenue <= 0
          ? null
          : ((revenue - previousRevenue) / previousRevenue) * 100,
      salesByDay: points,
      revenueByProvider: byProvider,
      topProducts: products.take(5).toList(),
      slowProducts: products.reversed.take(3).toList(),
      ordersByWeekday: byWeekday,
      awaitingVerification: awaiting,
      verifiedCount: verified,
      mismatchCount: mismatch,
      readinessParts: _readiness(
        shop: shop,
        orderCount: orderCount,
        verified: verified,
        activeWeeks: activeWeeks.length,
        rangeDays: rangeDays,
        t: t,
      ),
    );
  }

  List<ReadinessPart> _readiness({
    required Map<String, dynamic>? shop,
    required int orderCount,
    required int verified,
    required int activeWeeks,
    required int rangeDays,
    required String Function(String) t,
  }) {
    final weeksInRange = (rangeDays / 7).ceil();
    final consistency =
        weeksInRange == 0 ? 0.0 : (activeWeeks / weeksInRange).clamp(0.0, 1.0);
    const volumeTarget = 40;
    final volume = (orderCount / volumeTarget).clamp(0.0, 1.0);
    final digital =
        orderCount == 0 ? 0.0 : (verified / orderCount).clamp(0.0, 1.0);
    const fields = [
      'name',
      'description',
      'logo_url',
      'city',
      'whatsapp_phone',
      'merchant_code',
      'merchant_provider',
      'lat',
    ];
    final filled = shop == null
        ? 0
        : fields.where((f) {
            final v = shop[f];
            return v != null && v.toString().trim().isNotEmpty;
          }).length;
    final completeness = filled / fields.length;
    return [
      ReadinessPart(
        label: t('readiness_label_activity_regularity'),
        score: consistency * 25,
        detail: t(activeWeeks > 1
                ? 'readiness_weeks_plural'
                : 'readiness_weeks_singular')
            .replaceAll('{active}', '$activeWeeks')
            .replaceAll('{total}', '$weeksInRange'),
      ),
      ReadinessPart(
        label: t('readiness_label_order_volume'),
        score: volume * 25,
        detail: t(orderCount > 1
                ? 'readiness_orders_plural'
                : 'readiness_orders_singular')
            .replaceAll('{n}', '$orderCount')
            .replaceAll('{target}', '$volumeTarget'),
      ),
      ReadinessPart(
        label: t('readiness_label_digital_payments'),
        score: digital * 25,
        detail: t(verified > 1
                ? 'readiness_payments_plural'
                : 'readiness_payments_singular')
            .replaceAll('{n}', '$verified')
            .replaceAll('{total}', '$orderCount'),
      ),
      ReadinessPart(
        label: t('readiness_label_shop_profile'),
        score: completeness * 25,
        detail: t(filled > 1
                ? 'readiness_fields_plural'
                : 'readiness_fields_singular')
            .replaceAll('{n}', '$filled')
            .replaceAll('{total}', '${fields.length}'),
      ),
    ];
  }
}

class Insight {
  final String text;
  final bool isSuggestion;
  const Insight(this.text, {this.isSuggestion = false});
}

class BoutigueInsights {
  static const _weekdayKeys = [
    'weekday_monday',
    'weekday_tuesday',
    'weekday_wednesday',
    'weekday_thursday',
    'weekday_friday',
    'weekday_saturday',
    'weekday_sunday',
  ];

  static List<Insight> from(VendorAnalytics a, String Function(String) t) {
    if (a.isEmpty) return const [];
    final out = <Insight>[];
    final growth = a.revenueGrowthPct;
    if (growth != null && growth.abs() >= 5) {
      out.add(Insight(
          t(growth > 0 ? 'insight_sales_grew' : 'insight_sales_dropped')
              .replaceAll('{n}', '${growth.abs().round()}')
              .replaceAll('{days}', '${a.rangeDays}')));
    }
    final busiest = a.busiestWeekday;
    if (busiest != null) {
      final day = t(_weekdayKeys[busiest - 1]);
      out.add(Insight(t('insight_busiest_day').replaceAll('{day}', day)));
      out.add(Insight(
        t('insight_restock_suggestion').replaceAll('{day}', day),
        isSuggestion: true,
      ));
    }
    if (a.topProducts.isNotEmpty) {
      out.add(Insight(t('insight_best_seller')
          .replaceAll('{name}', a.topProducts.first.name)));
    }
    if (a.revenueByProvider.isNotEmpty && a.revenue > 0) {
      final top = a.revenueByProvider.entries
          .reduce((x, y) => x.value >= y.value ? x : y);
      final share = (top.value / a.revenue * 100).round();
      out.add(Insight(t('insight_provider_share')
          .replaceAll('{pct}', '$share')
          .replaceAll('{provider}', top.key)));
    }
    if (a.awaitingVerification > 0) {
      out.add(Insight(
        t(a.awaitingVerification > 1
                ? 'insight_refs_checking_plural'
                : 'insight_refs_checking_singular')
            .replaceAll('{n}', '${a.awaitingVerification}'),
        isSuggestion: true,
      ));
    }
    if (a.customerCount > 0 && a.orderCount > a.customerCount) {
      final repeat = a.orderCount / a.customerCount;
      if (repeat >= 1.3) {
        out.add(Insight(t('insight_repeat_customers')
            .replaceAll('{x}', repeat.toStringAsFixed(1))));
      }
    }
    return out;
  }
}
