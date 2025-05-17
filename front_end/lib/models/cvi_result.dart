/// Model class for CVI detection result
class CVIResult {
  final String label;
  final double confidence;
  final String summary;
  final List<String> recommendations;
  final String? imageUrl;

  CVIResult({
    required this.label,
    required this.confidence,
    required this.summary,
    required this.recommendations,
    this.imageUrl,
  });

  /// Create a CVIResult from JSON data
  factory CVIResult.fromJson(Map<String, dynamic> json) {
    return CVIResult(
      label: json['label'] ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      summary: json['summary'] ?? 'No summary available',
      recommendations: List<String>.from(json['recommendations'] ?? []),
      imageUrl: json['image_url'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
      'summary': summary,
      'recommendations': recommendations,
      'image_url': imageUrl,
    };
  }
  
  /// Get severity level based on confidence
  String getSeverityLevel() {
    if (confidence >= 0.75) {
      return 'Severe';
    } else if (confidence >= 0.5) {
      return 'Moderate';
    } else if (confidence >= 0.25) {
      return 'Mild';
    } else {
      return 'Normal';
    }
  }
  
  /// Get color for severity level
  int getSeverityColor() {
    if (confidence >= 0.75) {
      return 0xFFE53935; // Red
    } else if (confidence >= 0.5) {
      return 0xFFEF6C00; // Orange
    } else if (confidence >= 0.25) {
      return 0xFFFDD835; // Yellow
    } else {
      return 0xFF43A047; // Green
    }
  }
} 