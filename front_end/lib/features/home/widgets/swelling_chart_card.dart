import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

/// Repository that provides swelling data for different time ranges
class SwellingRepository {
  static final Random _random = Random();
  static final double _baseValue = 3.5; // Base swelling value in millimeters
  
  /// Returns mock data for daily swelling values (24 hours)
  List<double> getDayData() {
    return List.generate(24, (index) {
      return _baseValue + _random.nextDouble() * 2;
    });
  }
  
  /// Returns mock data for weekly swelling values (7 days)
  List<double> getWeekData() {
    return List.generate(7, (index) {
      return _baseValue + _random.nextDouble() * 2.5;
    });
  }
  
  /// Returns mock data for monthly swelling values (30 days)
  List<double> getMonthData() {
    return List.generate(30, (index) {
      return _baseValue + _random.nextDouble() * 3;
    });
  }
  
  /// Returns mock data for yearly swelling values (12 months)
  List<double> getYearData() {
    return List.generate(12, (index) {
      return _baseValue + _random.nextDouble() * 4;
    });
  }
  
  /// Returns the latest swelling value
  double get latestValue {
    final dayData = getDayData();
    return dayData.last;
  }
}

/// Widget that displays a swelling chart with different time ranges
class SwellingChartCard extends StatefulWidget {
  const SwellingChartCard({Key? key}) : super(key: key);

  @override
  State<SwellingChartCard> createState() => _SwellingChartCardState();
}

class _SwellingChartCardState extends State<SwellingChartCard> {
  final SwellingRepository _repository = SwellingRepository();
  int _selectedRangeIndex = 0;
  final List<String> _timeRanges = ['Day', 'Week', 'Month', 'Year'];
  late List<double> _currentData;
  
  @override
  void initState() {
    super.initState();
    _currentData = _repository.getDayData();
  }
  
  /// Updates chart data based on selected time range
  void _updateChartData(int index) {
    setState(() {
      _selectedRangeIndex = index;
      switch (index) {
        case 0:
          _currentData = _repository.getDayData();
          break;
        case 1:
          _currentData = _repository.getWeekData();
          break;
        case 2:
          _currentData = _repository.getMonthData();
          break;
        case 3:
          _currentData = _repository.getYearData();
          break;
      }
    });
  }
  
  /// Determines whether the trend is increasing (red) or decreasing/stable (green)
  bool get _isIncreasing {
    if (_currentData.length < 2) return false;
    
    if (_selectedRangeIndex == 0 && _currentData.length >= 2) {
      // For day view, compare last two points
      return _currentData.last > _currentData[_currentData.length - 2];
    } else {
      // For other views, compare last point with first point
      return _currentData.last > _currentData.first;
    }
  }
  
  /// Returns the line chart color based on the trend
  Color get _lineColor {
    return _isIncreasing ? Colors.red : Colors.green;
  }
  
  /// Builds the segmented control for time range selection
  Widget _buildSegmentedControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CupertinoSegmentedControl<int>(
        children: Map.fromIterable(
          List.generate(_timeRanges.length, (index) => index),
          key: (index) => index,
          value: (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(_timeRanges[index]),
          ),
        ),
        onValueChanged: _updateChartData,
        groupValue: _selectedRangeIndex,
      ),
    );
  }
  
  /// Builds the line chart for swelling data
  Widget _buildChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            getDrawingHorizontalLine: _getGridLine,
            getDrawingVerticalLine: _getGridLine,
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: _getIntervalForXAxis(),
                getTitlesWidget: _getBottomTitles,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 40,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          minX: 0,
          maxX: (_currentData.length - 1).toDouble(),
          minY: (_currentData.reduce(min) - 0.5).clamp(0, double.infinity),
          maxY: _currentData.reduce(max) + 0.5,
          lineBarsData: [
            LineChartBarData(
              spots: _currentData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value);
              }).toList(),
              isCurved: true,
              color: _lineColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: _lineColor.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Determines the interval for X-axis based on selected time range
  double _getIntervalForXAxis() {
    switch (_selectedRangeIndex) {
      case 0: // Day
        return 4; // Show every 4 hours
      case 1: // Week
        return 1; // Show every day
      case 2: // Month
        return 5; // Show every 5 days
      case 3: // Year
        return 1; // Show every month
      default:
        return 1;
    }
  }
  
  /// Builds the bottom titles for the chart
  static Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontSize: 10,
    );
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(value.toInt().toString(), style: style),
    );
  }
  
  /// Returns grid line configuration
  static FlLine _getGridLine(double value) {
    return const FlLine(
      color: Color(0xffe7e8ec),
      strokeWidth: 1,
      dashArray: [5, 5],
    );
  }

  @override
  Widget build(BuildContext context) {
    final latestValue = _repository.latestValue;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Swelling Trend',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${latestValue.toStringAsFixed(1)} mm',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSegmentedControl(),
            const SizedBox(height: 8),
            _buildChart(),
          ],
        ),
      ),
    );
  }
} 