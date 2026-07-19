enum AiModel {
  gpt56Sol('GPT-5.6 Sol', 'gpt-5.6'),
  gpt56Terra('GPT-5.6 Terra', 'gpt-5.6-terra'),
  gpt56Luna('GPT-5.6 Luna', 'gpt-5.6-luna'),
  gpt55('GPT-5.5', 'gpt-5.5'),
  gpt55Instant('GPT-5.5 Instant', 'gpt-5.5-instant');

  const AiModel(this.displayName, this.apiName);

  final String displayName;
  final String apiName;

  static const defaultModel = AiModel.gpt55Instant;

  static AiModel fromApiName(String? value) => values.firstWhere(
    (model) => model.apiName == value,
    orElse: () => defaultModel,
  );
}
