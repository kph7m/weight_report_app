import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/weight_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repository = await ref.read(weightRepositoryProvider.future);
    await repository.saveToday(double.parse(_controller.text));
    _controller.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('今日の体重を保存しました')));
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(weightEntriesProvider);
    final average = ref.watch(sevenDayAverageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Weight Report')),
      body: entriesAsync.when(
        data: (entries) {
          final latest = entries.isNotEmpty ? entries.first.weightKg : null;
          final remaining = latest == null ? null : (latest - targetWeightKg).clamp(0, double.infinity).toDouble();
          final progress = latest == null ? 0.0 : (targetWeightKg / latest).clamp(0.0, 1.0).toDouble();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('今日の体重入力', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _controller,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: '体重',
                            suffixText: 'kg',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final weight = double.tryParse(value ?? '');
                            if (weight == null || weight <= 0) return '有効な体重を入力してください';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.save),
                          label: const Text('保存'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
}
