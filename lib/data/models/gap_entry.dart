import '../../theme/tokens.dart';

class GapEntry {
  final String villageCode;
  final String category;
  final double demand;
  final double deficit;
  final double coverage;
  final double priority;
  final String quadrant;

  const GapEntry({
    required this.villageCode,
    required this.category,
    required this.demand,
    required this.deficit,
    required this.coverage,
    required this.priority,
    required this.quadrant,
  });

  Quadrant get quadrantEnum => switch (quadrant) {
    'silent_gap' => Quadrant.silentGap,
    'true_hotspot' => Quadrant.trueHotspot,
    'phantom_demand' => Quadrant.phantomDemand,
    _ => Quadrant.stable,
  };

  factory GapEntry.fromJson(Map<String, dynamic> json) => GapEntry(
    villageCode: json['village_code'] as String,
    category: json['category'] as String,
    demand: (json['demand'] as num).toDouble(),
    deficit: (json['deficit'] as num).toDouble(),
    coverage: (json['coverage'] as num).toDouble(),
    priority: (json['priority'] as num).toDouble(),
    quadrant: json['quadrant'] as String,
  );

  Map<String, dynamic> toJson() => {
    'village_code': villageCode,
    'category': category,
    'demand': demand,
    'deficit': deficit,
    'coverage': coverage,
    'priority': priority,
    'quadrant': quadrant,
  };
}
