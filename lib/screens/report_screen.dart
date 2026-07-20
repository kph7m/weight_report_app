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
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0xFFFFF8FB),
            image: DecorationImage(
              image: AssetImage('assets/images/report/report_background.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black],
              stops: [0, 0.32],
            ).createShader(bounds),
            child: Image.asset(
              'assets/images/report/report_background_clouds.jpg',
              width: double.infinity,
              fit: BoxFit.fitWidth,
              excludeFromSemantics: true,
            ),
          ),
        ),
        Scaffold(
          extendBody: true,
          backgroundColor: Colors.transparent,
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
        ),
      ],
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
            color: Colors.white.withValues(alpha: 0.9),
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
                    label: 'レポート',
                    icon: Icons.assignment_rounded,
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
        return Align(
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
                    Positioned(
                      left: 28,
                      right: 28,
                      top: 18,
                      child: _TodayWeightCard(latest: latest),
                    ),
                    Positioned(
                      left: 28,
                      right: 28,
                      top: 286,
                      child: _HistoryCard(rows: rows),
                    ),
                    Positioned(
                      left: 28,
                      top: 814,
                      width: 450,
                      height: 565,
                      child: _MetanCommentPanel(comment: comment),
                    ),
                    const Positioned(
                      right: -25,
                      bottom: 40,
                      width: 580,
                      height: 767,
                      child: _ReportCharacter(),
                    ),
                  ],
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
      height: 248,
      padding: const EdgeInsets.fromLTRB(25, 17, 25, 20),
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
              const SizedBox(width: 30),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        weight == null ? '--.-' : weight.toStringAsFixed(1),
                        style: const TextStyle(
                          color: _deepPink,
                          fontFamily: reportAccentFontFamily,
                          fontSize: 84,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8, left: 8),
                        child: Text(
                          'kg でしたわー！',
                          style: TextStyle(
                            color: _ink,
                            fontFamily: reportAccentFontFamily,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Image.asset(
                'assets/images/report/report_sparkle_pink.png',
                width: 48,
                height: 48,
                excludeFromSemantics: true,
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _GoalPill(
                  icon: Icons.emoji_events_rounded,
                  iconColor: Color(0xFFFFC329),
                  label: '目標体重',
                  value: '${targetWeightKg.toStringAsFixed(1)} kg',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _GoalPill(
                  icon: Icons.favorite_rounded,
                  iconColor: Color(0xFFFF8DB8),
                  label: '目標まであと',
                  value: '${remaining?.toStringAsFixed(1) ?? '--.-'} kg',
                  suffix: 'ですわ！',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalPill extends StatelessWidget {
  const _GoalPill({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.suffix,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAFC),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: const Color(0xFFFFD9E5), width: 2),
        boxShadow: const [BoxShadow(color: Color(0x12D94A80), blurRadius: 8)],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(width: 12),
            Text(
              '$label　',
              style: const TextStyle(
                fontFamily: reportAccentFontFamily,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: _deepPink,
                fontFamily: reportAccentFontFamily,
                fontSize: 31,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (suffix != null)
              Text(
                '　$suffix',
                style: const TextStyle(
                  fontFamily: reportAccentFontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
          ],
        ),
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
    final paragraphs = _commentParagraphs(comment);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.97),
              borderRadius: BorderRadius.circular(42),
              border: Border.all(color: const Color(0xFFFFD5E3), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x24D94A80),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
          ),
        ),
        Positioned(left: 52, right: 52, top: 16, child: _CommentHeading()),
        Positioned(
          left: 18,
          top: 24,
          child: Image.asset(
            'assets/images/report/report_flower.png',
            width: 34,
            height: 34,
            excludeFromSemantics: true,
          ),
        ),
        Positioned(
          right: 18,
          top: 24,
          child: Image.asset(
            'assets/images/report/report_flower.png',
            width: 34,
            height: 34,
            excludeFromSemantics: true,
          ),
        ),
        Positioned(
          left: 34,
          right: 34,
          top: 105,
          bottom: 30,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Align(
                alignment: Alignment.topLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (
                          var index = 0;
                          index < paragraphs.length;
                          index++
                        ) ...[
                          Text(
                            paragraphs[index],
                            style: const TextStyle(
                              color: Color(0xFF3F2C31),
                              fontFamily: appFontFamily,
                              fontSize: 19,
                              height: 1.7,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (index != paragraphs.length - 1) ...[
                            const SizedBox(height: 9),
                            Image.asset(
                              'assets/images/report/report_comment_divider.png',
                              width: constraints.maxWidth,
                              height: 12,
                              fit: BoxFit.fill,
                              excludeFromSemantics: true,
                            ),
                            const SizedBox(height: 9),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

List<String> _commentParagraphs(String comment) {
  final paragraphs = <String>[];
  final buffer = StringBuffer();
  for (final character in comment.trim().characters) {
    buffer.write(character);
    if ('。！？'.contains(character) && paragraphs.length < 3) {
      final sentence = buffer.toString().trim();
      if (sentence.isNotEmpty) paragraphs.add(sentence);
      buffer.clear();
    }
  }
  final remainder = buffer.toString().trim();
  if (remainder.isNotEmpty) paragraphs.add(remainder);
  return paragraphs.isEmpty ? [comment] : paragraphs;
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
                'めたんのひとこと',
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
            width: 350,
            height: 68,
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
            width: 72,
            height: 72,
            excludeFromSemantics: true,
          ),
        ),
        Positioned(
          right: 2,
          top: 35,
          child: Image.asset(
            'assets/images/report/report_sparkle_pink.png',
            width: 70,
            height: 70,
            excludeFromSemantics: true,
          ),
        ),
        Image.asset(
          'assets/images/character_report.png',
          height: 767,
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
