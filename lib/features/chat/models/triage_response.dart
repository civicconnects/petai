class TriageResponse {
  final String userAdvice;
  final String triageLevel; // 'Red', 'Yellow', 'Green'
  final bool isEmergency;
  final String reasoning;

  TriageResponse({
    required this.userAdvice,
    required this.triageLevel,
    required this.isEmergency,
    required this.reasoning,
  });

  factory TriageResponse.fromJson(Map<String, dynamic> json) {
    return TriageResponse(
      userAdvice: json['user_advice'] ?? "Please consult a veterinarian.",
      triageLevel: json['triage_level'] ?? 'Yellow',
      isEmergency: json['is_emergency'] ?? false,
      reasoning: json['reasoning'] ?? "",
    );
  }
}
