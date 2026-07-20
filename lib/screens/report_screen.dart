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
    final comment =
        latest?.aiComment ?? generatedComment ?? aiCommentFailureMessage;

    return LayoutBuilder(
      builder: (context, constraints) {
        const designSize = Size(922, 1570);
        return ColoredBox(
          color: const Color(0xFFFFF8FB),
          child: Align(
            alignment: Alignment.topCenter,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: designSize.width,
                height: designSize.height,
                child: DefaultTextStyle.merge(
                  style: const TextStyle(
                    color: _ink,
                    fontFamily: appFontFamily,
                    fontWeight: FontWeight.w700,
                  ),
                  child: Stack(
                    children: [
                      const Positioned.fill(child: _ReportBackdrop()),
                      Positioned(
                        left: 28,
                        right: 28,
                        top: 18,
                        child: _TodayWeightCard(latest: latest),
                      ),
                      Positioned(
                        left: 28,
                        right: 28,
                        top: 337,
                        child: _HistoryCard(rows: rows),
                      ),
                      Positioned(
                        left: 28,
                        top: 865,
                        width: 450,
                        height: 565,
                        child: _MetanCommentPanel(comment: comment),
                      ),
                      const Positioned(
                        right: 5,
                        bottom: 40,
                        width: 500,
                        height: 680,
                        child: _ReportCharacter(),
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

class _ReportBackdrop extends StatelessWidget {
  const _ReportBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFFFF8FB),
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/report/report_background_tile.png',
                ),
                repeat: ImageRepeat.repeat,
                opacity: 0.62,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 190,
          child: Image.asset(
            'assets/images/report/report_bottom_lace_tile.png',
            fit: BoxFit.fill,
            excludeFromSemantics: true,
          ),
        ),
      ],
    );
  }
}

class _TodayWeightCard extends StatelessWidget {
  const _TodayWeightCard({required this.latest});

  final WeightEntry? latest;

  @override
  Widget build(BuildContext context) {
    final weight = latest?.weightKg;
    final remaining = weight == null
        ? null
        : (weight - targetWeightKg).clamp(0, double.infinity).toDouble();

    return Container(
      height: 312,
      padding: const EdgeInsets.fromLTRB(25, 16, 25, 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFFFFBDD2), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30D94A80),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ThreeSliceLabel(
                family: 'report_today_title',
                width: 250,
                height: 72,
                child: const Text(
                  '本日の体重',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: reportAccentFontFamily,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              Image.asset(
                'assets/images/report/report_sparkle_gold.png',
                width: 62,
                height: 62,
                excludeFromSemantics: true,
              ),
            ],
          ),
          Transform.translate(
            offset: const Offset(0, -35),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  weight == null ? '--.-' : weight.toStringAsFixed(1),
                  style: const TextStyle(
                    color: _deepPink,
                    fontFamily: reportAccentFontFamily,
                    fontSize: 95,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 9, left: 9),
                  child: Text(
                    'kg でしたわー！',
                    style: TextStyle(
                      color: _ink,
                      fontFamily: reportAccentFontFamily,
                      fontSize: 31,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBFC),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFFFCADC)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '目標体重　${targetWeightKg.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                    fontFamily: reportAccentFontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 34),
                Container(width: 2, height: 31, color: const Color(0xFFFFD3E1)),
                const SizedBox(width: 34),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: '目標まであと　'),
                      TextSpan(
                        text: '${remaining?.toStringAsFixed(1) ?? '--.-'} kg',
                        style: const TextStyle(color: _deepPink),
                      ),
                      const TextSpan(text: '　ですわ！'),
                    ],
                  ),
                  style: const TextStyle(
                    fontFamily: reportAccentFontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.rows});
  final List<_ReportRowData> rows;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 510,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 44,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 44, 18, 18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(34),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2BD94A80),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: _SevenDayTable(rows: rows),
            ),
          ),
          _ThreeSliceLabel(
            family: 'report_history_ribbon',
            width: 540,
            height: 92,
            child: const Text(
              '直近７日間の体重記録',
              style: TextStyle(
                color: Colors.white,
                fontFamily: reportAccentFontFamily,
                fontSize: 31,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Color(0x559A174D), blurRadius: 3)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreeSliceLabel extends StatelessWidget {
  const _ThreeSliceLabel({
    required this.family,
    required this.width,
    required this.height,
    required this.child,
  });

  final String family;
  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final capWidth = height * 1.18;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/report/${family}_left.png',
                width: capWidth,
                height: height,
                fit: BoxFit.fill,
                excludeFromSemantics: true,
              ),
              Expanded(
                child: Image.asset(
                  'assets/images/report/${family}_center.png',
                  height: height,
                  fit: BoxFit.fill,
                  excludeFromSemantics: true,
                ),
              ),
              Image.asset(
                'assets/images/report/${family}_right.png',
                width: capWidth,
                height: height,
                fit: BoxFit.fill,
                excludeFromSemantics: true,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: height * 0.72),
            child: FittedBox(fit: BoxFit.scaleDown, child: child),
          ),
        ],
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
      borderRadius: BorderRadius.circular(18),
      child: Table(
        border: TableBorder.all(color: const Color(0xFFFFDDE8), width: 1),
        columnWidths: const {
          0: FlexColumnWidth(1.35),
          1: FlexColumnWidth(1.08),
          2: FlexColumnWidth(1.06),
          3: FlexColumnWidth(1.25),
        },
        children: [
          _row(const [
            Text('日付'),
            Text('体重'),
            Text('前日比'),
            Text('7日平均'),
          ], header: true),
          ...rows.map((row) => _row(row.cells)),
        ],
      ),
    );
  }

  TableRow _row(List<Widget> cells, {bool header = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: header ? const Color(0xFFF75A99) : Colors.white,
      ),
      children: cells
          .map(
            (cell) => SizedBox(
              height: header ? 49 : 50,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: DefaultTextStyle.merge(
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: header ? Colors.white : _ink,
                      fontSize: header ? 22 : 21,
                      fontWeight: header ? FontWeight.w900 : FontWeight.w700,
                    ),
                    child: cell,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MetanCommentPanel extends StatelessWidget {
  const _MetanCommentPanel({required this.comment});
  final String comment;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/report/report_comment_panel_frame.png',
            fit: BoxFit.fill,
            excludeFromSemantics: true,
          ),
        ),
        Positioned(left: 32, right: 32, top: 13, child: _CommentHeading()),
        Positioned(
          left: 43,
          right: 43,
          top: 100,
          bottom: 72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  comment,
                  overflow: TextOverflow.fade,
                  style: const TextStyle(
                    color: Color(0xFF3F2C31),
                    fontFamily: appFontFamily,
                    fontSize: 19,
                    height: 1.75,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Image.asset(
                'assets/images/report/report_comment_divider.png',
                width: double.infinity,
                height: 18,
                fit: BoxFit.fill,
                excludeFromSemantics: true,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Image.asset(
                  'assets/images/report/report_comment_ornament.png',
                  width: 78,
                  height: 52,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentHeading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/report/report_comment_heading_left.png',
                width: 118,
                height: 76,
                fit: BoxFit.fill,
                excludeFromSemantics: true,
              ),
              Expanded(
                child: Image.asset(
                  'assets/images/report/report_comment_heading_center.png',
                  height: 76,
                  fit: BoxFit.fill,
                  excludeFromSemantics: true,
                ),
              ),
              Image.asset(
                'assets/images/report/report_comment_heading_right.png',
                width: 118,
                height: 76,
                fit: BoxFit.fill,
                excludeFromSemantics: true,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 70),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'めたんからのひとこと',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: reportAccentFontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCharacter extends StatelessWidget {
  const _ReportCharacter();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          bottom: 2,
          child: Container(
            width: 310,
            height: 62,
            decoration: const BoxDecoration(
              color: Color(0x55F76B9F),
              borderRadius: BorderRadius.all(Radius.elliptical(999, 180)),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 55,
          child: Image.asset(
            'assets/images/report/report_sparkle_gold.png',
            width: 65,
            height: 65,
            excludeFromSemantics: true,
          ),
        ),
        Positioned(
          right: 2,
          top: 35,
          child: Image.asset(
            'assets/images/report/report_sparkle_pink.png',
            width: 64,
            height: 64,
            excludeFromSemantics: true,
          ),
        ),
        Image.asset(
          'assets/images/character_report.png',
          height: 665,
          fit: BoxFit.contain,
          semanticLabel: 'レポート応援キャラクター',
        ),
      ],
    );
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
