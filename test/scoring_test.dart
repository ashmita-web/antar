import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:antar/core/scoring.dart';
import 'package:antar/data/models/village.dart';
import 'package:antar/data/models/gap_entry.dart';

void main() {
  late List<Village> fixtureVillages;
  late List<GapEntry> fixtureGaps;

  setUpAll(() {
    final villagesJson = json.decode(
      File('test/fixtures/villages_fixture.json').readAsStringSync(),
    ) as List;
    fixtureVillages = villagesJson
        .map((e) => Village.fromJson(e as Map<String, dynamic>))
        .toList();

    final gapsJson = json.decode(
      File('test/fixtures/gap_matrix_fixture.json').readAsStringSync(),
    ) as List;
    fixtureGaps = gapsJson
        .map((e) => GapEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  });

  test('Dart deficit matches Python fixtures within 0.001', () {
    final villageMap = {for (final v in fixtureVillages) v.villageCode: v};

    for (final gap in fixtureGaps) {
      final village = villageMap[gap.villageCode];
      if (village == null) continue;

      final dartDeficit = computeDeficit(village, gap.category);
      expect(
        dartDeficit,
        closeTo(gap.deficit, 0.001),
        reason: 'Deficit mismatch for ${gap.villageCode}/${gap.category}: '
            'Dart=$dartDeficit, Python=${gap.deficit}',
      );
    }
  });

  test('Dart priority formula matches Python within 0.001', () {
    for (final gap in fixtureGaps) {
      final dartPriority = computePriority(
        gap.deficit,
        gap.coverage,
        gap.demand,
      );
      expect(
        dartPriority,
        closeTo(gap.priority, 0.001),
        reason: 'Priority mismatch for ${gap.villageCode}/${gap.category}: '
            'Dart=$dartPriority, Python=${gap.priority}',
      );
    }
  });

  test('Dart quadrant classification matches Python', () {
    for (final gap in fixtureGaps) {
      final dartQuadrant = classifyQuadrant(gap.demand, gap.deficit);
      expect(
        dartQuadrant,
        equals(gap.quadrant),
        reason: 'Quadrant mismatch for ${gap.villageCode}/${gap.category}: '
            'Dart=$dartQuadrant, Python=${gap.quadrant} '
            '(demand=${gap.demand}, deficit=${gap.deficit})',
      );
    }
  });

  test('All four quadrants present in fixtures', () {
    final quadrants = fixtureGaps.map((g) => g.quadrant).toSet();
    expect(quadrants, contains('silent_gap'));
    expect(quadrants, contains('true_hotspot'));
    expect(quadrants, contains('phantom_demand'));
    expect(quadrants, contains('stable'));
  });

  test('Priority is always non-negative', () {
    for (final gap in fixtureGaps) {
      expect(gap.priority, greaterThanOrEqualTo(0.0));
    }
  });
}
