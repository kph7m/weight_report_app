import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weight_entry.dart';
import '../providers/ai_comment_providers.dart';
import '../providers/weight_providers.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

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
    final generationState = ref.watch(aiCommentControllerProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFD),
      body: SafeArea(
        child: entriesAsync.when(
          data: (entries) => _ReportBody(
            entries: entries,
            generatedComment: generationState.comment,
          ),
          error: (error, stackTrace) =>
              Center(child: Text('読み込みに失敗しました: $error')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
      bottomNavigationBar: const _ReportFooter(),
    );
  }
}

class _ReportFooter extends StatelessWidget {
  const _ReportFooter();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        return Container(
          height: compact ? 84 : 116,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(compact ? 28 : 44),
            ),
            border: const Border(top: BorderSide(color: Color(0xFFFFE2EC))),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22D54A7F),
                blurRadius: 18,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            minimum: EdgeInsets.symmetric(horizontal: compact ? 8 : 34),
            child: Row(
              children: [
                Expanded(
                  child: _FooterDestination(
                    label: 'ホーム',
                    icon: Icons.home_rounded,
                    selected: true,
                    compact: compact,
                    onPressed: () {},
                  ),
                ),
                Expanded(
                  child: _FooterDestination(
                    label: 'グラフ',
                    icon: Icons.show_chart_rounded,
                    compact: compact,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('グラフ画面は準備中です')),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _FooterDestination(
                    label: '記録',
                    icon: Icons.edit_note_rounded,
                    compact: compact,
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => const HomeScreen(forceInput: true),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _FooterDestination(
                    label: '設定',
                    icon: Icons.settings_outlined,
                    compact: compact,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FooterDestination extends StatelessWidget {
  const _FooterDestination({
    required this.label,
    required this.icon,
    required this.compact,
    required this.onPressed,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final bool compact;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _reportPink : const Color(0xFF594B4E);
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 6 : 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: compact ? 30 : 43),
              SizedBox(height: compact ? 2 : 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontFamily: reportAccentFontFamily,
                  fontSize: compact ? 12 : 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.entries, required this.generatedComment});

  final List<WeightEntry> entries;
  final String? generatedComment;

  @override
  Widget build(BuildContext context) {
    final latest = entries.isNotEmpty ? entries.first : null;
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
                              aiComment:
                                  latest?.aiComment ??
                                  generatedComment ??
                                  aiCommentFailureMessage,
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
    final remaining = weight == null
        ? null
        : (weight - targetWeightKg).clamp(0, double.infinity).toDouble();
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
                  fontFamily: reportAccentFontFamily,
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
                        fontFamily: reportAccentFontFamily,
                        color: _ink,
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
                  '目標体重　${targetWeightKg.toStringAsFixed(1)}kg　'
                  '目標まであと　${remaining?.toStringAsFixed(1) ?? '--.-'}kg　ですわ！',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: reportAccentFontFamily,
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
      clipBehavior: Clip.none,
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
            Text('7日平均'),
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
          width: 116 * scale,
          height: 116 * scale,
          semanticLabel: '体重入力アイコン',
        ),
      ),
    );
  }
}

class _LayeredReportBottomSection extends StatelessWidget {
  const _LayeredReportBottomSection({
    required this.aiComment,
    required this.scale,
  });

  final String aiComment;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final messageWidth = constraints.maxWidth * 0.52;
        return SizedBox(
          height: 760 * scale,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 0,
                bottom: 0,
                width: 420 * scale,
                height: 500 * scale,
                child: _ReportCharacterArt(scale: scale),
              ),
              Positioned(
                left: 0,
                top: 0,
                width: messageWidth,
                child: _ViewerMessagePanel(aiComment: aiComment, scale: scale),
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
  const _ViewerMessagePanel({required this.aiComment, required this.scale});

  final String aiComment;
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
      child: Text(
        aiComment,
        style: TextStyle(
          fontFamily: appFontFamily,
          fontSize: 18 * scale,
          height: 1.65,
          fontWeight: FontWeight.w600,
        ),
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
