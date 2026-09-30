class CitizenRequest {
  final String requestId;
  final String villageCode;
  final String villageName;
  final String block;
  final String timestamp;
  final String language;
  final String languageName;
  final String category;
  final String subtype;
  final int severity;
  final int peopleAffectedEstimate;
  final String transcriptEn;
  final String summaryEn;
  final String status;
  final bool synthetic;

  const CitizenRequest({
    required this.requestId,
    required this.villageCode,
    required this.villageName,
    required this.block,
    required this.timestamp,
    required this.language,
    required this.languageName,
    required this.category,
    required this.subtype,
    required this.severity,
    required this.peopleAffectedEstimate,
    required this.transcriptEn,
    required this.summaryEn,
    required this.status,
    required this.synthetic,
  });

  factory CitizenRequest.fromJson(Map<String, dynamic> json) => CitizenRequest(
    requestId: json['request_id'] as String,
    villageCode: json['village_code'] as String,
    villageName: json['village_name'] as String,
    block: json['block'] as String,
    timestamp: json['timestamp'] as String,
    language: json['language'] as String,
    languageName: json['language_name'] as String,
    category: json['category'] as String,
    subtype: json['subtype'] as String,
    severity: json['severity'] as int,
    peopleAffectedEstimate: json['people_affected_estimate'] as int,
    transcriptEn: json['transcript_en'] as String,
    summaryEn: json['summary_en'] as String,
    status: json['status'] as String,
    synthetic: json['synthetic'] as bool? ?? false,
  );
}
