import 'package:flutter/foundation.dart';
import '../models/card_item.dart';
import '../models/portfolio_snapshot.dart';
import '../models/price_point.dart';
import '../services/cardtrader_service.dart';
import '../services/storage_service.dart';
import '../services/bulk_import_service.dart';

class PortfolioProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  late CardTraderService _cardTraderService;

  List<CardItem> _cards = [];
  List<PortfolioSnapshot> _snapshots = [];
  String _selectedGameFilter = 'Tutti';
  String _searchQuery = '';
  String _sortBy = 'valore_desc'; // 'valore_desc', 'valore_asc', 'nome_asc'
  String? _cardTraderToken;
  bool _isLoading = false;

  PortfolioProvider() {
    _cardTraderService = CardTraderService();
    init();
  }

  // GETTERS
  List<CardItem> get cards => _cards;
  List<PortfolioSnapshot> get snapshots => _snapshots;
  String get selectedGameFilter => _selectedGameFilter;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  String? get cardTraderToken => _cardTraderToken;
  bool get isLoading => _isLoading;
  CardTraderService get cardTraderService => _cardTraderService;

  double get totalPortfolioValue =>
      _cards.fold(0.0, (sum, item) => sum + item.totalValue);

  int get totalCardCount =>
      _cards.fold(0, (sum, item) => sum + item.quantity);

  int get uniqueCardCount => _cards.length;

  /// Carte filtrate in base a ricerca, tab del gioco ed ordinamento
  List<CardItem> get filteredCards {
    return _cards.where((card) {
      final matchesGame = _selectedGameFilter == 'Tutti' ||
          card.game.toLowerCase() == _selectedGameFilter.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          card.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          card.setName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          card.cardNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesGame && matchesSearch;
    }).toList()
      ..sort((a, b) {
        if (_sortBy == 'valore_desc') {
          return b.totalValue.compareTo(a.totalValue);
        } else if (_sortBy == 'valore_asc') {
          return a.totalValue.compareTo(b.totalValue);
        } else {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        }
      });
  }

  /// Distribuzione del valore per ciascun TCG (per grafico a torta)
  Map<String, double> get gameValueDistribution {
    final Map<String, double> dist = {};
    for (final card in _cards) {
      dist[card.game] = (dist[card.game] ?? 0.0) + card.totalValue;
    }
    return dist;
  }

  // INIZIALIZZAZIONE
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _cardTraderToken = await _storageService.loadApiToken();
    _cardTraderService.apiToken = _cardTraderToken;

    _cards = await _storageService.loadCards();
    _snapshots = await _storageService.loadPortfolioHistory();

    // Se l'archivio è vuoto, carica subito i dati di fabbrica per un'esperienza immediata!
    if (_cards.isEmpty) {
      await loadFactorySampleData();
    } else {
      _ensureSnapshotRecorded();
    }

    _isLoading = false;
    notifyListeners();
  }

  // GESTIONE SELEZIONI E FILTRI
  void setGameFilter(String game) {
    _selectedGameFilter = game;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  Future<void> setCardTraderToken(String token) async {
    _cardTraderToken = token;
    _cardTraderService.apiToken = token;
    await _storageService.saveApiToken(token);
    notifyListeners();
  }

  // AZIONI SULLE CARTE
  Future<void> addCard(CardItem card) async {
    final now = DateTime.now();
    final updatedHistory = List<PricePoint>.from(card.priceHistory);
    if (updatedHistory.isEmpty) {
      updatedHistory.add(PricePoint(timestamp: now, price: card.currentPrice));
    }
    final newCard = card.copyWith(priceHistory: updatedHistory);
    _cards.add(newCard);
    await _saveAndRecord();
  }

  Future<void> updateCard(CardItem updatedCard) async {
    final index = _cards.indexWhere((c) => c.id == updatedCard.id);
    if (index != -1) {
      final oldCard = _cards[index];
      List<PricePoint> history = List<PricePoint>.from(updatedCard.priceHistory);
      if (oldCard.currentPrice != updatedCard.currentPrice) {
        history.add(PricePoint(
            timestamp: DateTime.now(), price: updatedCard.currentPrice));
      }
      _cards[index] = updatedCard.copyWith(priceHistory: history);
      await _saveAndRecord();
    }
  }

  Future<void> updateQuantity(String cardId, int delta) async {
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      final current = _cards[index];
      final newQty = current.quantity + delta;
      if (newQty <= 0) {
        _cards.removeAt(index);
      } else {
        _cards[index] = current.copyWith(quantity: newQty);
      }
      await _saveAndRecord();
    }
  }

  Future<void> deleteCard(String cardId) async {
    _cards.removeWhere((c) => c.id == cardId);
    await _saveAndRecord();
  }

  // CARICAMENTO FABBRICA & BULK JSON
  Future<void> loadFactorySampleData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final sampleCards = await BulkImportService.loadFactorySampleCards();
      _cards = sampleCards;
      _snapshots = _generateSampleSnapshotsFromCards(sampleCards);
      await _saveAndRecord();
    } catch (e) {
      debugPrint('Errore durante il caricamento dei dati di fabbrica: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> importJsonCards(List<CardItem> newCards,
      {bool replaceExisting = false}) async {
    if (replaceExisting) {
      _cards = newCards;
    } else {
      _cards.addAll(newCards);
    }
    await _saveAndRecord();
  }

  // AGGIORNAMENTO AUTOMATICO PREZZI CARDTRADER
  Future<void> autoRefreshPricesFromCardTrader() async {
    _isLoading = true;
    notifyListeners();

    for (int i = 0; i < _cards.length; i++) {
      final card = _cards[i];
      try {
        final res = await _cardTraderService.searchCard(
          card.name,
          card.game,
          cardNumber: card.cardNumber,
          setName: card.setName,
        );
        if (res != null && res.price > 0) {
          final history = List<PricePoint>.from(card.priceHistory);
          history.add(PricePoint(timestamp: DateTime.now(), price: res.price));
          _cards[i] = card.copyWith(
            currentPrice: res.price,
            imageUrl: res.imageUrl.isNotEmpty ? res.imageUrl : card.imageUrl,
            priceHistory: history,
          );
        }
      } catch (_) {}
    }

    await _saveAndRecord();
    _isLoading = false;
    notifyListeners();
  }

  // PERSISTENZA E RECORD SNAPS
  Future<void> _saveAndRecord() async {
    _ensureSnapshotRecorded();
    await _storageService.saveCards(_cards);
    await _storageService.savePortfolioHistory(_snapshots);
    notifyListeners();
  }

  void _ensureSnapshotRecorded() {
    final now = DateTime.now();
    final total = totalPortfolioValue;
    final count = totalCardCount;

    if (_snapshots.isEmpty) {
      _snapshots.add(PortfolioSnapshot(
          timestamp: now.subtract(const Duration(days: 30)),
          totalValue: total * 0.88,
          totalCardsCount: count));
      _snapshots.add(PortfolioSnapshot(
          timestamp: now.subtract(const Duration(days: 15)),
          totalValue: total * 0.94,
          totalCardsCount: count));
    }

    _snapshots.add(PortfolioSnapshot(
      timestamp: now,
      totalValue: total,
      totalCardsCount: count,
    ));
  }

  List<PortfolioSnapshot> _generateSampleSnapshotsFromCards(
      List<CardItem> sampleCards) {
    final now = DateTime.now();
    final total = sampleCards.fold(0.0, (s, c) => s + c.totalValue);
    final count = sampleCards.fold(0, (s, c) => s + c.quantity);

    return [
      PortfolioSnapshot(
          timestamp: now.subtract(const Duration(days: 90)),
          totalValue: total * 0.82,
          totalCardsCount: count),
      PortfolioSnapshot(
          timestamp: now.subtract(const Duration(days: 60)),
          totalValue: total * 0.89,
          totalCardsCount: count),
      PortfolioSnapshot(
          timestamp: now.subtract(const Duration(days: 30)),
          totalValue: total * 0.94,
          totalCardsCount: count),
      PortfolioSnapshot(
          timestamp: now, totalValue: total, totalCardsCount: count),
    ];
  }
}
