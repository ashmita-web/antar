class Village {
  final String villageCode;
  final String villageName;
  final String block;
  final String district;
  final String state;
  final int population;
  final int households;
  final double lat;
  final double lon;
  final bool coordApprox;
  final double roadPuccaPct;
  final double tapWaterPct;
  final double toiletPct;
  final double electricityPct;
  final int healthCenterWithin5km;
  final int schoolWithin3km;
  final double internetPct;
  final int bankWithin5km;
  final int busStopWithin5km;
  final bool synthetic;

  const Village({
    required this.villageCode,
    required this.villageName,
    required this.block,
    required this.district,
    required this.state,
    required this.population,
    required this.households,
    required this.lat,
    required this.lon,
    required this.coordApprox,
    required this.roadPuccaPct,
    required this.tapWaterPct,
    required this.toiletPct,
    required this.electricityPct,
    required this.healthCenterWithin5km,
    required this.schoolWithin3km,
    required this.internetPct,
    required this.bankWithin5km,
    required this.busStopWithin5km,
    required this.synthetic,
  });

  factory Village.fromJson(Map<String, dynamic> json) => Village(
    villageCode: json['village_code'] as String,
    villageName: json['village_name'] as String,
    block: json['block'] as String,
    district: json['district'] as String,
    state: json['state'] as String,
    population: json['population'] as int,
    households: json['households'] as int,
    lat: (json['lat'] as num).toDouble(),
    lon: (json['lon'] as num).toDouble(),
    coordApprox: json['coord_approx'] as bool? ?? true,
    roadPuccaPct: (json['road_pucca_pct'] as num).toDouble(),
    tapWaterPct: (json['tap_water_pct'] as num).toDouble(),
    toiletPct: (json['toilet_pct'] as num).toDouble(),
    electricityPct: (json['electricity_pct'] as num).toDouble(),
    healthCenterWithin5km: json['health_center_within_5km'] as int,
    schoolWithin3km: json['school_within_3km'] as int,
    internetPct: (json['internet_pct'] as num).toDouble(),
    bankWithin5km: json['bank_within_5km'] as int,
    busStopWithin5km: json['bus_stop_within_5km'] as int,
    synthetic: json['synthetic'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'village_code': villageCode,
    'village_name': villageName,
    'block': block,
    'district': district,
    'state': state,
    'population': population,
    'households': households,
    'lat': lat,
    'lon': lon,
    'coord_approx': coordApprox,
    'road_pucca_pct': roadPuccaPct,
    'tap_water_pct': tapWaterPct,
    'toilet_pct': toiletPct,
    'electricity_pct': electricityPct,
    'health_center_within_5km': healthCenterWithin5km,
    'school_within_3km': schoolWithin3km,
    'internet_pct': internetPct,
    'bank_within_5km': bankWithin5km,
    'bus_stop_within_5km': busStopWithin5km,
    'synthetic': synthetic,
  };
}
