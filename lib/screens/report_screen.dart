import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weight_entry.dart';
import '../providers/weight_providers.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(weightEntriesProvider);
    final average = ref.watch(sevenDayAverageProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFD),
      appBar: AppBar(
        title: const Text('レポート'),
        backgroundColor: const Color(0xFFFFFBFD),
        foregroundColor: const Color(0xFFB83283),
        elevation: 0,
      ),
      body: entriesAsync.when(
        data: (entries) =>
            _ReportBody(entries: entries, sevenDayAverage: average),
        error: (error, stackTrace) =>
            Center(child: Text('読み込みに失敗しました: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.entries, required this.sevenDayAverage});

  final List<WeightEntry> entries;
  final double? sevenDayAverage;

  @override
  Widget build(BuildContext context) {
    final latest = entries.isNotEmpty ? entries.first : null;
    final previous = entries.length > 1 ? entries[1] : null;
    final latestWeight = latest?.weightKg;
    final previousDiff = latestWeight == null || previous == null
        ? null
        : latestWeight - previous.weightKg;
    final effectiveAverage = sevenDayAverage ?? latestWeight;
    final remaining = latestWeight == null
        ? null
        : (latestWeight - targetWeightKg).clamp(0, double.infinity).toDouble();
    final averageDiff = latestWeight == null || effectiveAverage == null
        ? null
        : latestWeight - effectiveAverage;
    final rows = _recentRows(entries, effectiveAverage);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 860;
        final content = isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 13,
                    child: _MainReportColumn(
                      latest: latest,
                      rows: rows,
                      latestWeight: latestWeight,
                      previousDiff: previousDiff,
                      sevenDayAverage: effectiveAverage,
                      averageDiff: averageDiff,
                      remaining: remaining,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    flex: 6,
                    child: _ViewerMessagePanel(
                      latestWeight: latestWeight,
                      previousDiff: previousDiff,
                      remaining: remaining,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _MainReportColumn(
                    latest: latest,
                    rows: rows,
                    latestWeight: latestWeight,
                    previousDiff: previousDiff,
                    sevenDayAverage: effectiveAverage,
                    averageDiff: averageDiff,
                    remaining: remaining,
                  ),
                  const SizedBox(height: 16),
                  _ViewerMessagePanel(
                    latestWeight: latestWeight,
                    previousDiff: previousDiff,
                    remaining: remaining,
                  ),
                ],
              );

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
          child: content,
        );
      },
    );
  }

  List<_ReportRowData> _recentRows(
    List<WeightEntry> source,
    double? fallbackAverage,
  ) {
    final sorted = [...source]..sort((a, b) => b.date.compareTo(a.date));
    return List.generate(7, (index) {
      if (index >= sorted.length) return _ReportRowData.empty();
      final entry = sorted[index];
      final previous = index + 1 < sorted.length ? sorted[index + 1] : null;
      return _ReportRowData(
        date: entry.date,
        weight: entry.weightKg,
        diff: previous == null ? null : entry.weightKg - previous.weightKg,
        average: fallbackAverage,
      );
    });
  }
}

class _MainReportColumn extends StatelessWidget {
  const _MainReportColumn({
    required this.latest,
    required this.rows,
    required this.latestWeight,
    required this.previousDiff,
    required this.sevenDayAverage,
    required this.averageDiff,
    required this.remaining,
  });

