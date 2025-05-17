/// Data structure for leg daily statistics
class LegDailyStats {
  final String sedentaryHours;
  final String legElevation;
  final String standingTime;
  final String painLevel;

  const LegDailyStats({
    this.sedentaryHours = "3h 30m",
    this.legElevation = "1h 15m",
    this.standingTime = "4h 20m",
    this.painLevel = "2/10",
  });
}

/// Data structure for leg health indicators
class LegIndicators {
  final double bloodPressure; // 0.0 to 1.0
  final String bpText;
  final double swelling; // 0.0 to 1.0
  final String swellingText;
  final double temperature; // 0.0 to 1.0
  final String tempText;

  const LegIndicators({
    this.bloodPressure = 0.75,
    this.bpText = "120/80",
    this.swelling = 0.5,
    this.swellingText = "Moderate",
    this.temperature = 0.3,
    this.tempText = "37.0°C",
  });
} 