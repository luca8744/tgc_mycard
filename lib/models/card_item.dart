import 'price_point.dart';

class CardItem {
  final String id;
  final String name;
  final String game; // 'Magic', 'Pokémon', 'Lorcana', 'One Piece', 'Altro'
  final String setName;
  final String cardNumber;
  final String imageUrl;
  final double currentPrice;
  final int quantity;
  final String rarity;
  final List<PricePoint> priceHistory;

  CardItem({
    required this.id,
    required this.name,
    required this.game,
    required this.setName,
    required this.cardNumber,
    required this.imageUrl,
    required this.currentPrice,
    required this.quantity,
    this.rarity = '',
    List<PricePoint>? priceHistory,
  }) : priceHistory = priceHistory ?? [];

  double get totalValue => currentPrice * quantity;

  double get priceChangePercentage {
    if (priceHistory.isEmpty || priceHistory.first.price == 0) return 0.0;
    final initialPrice = priceHistory.first.price;
    return ((currentPrice - initialPrice) / initialPrice) * 100;
  }

  CardItem copyWith({
    String? id,
    String? name,
    String? game,
    String? setName,
    String? cardNumber,
    String? imageUrl,
    double? currentPrice,
    int? quantity,
    String? rarity,
    List<PricePoint>? priceHistory,
  }) {
    return CardItem(
      id: id ?? this.id,
      name: name ?? this.name,
      game: game ?? this.game,
      setName: setName ?? this.setName,
      cardNumber: cardNumber ?? this.cardNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      currentPrice: currentPrice ?? this.currentPrice,
      quantity: quantity ?? this.quantity,
      rarity: rarity ?? this.rarity,
      priceHistory: priceHistory ?? List.from(this.priceHistory),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'game': game,
        'setName': setName,
        'cardNumber': cardNumber,
        'imageUrl': imageUrl,
        'currentPrice': currentPrice,
        'quantity': quantity,
        'rarity': rarity,
        'priceHistory': priceHistory.map((p) => p.toJson()).toList(),
      };

  factory CardItem.fromJson(Map<String, dynamic> json) {
    return CardItem(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Carta Sconosciuta',
      game: json['game'] as String? ?? 'Altro',
      setName: json['setName'] as String? ?? '',
      cardNumber: json['cardNumber'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      rarity: json['rarity'] as String? ?? '',
      priceHistory: (json['priceHistory'] as List<dynamic>?)
              ?.map((p) => PricePoint.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