  final WeightEntry? latest;
  final List<_ReportRowData> rows;
  final double? latestWeight;
  final double? previousDiff;
  final double? sevenDayAverage;
  final double? averageDiff;
  final double? remaining;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ReportHeader(latest: latest),
        const SizedBox(height: 12),
        const _RibbonTitle(),
        const SizedBox(height: 10),
        _SevenDayTable(rows: rows),
        const SizedBox(height: 6),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('※7日平均は、その日を含む過去7日間の平均体重です。'),
        ),
        const SizedBox(height: 12),
        _SummaryCards(
          latestWeight: latestWeight,
          sevenDayAverage: sevenDayAverage,
          averageDiff: averageDiff,
          remaining: remaining,
          previousDiff: previousDiff,
        ),
        const SizedBox(height: 10),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('💡毎日の積み重ねが、未来の自分をつくりますわっ！ 今日も本当におつかれさまでしたっ✨'),
        ),
      ],
    );
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({required this.latest});

  final WeightEntry? latest;

  @override
  Widget build(BuildContext context) {
    final weight = latest?.weightKg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF7BAC), width: 2),
      ),
      child: Row(
        children: [
          const Text(
            '本日の\n体重',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFF4081),
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(width: 16),
          const Text('⚖️', style: TextStyle(fontSize: 34)),
          const SizedBox(width: 10),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Color(0xFF191919),
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Noto Sans JP',
                  ),
                  children: [
                    TextSpan(
                      text: weight == null
                          ? '--.-kg'
                          : '${weight.toStringAsFixed(1)}kg',
                      style: const TextStyle(
                        color: Color(0xFFF50057),
                        fontSize: 54,
                      ),
                    ),
                    const TextSpan(
                      text: ' でしたわー!! ✨',
                      style: TextStyle(fontSize: 32),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RibbonTitle extends StatelessWidget {
  const _RibbonTitle();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4081),
        borderRadius: BorderRadius.circular(2),
      ),
      child: const Text(
        '📋 直近７日間の体重記録',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SevenDayTable extends StatelessWidget {
  const _SevenDayTable({required this.rows});

  final List<_ReportRowData> rows;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Table(
        border: TableBorder.all(color: const Color(0xFFFFD5E4)),
        columnWidths: const {
          0: FlexColumnWidth(1.8),
          1: FlexColumnWidth(1.1),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1.7),
        },
        children: [
          _tableRow(const [
            Text('日付（JST）'),
            Text('体重'),
            Text('前日比'),
            Text('7日平均'),
          ], isHeader: true),
          ...rows.map((row) => _tableRow(row.cells)),
        ],
      ),
    );
  }

  TableRow _tableRow(List<Widget> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? const Color(0xFFFF4081) : Colors.white,
      ),
      children: cells
          .map(
            (cell) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              child: DefaultTextStyle.merge(
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isHeader ? Colors.white : const Color(0xFF1F1F1F),
                  fontSize: isHeader ? 18 : 19,
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

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({
    required this.latestWeight,
    required this.sevenDayAverage,
    required this.averageDiff,
    required this.remaining,
    required this.previousDiff,
  });

  final double? latestWeight;
  final double? sevenDayAverage;
  final double? averageDiff;
  final double? remaining;
  final double? previousDiff;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 560;
        final cards = [
          _SummaryCard(
            title: '🎯 目標体重',
            value: '75.0',
            unit: 'kg',
            footer: _remainingText(remaining),
            color: const Color(0xFFF50057),
          ),
          _SummaryCard(
            title: '📈 過去７日平均',
            value: _formatNumber(sevenDayAverage),
            unit: 'kg',
            footer: _diffText('前日比', averageDiff),
            color: const Color(0xFF2563EB),
          ),
          _SummaryCard(
            title: '🚩 目標まであと',
            value: _formatNumber(remaining),
            unit: 'kg',
            footer: _diffText('前日比', previousDiff),
            color: const Color(0xFF168A2F),
          ),
        ];
        if (narrow) {
          return Column(
            children: cards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: card,
                  ),
                )
                .toList(),
          );
        }
        return Row(
          children: cards
              .map(
                (card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: card,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.footer,
    required this.color,
  });

  final String title;
  final String value;
  final String unit;
  final String footer;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: color,
                fontFamily: 'Noto Sans JP',
                fontWeight: FontWeight.w900,
              ),
              children: [
                TextSpan(text: value, style: const TextStyle(fontSize: 34)),
                TextSpan(text: unit, style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            footer,
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _ViewerMessagePanel extends StatelessWidget {
  const _ViewerMessagePanel({
    required this.latestWeight,
    required this.previousDiff,
    required this.remaining,
  });

  final double? latestWeight;
  final double? previousDiff;
  final double? remaining;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE4EF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFF9BC2)),
          ),
          child: Text(
            '測定日：${_formatJstDate(DateTime.now())} JST',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(42),
            border: Border.all(color: const Color(0xFFFF8DB8), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '視聴者さん♪',
                style: TextStyle(
                  color: Color(0xFFF50057),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '本日は ${_formatNumber(latestWeight)}kg でしたわー!!',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '前日より ${_formatSigned(previousDiff)}kg、7日平均もチェックですの〜✨',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(
                  color: Color(0xFFFF8DB8),
                  thickness: 1,
                  height: 1,
                ),
              ),
              Text(
                'この調子で、ゆるやかでも確実に減少傾向を続けていきますわ！\n焦らずコツコツが一番ですのっ♪\n一緒に目標の75kgまで、あと ${_formatNumber(remaining)}kg がんばりましょうねっ💪💕',
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.75,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(
              left: 6,
              top: 30,
              child: Text(
                '✦',
                style: TextStyle(color: Color(0xFFFF8DB8), fontSize: 28),
              ),
            ),
            const Positioned(
              right: 2,
              top: 4,
              child: Text(
                '✦',
                style: TextStyle(color: Color(0xFFFF8DB8), fontSize: 28),
              ),
            ),
            Image.asset(
              'assets/images/character_high_touch.png',
              semanticLabel: 'レポート応援キャラクター',
              fit: BoxFit.contain,
            ),
          ],
        ),
      ],
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
            ? const Color(0xFFF50057)
            : diff! < 0
            ? const Color(0xFF2563EB)
            : const Color(0xFF4B5563),
      ),
    ),
    Text(
      average == null ? '--' : '${average!.toStringAsFixed(2)}kg',
      style: const TextStyle(color: Color(0xFFF50057)),
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
String _remainingText(double? value) => '目標まであと ${_formatNumber(value)}kg';
String _diffText(String label, double? value) =>
    '$label ${_formatSigned(value)}kg';

String _formatJstDate(DateTime date) {
  const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
  final weekday = weekdays[date.weekday - 1];
  return '${date.year}/${date.month}/${date.day}（$weekday）';
}
