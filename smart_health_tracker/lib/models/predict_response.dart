class PredictResponse {
  final String condition;
  final String message;
  final List<Issue> issues;

  PredictResponse({
    required this.condition,
    required this.message,
    required this.issues,
  });

  factory PredictResponse.fromJson(Map<String, dynamic> json) {
    return PredictResponse(
      condition: json['condition'] ?? "Unknown",
      message: json['message'] ?? "",
      issues: (json['issues'] as List<dynamic>?)
              ?.map((e) => Issue.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Issue {
  final String parameter;
  final String status;
  final double value;
  final String suggestion;

  Issue({
    required this.parameter,
    required this.status,
    required this.value,
    required this.suggestion,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      parameter: json['parameter'] ?? "",
      status: json['status'] ?? "",
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      suggestion: json['suggestion'] ?? "",
    );
  }
}
