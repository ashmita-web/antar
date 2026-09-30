class CandidateProject {
  final String candidateId;
  final String villageCode;
  final String villageName;
  final String block;
  final String category;
  final String projectType;
  final String projectLabel;
  final int indicativeCost;
  final int beneficiaries;
  final double priority;
  final String quadrant;
  final String fundHint;
  final bool synthetic;

  const CandidateProject({
    required this.candidateId,
    required this.villageCode,
    required this.villageName,
    required this.block,
    required this.category,
    required this.projectType,
    required this.projectLabel,
    required this.indicativeCost,
    required this.beneficiaries,
    required this.priority,
    required this.quadrant,
    required this.fundHint,
    required this.synthetic,
  });

  factory CandidateProject.fromJson(Map<String, dynamic> json) =>
      CandidateProject(
        candidateId: json['candidate_id'] as String,
        villageCode: json['village_code'] as String,
        villageName: json['village_name'] as String,
        block: json['block'] as String,
        category: json['category'] as String,
        projectType: json['project_type'] as String,
        projectLabel: json['project_label'] as String,
        indicativeCost: json['indicative_cost'] as int,
        beneficiaries: json['beneficiaries'] as int,
        priority: (json['priority'] as num).toDouble(),
        quadrant: json['quadrant'] as String,
        fundHint: json['fund_hint'] as String? ?? '',
        synthetic: json['synthetic'] as bool? ?? false,
      );
}
