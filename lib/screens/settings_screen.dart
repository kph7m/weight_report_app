import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
