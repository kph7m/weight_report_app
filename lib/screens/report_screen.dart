import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weight_entry.dart';
import '../providers/ai_comment_providers.dart';
import '../providers/weight_providers.dart';
import '../theme/app_theme.dart';
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
    final latestWeight = latest?.weightKg;
    final remaining = latestWeight == null
        ? null
        : (latestWeight - targetWeightKg).clamp(0, double.infinity).toDouble();

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
                            _TargetWeightArea(
                              remaining: remaining,
                              scale: scale,
                            ),
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
                  '今日も記録えらいですわっ♪ 継続が一番の近道ですの！',
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

class _TargetWeightArea extends StatelessWidget {
  const _TargetWeightArea({required this.remaining, required this.scale});

  final double? remaining;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Matches the combined height formerly occupied by the measured-date
      // header and seven-day records section.
      height: 592 * scale,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F6),
                borderRadius: BorderRadius.circular(18 * scale),
                border: Border.all(color: const Color(0xFFFF8DB8), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gps_fixed, color: _deepPink, size: 68 * scale),
                  SizedBox(height: 16 * scale),
                  Text(
                    '目標体重',
                    style: TextStyle(
                      color: _deepPink,
                      fontSize: 44 * scale,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  Text(
                    '75.0kg',
                    style: TextStyle(
                      color: _deepPink,
                      fontSize: 112 * scale,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 18 * scale),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 44 * scale,
                      vertical: 12 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(999 * scale),
                      border: Border.all(color: const Color(0xFFFFC1D8)),
                    ),
                    child: Text(
                      '目標まであと ${_formatNumber(remaining)}kg',
                      style: TextStyle(
                        color: _deepPink,
                        fontSize: 27 * scale,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 14 * scale,
            top: 14 * scale,
            child: _WeightInputShortcutButton(scale: scale),
          ),
        ],
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🌸 今日のひとこと♪',
            style: TextStyle(
              fontFamily: reportAccentFontFamily,
              color: _deepPink,
              fontSize: 31 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 14 * scale),
          Text(
            aiComment,
            style: TextStyle(
              fontFamily: reportAccentFontFamily,
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

String _formatNumber(double? value) =>
    value == null ? '--' : value.toStringAsFixed(1);
