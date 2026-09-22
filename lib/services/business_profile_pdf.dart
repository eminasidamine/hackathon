import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/money.dart';
import '../models/models.dart';
import 'analytics_service.dart';

class BusinessProfilePdf {
  BusinessProfilePdf._();

  static String monthYear(DateTime d, String Function(String) t) =>
      '${t('month_${d.month}')} ${d.year}';

  static String _today(String Function(String) t) {
    final n = DateTime.now();
    return '${n.day} ${t('month_${n.month}')} ${n.year}';
  }

  static PdfColor get _ink => const PdfColor.fromInt(0xFF2B2B2B);
  static PdfColor get _ink2 => const PdfColor.fromInt(0xFF5C5658);
  static PdfColor get _line => const PdfColor.fromInt(0xFFE8E2E3);
  static PdfColor get _tint => const PdfColor.fromInt(0xFFF6F3F4);
  static PdfColor get _copper => const PdfColor.fromInt(0xFFD2793F);

  static Future<List<int>> build({
    required Shop? shop,
    required VendorAnalytics a,
    required String Function(String) t,
  }) async {
    final doc = pw.Document(
      title: '${t('business_profile_title')} — ${shop?.name ?? ''}',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 40),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 12),
          child: pw.Text(
            '${shop?.name ?? ''} · ${t('pdf_page_label')} ${context.pageNumber}/${context.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: _ink2),
          ),
        ),
        build: (context) => [
          _header(shop, t),
          pw.SizedBox(height: 22),
          _section(t('marketplace_history_title'), [
            (t('orders_fulfilled'), '${a.orderCount}'),
            (t('sales_volume'), Money.format(a.revenue)),
            (t('avg_order_value'), Money.format(a.averageOrderValue)),
            (t('distinct_customers'), '${a.customerCount}'),
            (t('orders_per_customer'), _repeat(a)),
          ]),
          pw.SizedBox(height: 16),
          _payments(a, t),
          pw.SizedBox(height: 16),
          _readiness(a, t),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFF6F3F4),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(t('business_profile_disclaimer'),
                style:
                    pw.TextStyle(fontSize: 8.5, color: _ink2, lineSpacing: 2)),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static String _repeat(VendorAnalytics a) => a.customerCount == 0
      ? '—'
      : (a.orderCount / a.customerCount).toStringAsFixed(1);

  static pw.Widget _header(Shop? shop, String Function(String) t) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: _tint,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(t('business_profile_label'),
              style: pw.TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.2,
                  fontWeight: pw.FontWeight.bold,
                  color: _ink)),
          pw.SizedBox(height: 10),
          pw.Text(shop?.name ?? '',
              style: pw.TextStyle(
                  fontSize: 22, fontWeight: pw.FontWeight.bold, color: _ink)),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 16,
            runSpacing: 3,
            children: [
              if (shop?.city != null && shop!.city!.isNotEmpty)
                _meta(t('pdf_city_label'), shop.city!),
              if (shop?.createdAt != null)
                _meta(t('pdf_active_since_label'),
                    monthYear(shop!.createdAt!, t)),
              if (shop?.merchantProvider != null &&
                  shop!.merchantProvider!.isNotEmpty)
                _meta(t('pdf_payment_service_label'), shop.merchantProvider!),
              _meta(t('pdf_generated_on_label'), _today(t)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _meta(String label, String value) => pw.RichText(
        text: pw.TextSpan(children: [
          pw.TextSpan(
              text: '$label: ', style: pw.TextStyle(fontSize: 9, color: _ink2)),
          pw.TextSpan(
              text: value,
              style: pw.TextStyle(
                  fontSize: 9, fontWeight: pw.FontWeight.bold, color: _ink)),
        ]),
      );

  static pw.Widget _title(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 10),
        child: pw.Text(text.toUpperCase(),
            style: pw.TextStyle(
                fontSize: 9.5,
                letterSpacing: 0.8,
                fontWeight: pw.FontWeight.bold,
                color: _ink)),
      );

  static pw.Widget _section(String title, List<(String, String)> rows) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _title(title),
        pw.Table(
          border: pw.TableBorder(
            horizontalInside: pw.BorderSide(color: _line, width: 0.5),
            top: pw.BorderSide(color: _line, width: 0.5),
            bottom: pw.BorderSide(color: _line, width: 0.5),
          ),
          columnWidths: const {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(2),
          },
          children: [
            for (final row in rows)
              pw.TableRow(children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 7),
                  child: pw.Text(row.$1,
                      style: pw.TextStyle(fontSize: 10, color: _ink2)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 7),
                  child: pw.Text(row.$2,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: _ink)),
                ),
              ]),
          ],
        ),
      ],
    );
  }

  static pw.Widget _payments(VendorAnalytics a, String Function(String) t) {
    final providers = a.revenueByProvider.entries.toList()
      ..sort((x, y) => y.value.compareTo(x.value));
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _title(t('digital_payments_label')),
        pw.Text(
          t('payments_found_in_history')
              .replaceAll('{n}', '${a.verifiedCount}')
              .replaceAll('{total}', '${a.orderCount}'),
          style: pw.TextStyle(fontSize: 9, color: _ink2),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          a.mismatchCount == 0
              ? t('pdf_no_mismatch')
              : t(a.mismatchCount > 1
                      ? 'pdf_mismatch_plural'
                      : 'pdf_mismatch_singular')
                  .replaceAll('{n}', '${a.mismatchCount}'),
          style: pw.TextStyle(fontSize: 9, color: _ink2),
        ),
        pw.SizedBox(height: 10),
        if (providers.isEmpty)
          pw.Text(t('no_payments_recorded'),
              style: pw.TextStyle(fontSize: 10, color: _ink2))
        else
          pw.Table(
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(color: _line, width: 0.5),
              top: pw.BorderSide(color: _line, width: 0.5),
              bottom: pw.BorderSide(color: _line, width: 0.5),
            ),
            columnWidths: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(2),
            },
            children: [
              for (final e in providers)
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 7),
                    child: pw.Text(e.key,
                        style: pw.TextStyle(fontSize: 10, color: _ink2)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 7),
                    child: pw.Text(Money.format(e.value),
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: _ink)),
                  ),
                ]),
            ],
          ),
      ],
    );
  }

  static pw.Widget _readiness(VendorAnalytics a, String Function(String) t) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _title(t('readiness_title')),
            pw.RichText(
              text: pw.TextSpan(children: [
                pw.TextSpan(
                    text: '${a.readinessScore.round()}',
                    style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: _copper)),
                pw.TextSpan(
                    text: ' / 100',
                    style: pw.TextStyle(fontSize: 10, color: _ink2)),
              ]),
            ),
          ],
        ),
        for (final p in a.readinessParts)
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 9),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(p.label,
                        style: pw.TextStyle(fontSize: 10, color: _ink)),
                    pw.Text('${p.score.round()} / 25',
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: _ink)),
                  ],
                ),
                pw.SizedBox(height: 3),
                pw.Stack(children: [
                  pw.Container(
                      height: 4, decoration: pw.BoxDecoration(color: _line)),
                  pw.Container(
                    height: 4,
                    width: (p.score / 25).clamp(0.0, 1.0) * 515,
                    decoration: pw.BoxDecoration(color: _copper),
                  ),
                ]),
                pw.SizedBox(height: 2),
                pw.Text(p.detail,
                    style: pw.TextStyle(fontSize: 8, color: _ink2)),
              ],
            ),
          ),
      ],
    );
  }
}
