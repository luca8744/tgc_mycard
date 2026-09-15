class PricePoint {
  final DateTime timestamp;
  final double price;

  PricePoint({
    required this.timestamp,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'price': price,
      };

  factory PricePoint.fromJson(Map<String, dynamic> json) => PricePoint(
        timestamp: DateTime.parse(json['timestamp'] as String),
        price: (json['price'] as num).toDouble(),
      );
}
