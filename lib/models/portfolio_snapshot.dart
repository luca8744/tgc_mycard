class PortfolioSnapshot {
  final DateTime timestamp;
  final double totalValue;
  final int totalCardsCount;

  PortfolioSnapshot({
    required this.timestamp,
    required this.totalValue,
    required this.totalCardsCount,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'totalValue': totalValue,
        'totalCardsCount': totalCardsCount,
      };

  factory PortfolioSnapshot.fromJson(Map<String, dynamic> json) =>
      PortfolioSnapshot(
        timestamp: DateTime.parse(json['timestamp'] as String),
        totalValue: (json['totalValue'] as num).toDouble(),
        totalCardsCount: (json['totalCardsCount'] as num).toInt(),
      );
}
