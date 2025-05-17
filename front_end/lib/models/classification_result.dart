import 'package:flutter/material.dart';

/// Results from the CVI image classification
class ClassificationResult {
  final String severity;
  final String explainer;
  final String tip;
  final double confidence;

  const ClassificationResult({
    required this.severity,
    required this.explainer,
    required this.tip,
    required this.confidence,
  });

  /// Get color based on severity
  Color get color {
    switch (severity.toLowerCase()) {
      case "normal":
        return Colors.green;
      case "moderate":
        return Colors.orange;
      case "severe":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  /// Factory method to create a ClassificationResult with predefined text based on severity
  factory ClassificationResult.withSeverity(String severity, double confidence) {
    String explainer;
    String tip;
    
    switch (severity.toLowerCase()) {
      case "normal":
        explainer = "No significant signs of Chronic Venous Insufficiency (CVI) detected.";
        tip = "Maintain a healthy lifestyle, engage in regular exercise, and elevate your legs when resting to promote good vein health.";
        break;
      case "moderate":
        explainer = "Some indicators consistent with moderate Chronic Venous Insufficiency (CVI) are present.";
        tip = "Consider consulting a healthcare professional for further evaluation. They may recommend lifestyle changes, compression therapy, or other measures.";
        break;
      case "severe":
        explainer = "Signs consistent with severe Chronic Venous Insufficiency (CVI) are detected.";
        tip = "It is highly recommended to seek prompt medical consultation for a comprehensive diagnosis and management plan. Do not delay in contacting your doctor.";
        break;
      default:
        explainer = "Unknown classification.";
        tip = "Please consult a healthcare professional if you have concerns.";
    }
    
    return ClassificationResult(
      severity: severity,
      explainer: explainer,
      tip: tip,
      confidence: confidence,
    );
  }
} 