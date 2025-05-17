import 'dart:convert';

enum CVISeverity {
  normal,
  moderate,
  severe,
}

class CVIResult {
  final String filename;
  final CVISeverity severity;
  final Map<String, double> probabilities;

  CVIResult({
    required this.filename,
    required this.severity,
    required this.probabilities,
  });

  factory CVIResult.fromJson(Map<String, dynamic> json) {
    // Parse the predicted class name to the enum
    final String predictedClassName = json['predicted_class_name'] as String;
    final CVISeverity severity = CVISeverity.values.firstWhere(
      (e) => e.toString().split('.').last == predictedClassName,
      orElse: () => CVISeverity.normal,
    );

    // Parse the probabilities map
    final Map<String, dynamic> probJson = json['probabilities'] as Map<String, dynamic>;
    final Map<String, double> probabilities = {};
    for (final entry in probJson.entries) {
      probabilities[entry.key] = entry.value.toDouble();
    }

    return CVIResult(
      filename: json['filename'] as String,
      severity: severity,
      probabilities: probabilities,
    );
  }

  static CVIResult fromResponseBody(String body) {
    final Map<String, dynamic> jsonMap = json.decode(body) as Map<String, dynamic>;
    return CVIResult.fromJson(jsonMap);
  }
} 