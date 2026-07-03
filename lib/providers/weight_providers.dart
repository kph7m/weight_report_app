import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weight_entry.dart';
import '../services/weight_repository.dart';

const targetWeightKg = 75.0;

final weightRepositoryProvider = FutureProvider<WeightRepository>((ref) {
  return WeightRepository.open();
});

final weightEntriesProvider = StreamProvider<List<WeightEntry>>((ref) async* {
  final repository = await ref.watch(weightRepositoryProvider.future);
  yield* repository.watchEntries();
});

final sevenDayAverageProvider = Provider<double?>((ref) {
  final entries = ref.watch(weightEntriesProvider).valueOrNull ?? const <WeightEntry>[];
  if (entries.isEmpty) return null;

  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
  final recent = entries.where((entry) => !entry.date.isBefore(start)).toList();
  if (recent.isEmpty) return null;

  final total = recent.fold<double>(0, (sum, entry) => sum + entry.weightKg);
  return total / recent.length;
});
