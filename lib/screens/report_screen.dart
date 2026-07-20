import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weight_entry.dart';
import '../providers/ai_comment_providers.dart';
import '../providers/weight_providers.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

const _deepPink = Color(0xFFF50057);
const _blue = Color(0xFF2563EB);
const _ink = Color(0xFF3D292D);
const _assetRoot = 'assets/images/report';
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
        final viewportWidth = constraints.maxWidth;
        final compact = viewportWidth < 680;
        final contentWidth = viewportWidth.clamp(320.0, 922.0);
        final scale = (contentWidth / 922).clamp(0.58, 1.0);
        final horizontalPadding = compact ? 12.0 : 22.0;
        final comment =
            latest?.aiComment ?? generatedComment ?? aiCommentFailureMessage;

        return DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF8FB),
            image: DecorationImage(
              image: AssetImage('$_assetRoot/report_background_tile.png'),
              repeat: ImageRepeat.repeat,
              opacity: 0.68,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Image.asset(
                    '$_assetRoot/report_bottom_lace_tile.png',
                    semanticLabel: 'レポート下部レース',
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  compact ? 48 : 72,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 922),
                    child: DefaultTextStyle.merge(
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w700,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ReportHeroHeader(
                            latest: latest,
                            scale: scale,
                            compact: compact,
                          ),
                          SizedBox(height: compact ? 18 : 24),
                          _ReportTitleArea(
                            date: latest?.date ?? DateTime.now(),
                            scale: scale,
                            compact: compact,
                          ),
                          SizedBox(height: compact ? 6 : 10),
                          _TableCard(
                            child: _SevenDayTable(rows: rows, scale: scale),
                          ),
                          SizedBox(height: compact ? 18 : 28),
                          _ResponsiveBottomSection(
                            aiComment: comment,
                            scale: scale,
                            compact: compact,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
  const _ReportHeroHeader({
    required this.latest,
    required this.scale,
    required this.compact,
  });

  final WeightEntry? latest;
  final double scale;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final weight = latest?.weightKg;
    final remaining = weight == null
        ? null
        : (weight - targetWeightKg).clamp(0, double.infinity).toDouble();
    final weightText = weight == null ? '--.-' : weight.toStringAsFixed(1);

    return _DecoratedCard(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _ThreeSliceRibbon(
              family: 'report_today_title',
              height: compact ? 48 : 62,
              maxWidth: compact ? 205 : 260,
              semanticLabel: '本日の体重タイトル装飾',
              child: Text(
                '本日の体重',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: reportAccentFontFamily,
                  fontSize: compact ? 18 : 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          SizedBox(height: compact ? 4 : 2),
          if (compact)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      _weightInputIconAsset,
                      width: 58,
                      height: 58,
                      semanticLabel: '体重入力アイコン',
                    ),
                    const SizedBox(width: 10),
                    _WeightValue(weightText: weightText, scale: scale),
                  ],
                ),
                const Text(
                  'kg でしたわー！',
                  style: TextStyle(
                    fontFamily: reportAccentFontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                const SizedBox(width: 28),
                Image.asset(
                  _weightInputIconAsset,
                  width: 92,
                  height: 92,
                  semanticLabel: '体重入力アイコン',
                ),
                const SizedBox(width: 28),
                _WeightValue(weightText: weightText, scale: scale),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'kg でしたわー！',
                    style: TextStyle(
                      fontFamily: reportAccentFontFamily,
                      fontSize: 31,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Image.asset(
                  '$_assetRoot/report_sparkle_gold.png',
                  width: 62,
                  height: 62,
                ),
              ],
            ),
          SizedBox(height: compact ? 12 : 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 20,
              vertical: compact ? 9 : 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFAFC),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFFFCADC)),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: compact ? 8 : 20,
              runSpacing: 4,
              children: [
                Text(
                  '目標体重　${targetWeightKg.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontFamily: reportAccentFontFamily,
                    fontSize: compact ? 14 : 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Container(
                  width: 1,
                  height: compact ? 18 : 26,
                  color: const Color(0xFFFFBCD2),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: '目標まであと　'),
                      TextSpan(
                        text: '${remaining?.toStringAsFixed(1) ?? '--.-'} kg',
                        style: const TextStyle(color: _deepPink),
                      ),
                      const TextSpan(text: ' ですわ！'),
                    ],
                  ),
                  style: TextStyle(
                    fontFamily: reportAccentFontFamily,
                    fontSize: compact ? 14 : 22,
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

class _WeightValue extends StatelessWidget {
  const _WeightValue({required this.weightText, required this.scale});

  final String weightText;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Text(
      weightText,
      style: TextStyle(
        color: _deepPink,
        fontFamily: reportAccentFontFamily,
        fontSize: 76 * scale,
        height: 1,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _DecoratedCard extends StatelessWidget {
  const _DecoratedCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFFA9C7), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33E94B85),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: child,
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
      padding: EdgeInsets.symmetric(horizontal: 22 * scale, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4EF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF9BC2)),
      ),
      child: Text(
        '測定日：${_formatJstDate(date)}',
        style: TextStyle(fontSize: 22 * scale, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _ReportTitleArea extends StatelessWidget {
  const _ReportTitleArea({
    required this.date,
    required this.scale,
    required this.compact,
  });

  final DateTime date;
  final double scale;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MeasuredDateBadge(date: date, scale: scale),
            SizedBox(width: compact ? 8 : 18),
            _WeightInputShortcutButton(scale: scale),
          ],
        ),
        SizedBox(height: compact ? 5 : 8),
        _ThreeSliceRibbon(
          family: 'report_history_ribbon',
          height: compact ? 66 : 88,
          maxWidth: compact ? 340 : 540,
          semanticLabel: '7日間記録タイトル装飾',
          child: Text(
            '直近７日間の体重記録',
            style: TextStyle(
              color: Colors.white,
              fontFamily: reportAccentFontFamily,
              fontSize: compact ? 18 : 29,
              fontWeight: FontWeight.w900,
              shadows: const [Shadow(color: Color(0x5595003D), blurRadius: 2)],
            ),
          ),
        ),
      ],
    );
  }
}

