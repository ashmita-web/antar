import 'package:flutter_test/flutter_test.dart';
import 'package:antar/core/optimizer.dart';
import 'package:antar/data/models/candidate_project.dart';

CandidateProject _makeCandidate({
  required String id,
  required int cost,
  required int beneficiaries,
  required double priority,
  String quadrant = 'stable',
}) {
  return CandidateProject(
    candidateId: id,
    villageCode: 'V-$id',
    villageName: 'Village $id',
    block: 'Block',
    category: 'road',
    projectType: 'pucca_road',
    projectLabel: 'Road $id',
    indicativeCost: cost,
    beneficiaries: beneficiaries,
    priority: priority,
    quadrant: quadrant,
    fundHint: '',
    synthetic: true,
  );
}

void main() {
  test('Optimizer never exceeds budget', () {
    final candidates = [
      _makeCandidate(id: 'A', cost: 300000, beneficiaries: 500, priority: 0.9),
      _makeCandidate(id: 'B', cost: 200000, beneficiaries: 300, priority: 0.8),
      _makeCandidate(id: 'C', cost: 400000, beneficiaries: 800, priority: 0.7),
      _makeCandidate(id: 'D', cost: 100000, beneficiaries: 100, priority: 0.5),
    ];

    final result = optimizeBudget(
      candidates: candidates,
      budget: 500000,
      budgetUnit: 100000,
    );

    expect(result.totalCost, lessThanOrEqualTo(500000));
    expect(result.selected, isNotEmpty);
  });

  test('DP beats greedy on known counterexample', () {
    // Greedy by value/weight picks A first (val/wt = 50/1 = 50), leaving no room for B+C.
    // But B + C together (wt 2 + 2 = 4 ≤ 4) give value 100, beating greedy's 50.
    final candidates = [
      _makeCandidate(id: 'A', cost: 300000, beneficiaries: 1000, priority: 0.05), // val=50, wt=3
      _makeCandidate(id: 'B', cost: 200000, beneficiaries: 500, priority: 0.1),   // val=50, wt=2
      _makeCandidate(id: 'C', cost: 200000, beneficiaries: 500, priority: 0.1),   // val=50, wt=2
    ];

    final result = optimizeBudget(
      candidates: candidates,
      budget: 400000,
      budgetUnit: 100000,
    );

    // DP should pick B + C (total value 100) not just A (value 50)
    expect(result.totalCost, lessThanOrEqualTo(400000));
    expect(result.totalValue, greaterThanOrEqualTo(100));
    expect(result.selected.length, equals(2));
    expect(
      result.selected.map((c) => c.candidateId).toSet(),
      equals({'B', 'C'}),
    );
  });

  test('Equity toggle changes selection for silent gaps', () {
    final candidates = [
      _makeCandidate(
        id: 'SG',
        cost: 200000,
        beneficiaries: 300,
        priority: 0.6,
        quadrant: 'silent_gap',
      ),
      _makeCandidate(
        id: 'ST',
        cost: 200000,
        beneficiaries: 350,
        priority: 0.6,
        quadrant: 'stable',
      ),
    ];

    final withoutEquity = optimizeBudget(
      candidates: candidates,
      budget: 200000,
      budgetUnit: 100000,
    );

    final withEquity = optimizeBudget(
      candidates: candidates,
      budget: 200000,
      budgetUnit: 100000,
      equityBoost: true,
    );

    // Without equity, ST is preferred (higher beneficiaries × same priority)
    expect(withoutEquity.selected.first.candidateId, equals('ST'));

    // With equity boost, SG gets 1.3× value and should be preferred
    expect(withEquity.selected.first.candidateId, equals('SG'));
  });

  test('Empty candidates returns empty result', () {
    final result = optimizeBudget(
      candidates: [],
      budget: 500000,
      budgetUnit: 100000,
    );
    expect(result.selected, isEmpty);
    expect(result.totalCost, equals(0));
  });

  test('Zero budget returns empty result', () {
    final candidates = [
      _makeCandidate(id: 'A', cost: 100000, beneficiaries: 100, priority: 0.5),
    ];
    final result = optimizeBudget(
      candidates: candidates,
      budget: 0,
      budgetUnit: 100000,
    );
    expect(result.selected, isEmpty);
  });
}
