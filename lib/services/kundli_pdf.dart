import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../models.dart';

class KundliPdf {
  static Future<File> buildFile({
    required AppUser user,
    required Chart chart,
    required AppLocalizations l,
  }) async {
    final doc = pw.Document();
    final name = user.name.isNotEmpty ? user.name : l.seeker;
    final dateFmt = _formatDob(user.dob);
    final timeFmt = _formatTime(user.birthTime);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          pw.Text(l.kundliPdfTitle, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(name, style: const pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 16),
          pw.Text(l.kundliBasicDetails, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          _kv(l.kundliLabelName, name),
          _kv(l.kundliLabelDate, dateFmt),
          _kv(l.kundliLabelTime, timeFmt),
          _kv(l.kundliLabelPlace, user.birthPlace),
          _kv(l.kundliLabelLatitude, user.latitude?.toStringAsFixed(2) ?? '—'),
          _kv(l.kundliLabelLongitude, user.longitude?.toStringAsFixed(2) ?? '—'),
          _kv(
            l.kundliLabelTimezone,
            chart.timezoneOffset.isNotEmpty
                ? 'GMT${chart.timezoneOffset.replaceFirst('+', '+')}'
                : chart.timezone,
          ),
          _kv(l.kundliLabelSunrise, chart.sunrise.isNotEmpty ? chart.sunrise : '—'),
          _kv(l.kundliLabelSunset, chart.sunset.isNotEmpty ? chart.sunset : '—'),
          _kv(l.kundliLabelAyanamsha, chart.ayanamsa > 0 ? chart.ayanamsa.toStringAsFixed(5) : '—'),
          _kv(l.kundliLabelLagna, '${chart.risingSign} ${chart.risingDegreeInSign.toStringAsFixed(2)}°'),
          _kv(l.kundliLabelMoon, '${chart.moonSign} (${chart.nakshatra})'),
          _kv(l.kundliLabelSun, chart.sunSign),
          pw.SizedBox(height: 16),
          pw.Text(l.kundliPlanets, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: [
              l.kundliColPlanet,
              l.kundliColSign,
              l.kundliColDegree,
              l.kundliColHouse,
              l.kundliColNakshatra,
            ],
            data: chart.planets
                .map((p) => [
                      p.name,
                      p.sign,
                      '${p.degreeInSign.toStringAsFixed(2)}°',
                      '${p.house}',
                      p.nakshatra,
                    ])
                .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
          ),
          if (chart.manglik != null) ...[
            pw.SizedBox(height: 16),
            pw.Text(l.kundliManglikAnalysis, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Text(l.kundliResult(chart.manglik!.label), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(chart.manglik!.summary, style: const pw.TextStyle(fontSize: 10)),
            for (final r in chart.manglik!.reasons) pw.Bullet(text: r),
          ],
          if (chart.dasha != null) ...[
            pw.SizedBox(height: 16),
            pw.Text(l.kundliVimshottari, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Text(
              '${l.kundliBalanceOf(chart.dasha!.balanceLord, chart.dasha!.balanceYears.toStringAsFixed(3))} (${l.kundliMoonIn(chart.dasha!.moonNakshatra)})',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: [l.kundliMahadasha, l.kundliColStart, l.kundliColEnd, l.kundliColYears],
              data: chart.dasha!.mahadashas
                  .map((d) => [d.planet, d.start, d.end, d.years.toStringAsFixed(2)])
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              cellStyle: const pw.TextStyle(fontSize: 9),
            ),
          ],
          pw.SizedBox(height: 20),
          pw.Text(
            l.guidanceOnly,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final safe = name.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
    final file = File('${dir.path}/MyFuture_Kundli_$safe.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  static Future<void> share({
    required AppUser user,
    required Chart chart,
    required AppLocalizations l,
  }) async {
    final file = await buildFile(user: user, chart: chart, l: l);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: l.kundliPdfShareText(user.name.isNotEmpty ? user.name : l.seeker),
        subject: l.kundliPdfTitle,
      ),
    );
  }

  static Future<void> download({
    required AppUser user,
    required Chart chart,
    required AppLocalizations l,
  }) async {
    final file = await buildFile(user: user, chart: chart, l: l);
    await Printing.sharePdf(bytes: await file.readAsBytes(), filename: file.uri.pathSegments.last);
  }

  static pw.Widget _kv(String k, String v) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(width: 90, child: pw.Text(k, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
            pw.Expanded(child: pw.Text(v, style: const pw.TextStyle(fontSize: 10))),
          ],
        ),
      );

  static String _formatDob(String dob) {
    final d = DateTime.tryParse(dob);
    if (d == null) return dob;
    return DateFormat('d MMMM y').format(d);
  }

  static String _formatTime(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return t;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final dt = DateTime(2000, 1, 1, h, m);
    return DateFormat('hh:mm a').format(dt);
  }
}
