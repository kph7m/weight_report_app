class AiModel {
  const AiModel(this.apiName);

  static const defaultModel = AiModel('gpt-5.5-instant');

  final String apiName;

  String get displayName => apiName;

  @override
  bool operator ==(Object other) =>
      other is AiModel && apiName == other.apiName;

  @override
  int get hashCode => apiName.hashCode;
}
