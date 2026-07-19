class AiCommentRequest {
  const AiCommentRequest({
    required this.heightCm,
    required this.targetWeightKg,
    required this.todayWeightKg,
    required this.previousDayDifferenceKg,
    required this.remainingToTargetKg,
    required this.recentWeights,
    required this.recentAverages,
    required this.previousComment,
  });

  final double? heightCm;
  final double? targetWeightKg;
  final double todayWeightKg;
  final double? previousDayDifferenceKg;
  final double? remainingToTargetKg;
  final List<AiCommentDailyValue> recentWeights;
  final List<AiCommentDailyValue> recentAverages;
  final String previousComment;

  String toPromptInput() {
    String value(double? number, {int fractionDigits = 1}) =>
        number?.toStringAsFixed(fractionDigits) ?? '';
    String dailyValues(List<AiCommentDailyValue> values, int digits) => values
        .map(
          (item) =>
              '${_formatDate(item.date)}: ${value(item.value, fractionDigits: digits)}',
        )
        .join('\n');

    return '''プロフィール
身長: ${value(heightCm)} cm
目標体重: ${value(targetWeightKg)} kg

今日のデータ
今日の体重: ${value(todayWeightKg)} kg
前日比: ${value(previousDayDifferenceKg)} kg
目標体重までの残り: ${value(remainingToTargetKg)} kg

直近7日間
${dailyValues(recentWeights, 1)}

直近7日平均
${dailyValues(recentAverages, 2)}

前回コメント
$previousComment''';
  }
}

class AiCommentDailyValue {
  const AiCommentDailyValue({required this.date, required this.value});

  final DateTime date;
  final double value;
}

String _formatDate(DateTime date) =>
    '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
