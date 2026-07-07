import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/weight_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _characterPointingInput = 'assets/images/character_pointing_input.png';
  static const _characterHighTouch = 'assets/images/character_high_touch.png';
  static const _characterCelebration = 'assets/images/character_celebration.png';
  static const _cloudTop = 'assets/images/cloud_top.png';
  static const _cloudBottom = 'assets/images/cloud_bottom.png';

  final _controller = TextEditingController(text: '00.0');
  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();

  var _isHighTouchMode = false;
  var _isCelebrating = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _isHighTouchMode = false;
          _isCelebrating = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repository = await ref.read(weightRepositoryProvider.future);
    await repository.saveToday(double.parse(_controller.text));
    _focusNode.unfocus();
    if (!mounted) return;
    setState(() {
      _isHighTouchMode = true;
      _isCelebrating = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('体重を保存しました。ハイタッチして記録完了です！')),
    );
  }

  void _celebrate() {
    if (!_isHighTouchMode) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isCelebrating = true;
      _isHighTouchMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(weightEntriesProvider);
    final average = ref.watch(sevenDayAverageProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FB),
      appBar: AppBar(
        title: const Text('Weight Report'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: entriesAsync.when(
        data: (entries) {
          final latest = entries.isNotEmpty ? entries.first.weightKg : null;
          final remaining = latest == null ? null : (latest - targetWeightKg).clamp(0, double.infinity).toDouble();
          final progress = latest == null ? 0.0 : (targetWeightKg / latest).clamp(0.0, 1.0).toDouble();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _WeightInputHero(
                formKey: _formKey,
                controller: _controller,
                focusNode: _focusNode,
                characterAsset: _characterAsset,
                cloudTopAsset: _cloudTop,
                cloudBottomAsset: _cloudBottom,
                statusLabel: _statusLabel,
                helperText: _helperText,
                isHighTouchMode: _isHighTouchMode,
                isCelebrating: _isCelebrating,
                onSave: _save,
                onHighTouch: _celebrate,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('サマリー', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Text('直近7日平均: ${average?.toStringAsFixed(1) ?? '--'} kg'),
                      const SizedBox(height: 12),
                      Text('目標75kgまで: ${remaining?.toStringAsFixed(1) ?? '--'} kg'),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: progress),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('体重履歴一覧', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (entries.isEmpty)
                const Card(child: ListTile(title: Text('まだ記録がありません')))
              else
                ...entries.map(
                  (entry) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.monitor_weight_outlined),
                      title: Text('${entry.weightKg.toStringAsFixed(1)} kg'),
                      subtitle: Text(DateFormat.yMMMd('ja').format(entry.date)),
                    ),
                  ),
                ),
            ],
          );
        },
        error: (error, stackTrace) => Center(child: Text('読み込みに失敗しました: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  String get _characterAsset {
    if (_isCelebrating) return _characterCelebration;
    if (_isHighTouchMode) return _characterHighTouch;
    return _characterPointingInput;
  }

  String get _statusLabel {
    if (_isCelebrating) return '記録完了';
    if (_isHighTouchMode) return '入力後';
    return '入力前';
  }

  String get _helperText {
    if (_isCelebrating) return 'エフェクトでお祝い！レポートを確認しよう';
    if (_isHighTouchMode) return 'ハイタッチして記録完了！';
    return '入力エリアを指定して体重を入力';
  }
}

class _WeightInputHero extends StatelessWidget {
  const _WeightInputHero({
    required this.formKey,
    required this.controller,
    required this.focusNode,
    required this.characterAsset,
    required this.cloudTopAsset,
    required this.cloudBottomAsset,
    required this.statusLabel,
    required this.helperText,
    required this.isHighTouchMode,
    required this.isCelebrating,
    required this.onSave,
    required this.onHighTouch,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String characterAsset;
  final String cloudTopAsset;
  final String cloudBottomAsset;
  final String statusLabel;
  final String helperText;
  final bool isHighTouchMode;
  final bool isCelebrating;
  final VoidCallback onSave;
  final VoidCallback onHighTouch;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.86),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFF1F8), Colors.white],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              cloudTopAsset,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
              excludeFromSemantics: true,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              cloudBottomAsset,
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
              excludeFromSemantics: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: _StatusPill(label: statusLabel),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    helperText,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: isHighTouchMode ? onHighTouch : null,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: Image.asset(
                        characterAsset,
                        key: ValueKey(characterAsset),
                        height: 300,
                        fit: BoxFit.contain,
                        semanticLabel: helperText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.9),
                      suffixText: 'kg',
                      suffixStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      enabledBorder: _inputBorder(colorScheme.primary.withValues(alpha: 0.28)),
                      focusedBorder: _inputBorder(colorScheme.primary),
                      errorBorder: _inputBorder(colorScheme.error),
                      focusedErrorBorder: _inputBorder(colorScheme.error),
                    ),
                    validator: (value) {
                      final weight = double.tryParse(value ?? '');
                      if (weight == null || weight <= 0) return '有効な体重を入力してください';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: isHighTouchMode ? onHighTouch : onSave,
                    icon: Icon(isHighTouchMode ? Icons.back_hand : Icons.save),
                    label: Text(isHighTouchMode ? 'ハイタッチ！' : '入力してハイタッチへ'),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: isCelebrating
                        ? Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Text(
                              '記録完了！今日もおつかれさまです。',
                              key: const ValueKey('celebration-message'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: color, width: 2),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEF5EA8),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF5EA8).withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}