class _ThreeSliceRibbon extends StatelessWidget {
  const _ThreeSliceRibbon({
    required this.family,
    required this.height,
    required this.maxWidth,
    required this.semanticLabel,
    required this.child,
  });

  final String family;
  final double height;
  final double maxWidth;
  final String semanticLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: semanticLabel,
      child: SizedBox(
        height: height,
        width: maxWidth,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ExcludeSemantics(
              child: Row(
                children: [
                  Image.asset(
                    '$_assetRoot/${family}_left.png',
                    height: height,
                    width: height * 1.17,
                    fit: BoxFit.fill,
                  ),
                  Expanded(
                    child: Image.asset(
                      '$_assetRoot/${family}_center.png',
                      height: height,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Image.asset(
                    '$_assetRoot/${family}_right.png',
                    height: height,
                    width: height * 1.17,
                    fit: BoxFit.fill,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: height * 0.65),
              child: FittedBox(fit: BoxFit.scaleDown, child: child),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26E94B85),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
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
      borderRadius: BorderRadius.circular(16),
      child: Table(
        border: TableBorder.all(color: const Color(0xFFFFD5E4), width: 0.8),
        columnWidths: const {
          0: FlexColumnWidth(1.55),
          1: FlexColumnWidth(1.15),
          2: FlexColumnWidth(1.05),
          3: FlexColumnWidth(1.35),
        },
        children: [
          _tableRow(const [
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
      decoration: BoxDecoration(
        color: isHeader ? const Color(0xFFF75A99) : Colors.white,
      ),
      children: cells
          .map(
            (cell) => Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 3,
                vertical: isHeader ? 10 * scale : 12 * scale,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: DefaultTextStyle.merge(
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isHeader ? Colors.white : _ink,
                    fontSize: (isHeader ? 20 : 23) * scale,
                    height: 1.18,
                    fontWeight: isHeader ? FontWeight.w900 : FontWeight.w700,
                  ),
                  child: cell,
                ),
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
    final size = 72 * scale;
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
          width: size,
          height: size,
          semanticLabel: '体重入力ショートカットアイコン',
        ),
      ),
    );
  }
}

class _ResponsiveBottomSection extends StatelessWidget {
  const _ResponsiveBottomSection({
    required this.aiComment,
    required this.scale,
    required this.compact,
  });

  final String aiComment;
  final double scale;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        children: [
          _ViewerMessagePanel(aiComment: aiComment, scale: scale),
          Transform.translate(
            offset: const Offset(18, -8),
            child: Align(
              alignment: Alignment.centerRight,
              child: _ReportCharacterArt(height: 390 * scale),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      height: 560,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            width: 490,
            child: _ViewerMessagePanel(aiComment: aiComment, scale: scale),
          ),
          Positioned(
            right: -12,
            bottom: 0,
            child: _ReportCharacterArt(height: 550),
          ),
        ],
      ),
    );
  }
}

class _ReportCharacterArt extends StatelessWidget {
  const _ReportCharacterArt({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height * 0.82,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 2,
            child: Container(
              width: height * 0.55,
              height: height * 0.09,
              decoration: const BoxDecoration(
                color: Color(0x55F76B9F),
                borderRadius: BorderRadius.all(Radius.elliptical(999, 120)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: height * 0.1,
            child: Image.asset(
              '$_assetRoot/report_sparkle_gold.png',
              width: height * 0.11,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Image.asset(
              '$_assetRoot/report_sparkle_pink.png',
              width: height * 0.12,
            ),
          ),
          Image.asset(
            'assets/images/character_report.png',
            semanticLabel: 'レポート応援キャラクター',
            fit: BoxFit.contain,
            height: height,
          ),
        ],
      ),
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
      padding: EdgeInsets.fromLTRB(22 * scale, 22, 22 * scale, 28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFFA9C7), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26E94B85),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Transform.translate(
            offset: const Offset(0, -9),
            child: _ThreeSliceRibbon(
              family: 'report_comment_title',
              height: 56,
              maxWidth: 340,
              semanticLabel: 'コメントタイトル装飾',
              child: const Text(
                'めたんからのひとこと',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: reportAccentFontFamily,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Image.asset('$_assetRoot/report_flower.png', width: 24, height: 24),
          const SizedBox(height: 2),
          Text(
            aiComment,
            style: TextStyle(
              fontFamily: appFontFamily,
              fontSize: 18 * scale,
              height: 1.72,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                '$_assetRoot/report_heart.png',
                width: 22,
                height: 22,
              ),
              const SizedBox(width: 6),
              Image.asset(
                '$_assetRoot/report_flower.png',
                width: 24,
                height: 24,
              ),
            ],
          ),
        ],
      ),
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
