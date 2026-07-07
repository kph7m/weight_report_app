import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/weight_entry.dart';
import '../providers/weight_providers.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(weightEntriesProvider);
    final average = ref.watch(sevenDayAverageProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFD),
      appBar: AppBar(
        title: const Text('レポート'),
        backgroundColor: const Color(0xFFFFFBFD),
        foregroundColor: const Color(0xFFB83283),
        elevation: 0,
      ),
      body: entriesAsync.when(
        data: (entries) =>
            _ReportBody(entries: entries, sevenDayAverage: average),
        error: (error, stackTrace) =>
            Center(child: Text('読み込みに失敗しました: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.entries, required this.sevenDayAverage});

  final List<WeightEntry> entries;
  final double? sevenDayAverage;

  @override
  Widget build(BuildContext context) {
    final latest = entries.isNotEmpty ? entries.first : null;
    final previous = entries.length > 1 ? entries[1] : null;
    final latestWeight = latest?.weightKg;
    final previousDiff = latestWeight == null || previous == null
        ? null
        : latestWeight - previous.weightKg;
    final remaining = latestWeight == null
        ? null
        : (latestWeight - targetWeightKg).clamp(0, double.infinity).toDouble();
    final progress = latestWeight == null
        ? 0.0
        : (targetWeightKg / latestWeight).clamp(0.0, 1.0).toDouble();
    final trendLabel = _trendLabel(previousDiff);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        _ReportHeader(latest: latest),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.28,
          children: [
            _MetricCard(
              label: '最新体重',
              value: latestWeight == null
                  ? '--'
                  : latestWeight.toStringAsFixed(1),
              unit: 'kg',
            ),
            _MetricCard(
              label: '直近7日平均',
              value: sevenDayAverage == null
                  ? '--'
                  : sevenDayAverage!.toStringAsFixed(1),
              unit: 'kg',
            ),
            _MetricCard(
              label: '前回との差分',
              value: previousDiff == null
                  ? '--'
                  : previousDiff.toStringAsFixed(1),
              unit: 'kg',
            ),
            _MetricCard(
              label: '記録日数',
              value: entries.length.toString(),
              unit: '日',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '目標75kgまで',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  remaining == null
                      ? '-- kg'
                      : '${remaining.toStringAsFixed(1)} kg',
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 10),
                Text('週ごとの傾向: $trendLabel'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '体重履歴',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          const Card(child: ListTile(title: Text('まだ記録がありません')))
        else
          ...entries.map(
            (entry) => Card(
              child: ListTile(
                leading: const Icon(Icons.monitor_weight_outlined),
                title: Text('${entry.weightKg.toStringAsFixed(1)} kg'),
                subtitle: Text(DateFormat.yMMMd().format(entry.date)),
              ),
            ),
          ),
      ],
    );
  }

  String _trendLabel(double? diff) {
    if (diff == null) return '比較できる前回記録がありません';
    if (diff < 0) return '前回より減少しています';
    if (diff > 0) return '前回より増加しています';
    return '前回から変化はありません';
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({required this.latest});

  final WeightEntry? latest;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE8F5), Color(0xFFFFFBFD)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF5A4CF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日のレポート',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              latest == null
                  ? '記録を保存すると、ここに体重管理情報が表示されます。'
                  : '${DateFormat.yMMMd().format(latest!.date)} の記録を保存しました。',
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF202633),
                  fontWeight: FontWeight.w900,
                ),
                children: [
                  TextSpan(text: value),
                  TextSpan(
                    text: ' $unit',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF202633),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
