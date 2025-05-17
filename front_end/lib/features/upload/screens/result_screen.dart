import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../upload_controller.dart';
import '../../report/screens/report_screen.dart';
import '../../../models/cvi_result.dart';

/// Screen to display CVI detection results
class ResultScreen extends ConsumerWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultState = ref.watch(uploadControllerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
      ),
      body: resultState.when(
        data: (CVIResult? result) {
          if (result == null) {
            return const Center(
              child: Text('No results available'),
            );
          }
          return _buildResultContent(context, result);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  /// Build the result content
  Widget _buildResultContent(BuildContext context, CVIResult result) {
    final theme = Theme.of(context);
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultHeader(theme, result),
            const SizedBox(height: 24),
            _buildConfidenceMeter(theme, result),
            const SizedBox(height: 24),
            _buildSummarySection(theme, result),
            const SizedBox(height: 16),
            _buildRecommendationsSection(theme, result),
            const Spacer(),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  /// Build the result header showing diagnosis and severity
  Widget _buildResultHeader(ThemeData theme, CVIResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Diagnosis',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(result.getSeverityColor()).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(result.getSeverityColor()),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.medical_information,
                color: Color(result.getSeverityColor()),
                size: 36,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.label,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${result.getSeverityLevel()} severity',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Color(result.getSeverityColor()),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build confidence meter with visual indicator
  Widget _buildConfidenceMeter(ThemeData theme, CVIResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: result.confidence,
            minHeight: 16,
            backgroundColor: theme.colorScheme.surfaceVariant,
            color: Color(result.getSeverityColor()),
          ),
        ),
      ],
    );
  }

  /// Build summary section
  Widget _buildSummarySection(ThemeData theme, CVIResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          result.summary,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  /// Build recommendations section
  Widget _buildRecommendationsSection(ThemeData theme, CVIResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommendations',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ...result.recommendations.map((recommendation) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Build action buttons (Back to Home, Send Report)
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ReportScreen(),
                ),
              );
            },
            child: const Text('Generate Report'),
          ),
        ),
      ],
    );
  }
} 