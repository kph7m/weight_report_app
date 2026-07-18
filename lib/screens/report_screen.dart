import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weight_entry.dart';
import '../providers/weight_providers.dart';
import 'home_screen.dart';

const _reportPink = Color(0xFFFF3B86);
const _deepPink = Color(0xFFF50057);
const _blue = Color(0xFF2563EB);
const _ink = Color(0xFF171717);
const _reportCharacterScale = 1.7;
const _weightInputIconAsset = 'assets/images/weight_input_icon.png';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(weightEntriesProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFD),
      body: SafeArea(
        child: entriesAsync.when(
          data: (entries) => _ReportBody(entries: entries),
          error: (error, stackTrace) =>
              Center(child: Text('読み込みに失敗しました: $error')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.entries});

  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    final latest = entries.isNotEmpty ? entries.first : null;
    final previous = entries.length > 1 ? entries[1] : null;
    final latestWeight = latest?.weightKg;
    final previousDiff = latestWeight == null || previous == null
        ? null
        : latestWeight - previous.weightKg;
    final remaining = latestWeight == null
        ? null
        : (latestWeight - targetWeightKg).clamp(0, double.infinity).toDouble();
    final rows = _recentRows(entries);

    return LayoutBuilder(
      builder: (context, constraints) {
        const designSize = Size(922, 1706);
        const scale = 1.0;
        return Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: designSize.width,
              height: designSize.height,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
                child: DefaultTextStyle.merge(
                  style: const TextStyle(
                    color: _ink,
                    fontFamily: 'Noto Sans JP',
                    fontWeight: FontWeight.w700,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ReportHeroHeader(latest: latest, scale: scale),
                            const SizedBox(height: 8),
                            _ReportTitleArea(
                              date: latest?.date ?? DateTime.now(),
                              scale: scale,
                            ),
                            const SizedBox(height: 8),
                            _SevenDayTable(rows: rows, scale: scale),
                            const SizedBox(height: 20),
                            _LayeredReportBottomSection(
                              remaining: remaining,
                              latestWeight: latestWeight,
                              previousDiff: previousDiff,
                              scale: scale,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<_ReportRowData> _recentRows(List<WeightEntry> source) {
    final sorted = [...source]..sort((a, b) => b.date.compareTo(a.date));
    return List.generate(7, (index) {
      if (index >= sorted.length) return _ReportRowData.empty();
      final entry = sorted[index];
      final previous = index + 1 < sorted.length ? sorted[index + 1] : null;
      return _ReportRowData(
        date: entry.date,
        weight: entry.weightKg,
        diff: previous == null ? null : entry.weightKg - previous.weightKg,
        average: rollingSevenDayAverage(sorted, index),
      );
    });
  }
}

double? rollingSevenDayAverage(List<WeightEntry> sortedEntries, int index) {
  if (index < 0 || index >= sortedEntries.length) return null;

  final entryDate = _dateOnly(sortedEntries[index].date);
  final windowStart = entryDate.subtract(const Duration(days: 6));
  final windowEntries = sortedEntries.where((entry) {
    final date = _dateOnly(entry.date);
    return !date.isBefore(windowStart) && !date.isAfter(entryDate);
  }).toList();

  if (windowEntries.isEmpty) return null;

  final total = windowEntries.fold<double>(
    0,
    (sum, entry) => sum + entry.weightKg,
  );
  return total / windowEntries.length;
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

class _ReportHeroHeader extends StatelessWidget {
  const _ReportHeroHeader({required this.latest, required this.scale});

  final WeightEntry? latest;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final weight = latest?.weightKg;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 14 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0xFFFF7BAC), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '本日の\n体重',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _reportPink,
                  fontSize: 30 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1.14,
                ),
              ),
              SizedBox(width: 28 * scale),
              Icon(
                Icons.monitor_weight_outlined,
                color: _blue,
                size: 58 * scale,
              ),
              SizedBox(width: 22 * scale),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: _ink,
                        fontFamily: 'Noto Sans JP',
                        fontWeight: FontWeight.w900,
                      ),
                      children: [
                        TextSpan(
                          text: weight == null
                              ? '--.-kg'
                              : '${weight.toStringAsFixed(1)}kg',
                          style: TextStyle(
                            color: _deepPink,
                            fontSize: 76 * scale,
                          ),
                        ),
                        TextSpan(
                          text: ' でしたわー!!',
                          style: TextStyle(fontSize: 37 * scale),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Icon(Icons.auto_awesome, color: Colors.amber, size: 36 * scale),
            ],
          ),
          SizedBox(height: 6 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.local_florist, color: _reportPink, size: 34 * scale),
              Expanded(
                child: Text(
                  '今日も記録えらいですわっ♪ 継続が一番の近道ですの！',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23 * scale,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Icon(Icons.local_florist, color: _reportPink, size: 34 * scale),
            ],
          ),
        ],
      ),
    );
  }
}

