import '../data/models/candidate_project.dart';

class OptimizationResult {
  final List<CandidateProject> selected;
  final int totalCost;
  final double totalValue;
  final int totalBeneficiaries;

  const OptimizationResult({
    required this.selected,
    required this.totalCost,
    required this.totalValue,
    required this.totalBeneficiaries,
  });
}

/// 0/1 knapsack via DP in budget-unit increments.
/// value = priority × beneficiaries; equity toggle adds +30% for silent gaps.
OptimizationResult optimizeBudget({
  required List<CandidateProject> candidates,
  required int budget,
  required int budgetUnit,
  bool equityBoost = false,
}) {
  if (candidates.isEmpty || budget <= 0) {
    return const OptimizationResult(
      selected: [],
      totalCost: 0,
      totalValue: 0,
      totalBeneficiaries: 0,
    );
  }

  final capacity = budget ~/ budgetUnit;
  final n = candidates.length;

  // Weight and value in budget units
  final weights = <int>[];
  final values = <double>[];

  for (final c in candidates) {
    final w = (c.indicativeCost / budgetUnit).ceil();
    weights.add(w);
    var v = c.priority * c.beneficiaries;
    if (equityBoost && c.quadrant == 'silent_gap') {
      v *= 1.3;
    }
    values.add(v);
  }

  // DP table: dp[j] = max value with capacity j
  final dp = List.filled(capacity + 1, 0.0);
  final keep = List.generate(n, (_) => List.filled(capacity + 1, false));

  for (var i = 0; i < n; i++) {
    for (var j = capacity; j >= weights[i]; j--) {
      final withItem = dp[j - weights[i]] + values[i];
      if (withItem > dp[j]) {
        dp[j] = withItem;
        keep[i][j] = true;
      }
    }
  }

  // Traceback
  final selected = <CandidateProject>[];
  var remaining = capacity;
  for (var i = n - 1; i >= 0; i--) {
    if (keep[i][remaining]) {
      selected.add(candidates[i]);
      remaining -= weights[i];
    }
  }

  final totalCost = selected.fold<int>(0, (s, c) => s + c.indicativeCost);
  final totalBeneficiaries = selected.fold<int>(0, (s, c) => s + c.beneficiaries);
  final totalValue = dp[capacity];

  return OptimizationResult(
    selected: selected.reversed.toList(),
    totalCost: totalCost,
    totalValue: totalValue,
    totalBeneficiaries: totalBeneficiaries,
  );
}
