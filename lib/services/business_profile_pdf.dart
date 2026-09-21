import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/money.dart';
import '../models/models.dart';
import 'analytics_service.dart';

class BusinessProfilePdf {
  BusinessProfilePdf._();

  static const _disclaimer =
      'This file summarizes a business\'s activity as recorded in this app. It '
      'is not a credit decision, a financing guarantee, or an assessment by a '
      'financial institution. Figures are computed automatically from the '
      'shop\'s real orders.';

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String monthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';

  static String _today() {
    final n = DateTime.now();
    return '${n.day} ${_months[n.month - 1]} ${n.year}';
  }

  static PdfColor get _ink => const PdfColor.fromInt(0xFF2B2B2B);
  static PdfColor get _ink2 => const PdfColor.fromInt(0xFF5C5658);
  static PdfColor get _line => const PdfColor.fromInt(0xFFE8E2E3);
  static PdfColor get _tint => const PdfColor.fromInt(0xFFF6F3F4);
  static PdfColor get _copper => const PdfColor.fromInt(0xFFD2793F);

  static Future<List<int>> build({
    required Shop? shop,
    required VendorAnalytics a,
  }) async {
    final doc = pw.Document(
      title: 'Business profile — ${shop?.name ?? ''}',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 40),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 12),
          child: pw.Text(
            '${shop?.name ?? ''} · page ${context.pageNumber}/${context.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: _ink2),
          ),
        ),
        build: (context) => [
          _header(shop),
          pw.SizedBox(height: 22),
          _section('Marketplace history', [
            ('Orders fulfilled', '${a.orderCount}'),
            ('Sales volume', Money.format(a.revenue)),
            ('Average order value', Money.format(a.averageOrderValue)),
            ('Distinct customers', '${a.customerCount}'),
            ('Orders per customer', _repeat(a)),
          ]),
          pw.SizedBox(height: 16),
          _payments(a),
          pw.SizedBox(height: 16),
          _readiness(a),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFF6F3F4),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(_disclaimer,
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

  static pw.Widget _header(Shop? shop) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: _tint,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('BUSINESS PROFILE',
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
                _meta('City', shop.city!),
              if (shop?.createdAt != null)
                _meta('Active since', monthYear(shop!.createdAt!)),
              if (shop?.merchantProvider != null &&
                  shop!.merchantProvider!.isNotEmpty)
                _meta('Payment service', shop.merchantProvider!),
              _meta('Generated on', _today()),
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

  static pw.Widget _payments(VendorAnalytics a) {
    final providers = a.revenueByProvider.entries.toList()
      ..sort((x, y) => y.value.compareTo(x.value));
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _title('Digital payments'),
        pw.Text(
          '${a.verifiedCount} payment${a.verifiedCount > 1 ? 's' : ''} out of '
          '${a.orderCount} found in the merchant\'s banking history.',
          style: pw.TextStyle(fontSize: 9, color: _ink2),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          a.mismatchCount == 0
              ? 'No mismatch between amounts received and order totals.'
              : '${a.mismatchCount} order${a.mismatchCount > 1 ? 's' : ''} '
                  'show${a.mismatchCount > 1 ? '' : 's'} a mismatch between the '
                  'amount received and the amount due.',
          style: pw.TextStyle(fontSize: 9, color: _ink2),
        ),
        pw.SizedBox(height: 10),
        if (providers.isEmpty)
          pw.Text('No payments recorded.',
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

  static pw.Widget _readiness(VendorAnalytics a) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _title('Financial readiness'),
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