class _MeasuredDateBadge extends StatelessWidget {
  const _MeasuredDateBadge({required this.date, required this.scale});

  final DateTime date;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 28 * scale,
        vertical: 7 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4EF),
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(color: const Color(0xFFFF9BC2)),
      ),
      child: Text(
        '測定日：${_formatJstDate(date)}',
        style: TextStyle(fontSize: 24 * scale, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _ReportTitleArea extends StatelessWidget {
  const _ReportTitleArea({required this.date, required this.scale});

  final DateTime date;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MeasuredDateBadge(date: date, scale: scale),
            SizedBox(height: 12 * scale),
            _RibbonTitle(scale: scale),
          ],
        ),
        Positioned(
          right: 14 * scale,
          child: _WeightInputShortcutButton(scale: scale),
        ),
      ],
    );
  }
}

class _RibbonTitle extends StatelessWidget {
  const _RibbonTitle({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 52 * scale,
        vertical: 9 * scale,
      ),
      decoration: BoxDecoration(
        color: _reportPink,
        borderRadius: BorderRadius.circular(3 * scale),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment, color: Colors.white, size: 32 * scale),
          SizedBox(width: 10 * scale),
          Text(
            '直近７日間の体重記録',
            style: TextStyle(
              color: Colors.white,
              fontSize: 31 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SevenDayTable extends StatelessWidget {
  const _SevenDayTable({required this.rows, required this.scale});

  final List<_ReportRowData> rows;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10 * scale),
      child: Table(
        border: TableBorder.all(color: const Color(0xFFFFD5E4)),
        columnWidths: const {
          0: FlexColumnWidth(1.55),
          1: FlexColumnWidth(1.15),
          2: FlexColumnWidth(1.05),
          3: FlexColumnWidth(1.75),
        },
        children: [
          _tableRow([
            Text('日付'),
            Text('体重'),
            Text('前日比'),
            Text('7日平均\n（その日を含む過去7日間平均）'),
          ], isHeader: true),
          ...rows.map((row) => _tableRow(row.cells)),
        ],
      ),
    );
  }

  TableRow _tableRow(List<Widget> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(color: isHeader ? _reportPink : Colors.white),
      children: cells
          .map(
            (cell) => Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 5 * scale,
                vertical: isHeader ? 9 * scale : 12 * scale,
              ),
              child: DefaultTextStyle.merge(
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isHeader ? Colors.white : _ink,
                  fontSize: isHeader ? 20 * scale : 25 * scale,
                  height: 1.18,
                  fontWeight: isHeader ? FontWeight.w900 : FontWeight.w700,
                ),
                child: cell,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _WeightInputShortcutButton extends StatelessWidget {
  const _WeightInputShortcutButton({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '体重入力画面を開く',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const HomeScreen(forceInput: true),
            ),
          );
        },
        child: Image.asset(
          _weightInputIconAsset,
          width: 78 * scale,
          height: 78 * scale,
          semanticLabel: '体重入力アイコン',
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.remaining, required this.scale});

  final double? remaining;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryCard(
        icon: Icons.gps_fixed,
        title: '目標体重',
        value: '75.0',
        unit: 'kg',
        footer: '目標まであと\n${_formatNumber(remaining)}kg',
        color: _deepPink,
        scale: scale,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(children: [cards[0]]);
        }
        return Row(
          children: [
            Expanded(child: cards[0]),
            const Spacer(),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.footer,
    required this.color,
    required this.scale,
  });

  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final String footer;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 31 * scale),
              SizedBox(width: 8 * scale),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 21 * scale,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: color,
                fontFamily: 'Noto Sans JP',
                fontWeight: FontWeight.w900,
              ),
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(fontSize: 54 * scale),
                ),
                TextSpan(
                  text: unit,
                  style: TextStyle(fontSize: 26 * scale),
                ),
              ],
            ),
          ),
          SizedBox(height: 8 * scale),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8 * scale),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(8 * scale),
              border: Border.all(color: color.withValues(alpha: 0.16)),
            ),
            child: Text(
              footer,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 18 * scale,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LayeredReportBottomSection extends StatelessWidget {
  const _LayeredReportBottomSection({
    required this.remaining,
    required this.latestWeight,
    required this.previousDiff,
    required this.scale,
  });

  final double? remaining;
  final double? latestWeight;
  final double? previousDiff;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final messageWidth = constraints.maxWidth * 0.52;
        final cardWidth = constraints.maxWidth * 0.52;

        return SizedBox(
          height: 760 * scale,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: 0,
                width: cardWidth,
                child: _SummaryCards(remaining: remaining, scale: scale),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                width: 420 * scale,
                height: 500 * scale,
                child: _ReportCharacterArt(scale: scale),
              ),
              Positioned(
                left: 0,
                top: 244 * scale,
                width: messageWidth,
                child: _ViewerMessagePanel(
                  latestWeight: latestWeight,
                  previousDiff: previousDiff,
                  scale: scale,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReportCharacterArt extends StatelessWidget {
  const _ReportCharacterArt({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      children: [
        Positioned(
          left: 2 * scale,
          top: 50 * scale,
          child: _Sparkle(scale: scale),
        ),
        Positioned(
          right: 8 * scale,
          top: 28 * scale,
          child: _Sparkle(scale: scale),
        ),
        Positioned(
          right: -50 * scale,
          bottom: 0,
          child: Transform.scale(
            scale: _reportCharacterScale,
            alignment: Alignment.bottomRight,
            child: Image.asset(
              'assets/images/character_report.png',
              semanticLabel: 'レポート応援キャラクター',
              fit: BoxFit.contain,
              height: 500 * scale,
            ),
          ),
        ),
      ],
    );
  }
}

class _ViewerMessagePanel extends StatelessWidget {
  const _ViewerMessagePanel({
    required this.latestWeight,
    required this.previousDiff,
    required this.scale,
  });

  final double? latestWeight;
  final double? previousDiff;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        30 * scale,
        22 * scale,
        24 * scale,
        72 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: const Color(0xFFFF8DB8), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '視聴者さん♪',
            style: TextStyle(
              color: _deepPink,
              fontSize: 31 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 14 * scale),
          _MessageRichLine(
            label: '本日は ',
            value: '${_formatNumber(latestWeight)}kg',
            suffix: ' でしたわー!!',
            scale: scale,
          ),
          _MessageRichLine(
            label: '前日より ',
            value: '${_formatSigned(previousDiff).replaceAll('−', '')}kg',
            suffix: previousDiff == null || previousDiff! >= 0
                ? ' ですの。'
                : ' 減って、',
            scale: scale,
          ),
          Text(
            '7日平均もしっかり下がってきてますの〜',
            style: TextStyle(
              fontSize: 18 * scale,
              height: 1.9,
              fontWeight: FontWeight.w900,
            ),
          ),
          Divider(
            color: const Color(0xFFFF8DB8),
            height: 28 * scale,
            thickness: 1,
          ),
          Text(
            'この調子で、ゆるやかでも\n確実に減少傾向が続いていますわ！\n\n焦らずコツコツが一番ですのっ♪\n\n一緒に目標の75kgを目指して、\nがんばりましょうねっ。',
            style: TextStyle(
              fontSize: 18 * scale,
              height: 1.65,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageRichLine extends StatelessWidget {
  const _MessageRichLine({
    required this.label,
    required this.value,
    required this.suffix,
    required this.scale,
  });

  final String label;
  final String value;
  final String suffix;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: _ink,
          fontFamily: 'Noto Sans JP',
          fontSize: 18 * scale,
          height: 1.9,
          fontWeight: FontWeight.w900,
        ),
        children: [
          TextSpan(text: label),
          TextSpan(
            text: value,
            style: const TextStyle(color: _deepPink),
          ),
          TextSpan(text: suffix),
        ],
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.auto_awesome,
      color: const Color(0xFFFF8DB8),
      size: 26 * scale,
    );
  }
}

class _ReportRowData {
  const _ReportRowData({this.date, this.weight, this.diff, this.average});
  const _ReportRowData.empty()
    : date = null,
      weight = null,
      diff = null,
      average = null;

  final DateTime? date;
  final double? weight;
  final double? diff;
  final double? average;

  List<Widget> get cells => [
    Text(date == null ? '--' : _formatJstDate(date!)),
    Text(weight == null ? '--' : '${weight!.toStringAsFixed(1)}kg'),
    Text(
      _formatSigned(diff),
      style: TextStyle(
        color: diff == null
            ? const Color(0xFF4B5563)
            : diff! > 0
            ? _deepPink
            : diff! < 0
            ? _blue
            : const Color(0xFF4B5563),
      ),
    ),
    Text(
      average == null ? '--' : '${average!.toStringAsFixed(2)}kg',
      style: const TextStyle(color: _deepPink),
    ),
  ];
}

String _formatNumber(double? value) =>
    value == null ? '--' : value.toStringAsFixed(1);
String _formatSigned(double? value) => value == null
    ? '±0.0'
    : '${value > 0
          ? '+'
          : value < 0
          ? '−'
          : '±'}${value.abs().toStringAsFixed(1)}';

String _formatJstDate(DateTime date) {
  const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
  final weekday = weekdays[date.weekday - 1];
  return '${date.year}/${date.month}/${date.day}（$weekday）';
}
