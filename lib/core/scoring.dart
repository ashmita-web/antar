import '../data/models/village.dart';

const quadrantThreshold = 0.5;

double computeDeficit(Village village, String category) {
  return switch (category) {
    'road' => 1.0 - village.roadPuccaPct / 100.0,
    'water' => 1.0 - village.tapWaterPct / 100.0,
    'sanitation' => 1.0 - village.toiletPct / 100.0,
    'electricity' => 1.0 - village.electricityPct / 100.0,
    'health' => 1.0 - village.healthCenterWithin5km.toDouble(),
    'education' => 1.0 - village.schoolWithin3km.toDouble(),
    'internet' => 1.0 - village.internetPct / 100.0,
    'banking' => 1.0 - village.bankWithin5km.toDouble(),
    'transport' => 1.0 - village.busStopWithin5km.toDouble(),
    _ => 0.0,
  };
}

double computePriority(double deficit, double coverage, double demand) {
  return deficit * (1.0 - coverage) * (0.7 + 0.3 * demand);
}

String classifyQuadrant(double demand, double deficit,
    {double threshold = quadrantThreshold}) {
  if (deficit >= threshold && demand < threshold) return 'silent_gap';
  if (deficit >= threshold && demand >= threshold) return 'true_hotspot';
  if (deficit < threshold && demand >= threshold) return 'phantom_demand';
  return 'stable';
}
