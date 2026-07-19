import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_model.dart';
import '../models/open_ai_exchange.dart';
import '../providers/weight_providers.dart';

const _pink = Color(0xFFEF5EA8);
const _ink = Color(0xFF202633);
const _muted = Color(0xFF9292A0);
const _cloudTop = 'assets/images/cloud_top.png';
const _cloudBottom = 'assets/images/cloud_bottom.png';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final settings = ref.watch(appSettingsProvider).valueOrNull;
    final exchange = ref.watch(latestOpenAiExchangeProvider).valueOrNull;
    final selectedModel =
        ref.watch(selectedAiModelProvider).valueOrNull ?? AiModel.defaultModel;
    final cachedModels =
        ref.watch(cachedAiModelsProvider).valueOrNull ?? const <AiModel>[];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFD),
      body: Stack(
        children: [
          const Positioned.fill(child: _SettingsBackground()),
          Positioned(
            top: mediaQuery.padding.top + 18,
            left: 20,
            child: _RoundBackButton(onPressed: () => Navigator.pop(context)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 92, 18, 24),
              child: Column(
                children: [
                  const _SettingsTitle(),
                  const SizedBox(height: 28),
                  _SettingsTile(
                    icon: Icons.straighten_rounded,
                    label: '身長',
                    value: _measurement(settings?.heightCm, 'cm'),
                    onTap: () => _editNumber(
                      context,
                      ref,
                      title: '身長',
                      unit: 'cm',
                      initialValue: settings?.heightCm,
                      onSave: (value) async {
                        final repository = await ref.read(
                          weightRepositoryProvider.future,
                        );
                        await repository.saveHeight(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.track_changes_rounded,
                    label: '目標体重',
                    value: _measurement(settings?.targetWeightKg, 'kg'),
                    onTap: () => _editNumber(
                      context,
                      ref,
                      title: '目標体重',
                      unit: 'kg',
                      initialValue: settings?.targetWeightKg,
                      onSave: (value) async {
                        final repository = await ref.read(
                          weightRepositoryProvider.future,
                        );
                        await repository.saveTargetWeight(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.smart_toy_rounded,
                    label: 'AIモデル',
                    value: selectedModel.displayName,
                    onTap: () => _selectAiModel(
                      context,
                      ref,
                      selectedModel: selectedModel,
                      models: cachedModels,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _refreshAiModels(context, ref),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('モデル一覧を更新'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.http_rounded,
                    label: '直近のOpenAI通信',
                    value: exchange == null
                        ? '未記録'
                        : exchange.succeeded
                        ? '成功'
                        : '失敗',
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            OpenAiExchangeScreen(exchange: exchange),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.key_rounded,
                    label: 'OpenAIキー',
                    value: _maskedKey(settings?.openAiApiKey),
                    onTap: () => _editApiKey(
                      context,
                      ref,
                      initialValue: settings?.openAiApiKey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _measurement(double? value, String unit) =>
      value == null ? '' : '${value.toStringAsFixed(1)} $unit';

  String _maskedKey(String? value) {
    if (value == null || value.isEmpty) return '';
    final prefix = value.length >= 3 ? value.substring(0, 3) : '';
    return '$prefix••••••••••';
  }

  Future<void> _selectAiModel(
    BuildContext context,
    WidgetRef ref, {
    required AiModel selectedModel,
    required List<AiModel> models,
  }) async {
    final model = await showDialog<AiModel>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('AIモデルを選択'),
        children: models.isEmpty
            ? const [
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: Text('モデル一覧がありません。「モデル一覧を更新」を押してください。'),
                ),
              ]
            : models
                  .map(
                    (model) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(dialogContext, model),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(model.displayName),
                        trailing: model == selectedModel
                            ? const Icon(Icons.check_rounded, color: _pink)
                            : null,
                      ),
                    ),
                  )
                  .toList(),
      ),
    );
    if (model == null) return;
    await ref.read(aiModelPreferencesProvider).saveSelected(model);
    ref.invalidate(selectedAiModelProvider);
  }

  Future<void> _refreshAiModels(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(appSettingsProvider).valueOrNull;
    final apiKey = settings?.openAiApiKey;
    try {
      final models = await ref
          .read(openAiModelsServiceProvider)
          .fetchModels(apiKey: apiKey ?? '');
      await ref.read(aiModelPreferencesProvider).saveCachedModels(models);
      ref.invalidate(cachedAiModelsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${models.length}件のモデルを取得しました。')),
        );
      }
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('モデル一覧を更新できませんでした。\n$error')));
      }
    }
  }

  Future<void> _editNumber(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String unit,
    required double? initialValue,
    required Future<void> Function(double? value) onSave,
  }) async {
    final controller = TextEditingController(
      text: initialValue?.toStringAsFixed(1) ?? '',
    );
    await _showEditDialog(
      context,
      title: title,
      controller: controller,
      suffixText: unit,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return null;
        final number = double.tryParse(value);
        if (number == null || number <= 0) return '正の数値を入力してください';
        return null;
      },
      onSave: () => onSave(
        controller.text.trim().isEmpty
            ? null
            : double.parse(controller.text.trim()),
      ),
    );
  }

  Future<void> _editApiKey(
    BuildContext context,
    WidgetRef ref, {
    required String? initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue ?? '');
    await _showEditDialog(
      context,
      title: 'OpenAIキー',
      controller: controller,
      obscureText: true,
      onSave: () async {
        final repository = await ref.read(weightRepositoryProvider.future);
        final value = controller.text.trim();
        await repository.saveOpenAiApiKey(value.isEmpty ? null : value);
      },
    );
  }

  Future<void> _showEditDialog(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    required Future<void> Function() onSave,
    String? suffixText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) async {
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              suffixText: suffixText,
              hintText: '未設定',
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              await onSave();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

class OpenAiExchangeScreen extends StatelessWidget {
  const OpenAiExchangeScreen({super.key, required this.exchange});

  final OpenAiExchange? exchange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFD),
      appBar: AppBar(
        title: const Text('直近のOpenAI通信'),
        backgroundColor: const Color(0xFFFFFBFD),
      ),
      body: exchange == null
          ? const Center(child: Text('まだ通信していません'))
          : SelectionArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE8F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: _deepWarning),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '学習・確認用として、リクエストにはAPIキーも表示されます。画面共有やコピー時の取り扱いに注意してください。',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ExchangeSummary(exchange: exchange!),
                  const SizedBox(height: 20),
                  _ExchangeCodeSection(
                    title: 'Request',
                    content: exchange!.requestJson,
                  ),
                  const SizedBox(height: 20),
                  _ExchangeCodeSection(
                    title: 'Response',
                    content: exchange!.responseBody ?? 'レスポンス本文はありません。',
                  ),
                  if (exchange!.errorMessage != null) ...[
                    const SizedBox(height: 20),
                    _ExchangeCodeSection(
                      title: 'Error',
                      content: exchange!.errorMessage!,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

const _deepWarning = Color(0xFFB45309);

class _ExchangeSummary extends StatelessWidget {
  const _ExchangeSummary({required this.exchange});

  final OpenAiExchange exchange;

  @override
  Widget build(BuildContext context) {
    final local = exchange.requestedAt.toLocal();
    final timestamp =
        '${local.year}/${local.month.toString().padLeft(2, '0')}/'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}:'
        '${local.second.toString().padLeft(2, '0')}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SummaryRow(label: '結果', value: exchange.succeeded ? '成功' : '失敗'),
            _SummaryRow(label: '実行日時', value: timestamp),
            _SummaryRow(
              label: 'HTTPステータス',
              value: exchange.statusCode?.toString() ?? '取得できませんでした',
            ),
            _SummaryRow(
              label: '応答時間',
              value: '${exchange.elapsedMilliseconds} ms',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(color: _muted)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _ExchangeCodeSection extends StatelessWidget {
  const _ExchangeCodeSection({required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF202633),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          content,
          style: const TextStyle(
            color: Color(0xFFF8FAFC),
            fontFamily: 'monospace',
            fontSize: 12,
            height: 1.45,
          ),
        ),
      ),
    ],
  );
}

class _SettingsBackground extends StatelessWidget {
  const _SettingsBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFEEF8), Color(0xFFFFFEFC), Color(0xFFFFF7FC)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(_cloudTop, fit: BoxFit.fitWidth),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(_cloudBottom, fit: BoxFit.fitWidth),
          ),
        ],
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF2B6D8), width: 2),
        boxShadow: [
          BoxShadow(
            color: _pink.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IconButton(
        tooltip: '戻る',
        onPressed: onPressed,
        constraints: const BoxConstraints.tightFor(width: 56, height: 56),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: _pink,
          size: 28,
        ),
      ),
    );
  }
}

class _SettingsTitle extends StatelessWidget {
  const _SettingsTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('〈', style: TextStyle(color: _pink, fontSize: 28)),
        SizedBox(width: 10),
        Text(
          '設定',
          style: TextStyle(
            color: _pink,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
          ),
        ),
        SizedBox(width: 10),
        Text('〉', style: TextStyle(color: _pink, fontSize: 28)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFE3F0)),
            boxShadow: [
              BoxShadow(
                color: _pink.withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF91C7), Color(0xFFEF4FA4)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: _muted, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}
