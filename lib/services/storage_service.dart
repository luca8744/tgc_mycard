import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/card_item.dart';
import '../models/portfolio_snapshot.dart';

class StorageService {
  static const String _cardsFilename = 'my_cards.json';
  static const String _historyFilename = 'portfolio_history.json';
  static const String _settingsFilename = 'app_settings.json';

  Future<File> _getFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$filename');
  }

  // CARTE
  Future<List<CardItem>> loadCards() async {
    try {
      final file = await _getFile(_cardsFilename);
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        return jsonList
            .map((e) => CardItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Errore durante il caricamento delle carte: $e');
    }
    return [];
  }

  Future<void> saveCards(List<CardItem> cards) async {
    try {
      final file = await _getFile(_cardsFilename);
      final jsonList = cards.map((c) => c.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Errore durante il salvataggio delle carte: $e');
    }
  }

  // STORICO PORTAFOGLIO
  Future<List<PortfolioSnapshot>> loadPortfolioHistory() async {
    try {
      final file = await _getFile(_historyFilename);
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        return jsonList
            .map((e) => PortfolioSnapshot.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Errore durante il caricamento dello storico portafoglio: $e');
    }
    return [];
  }

  Future<void> savePortfolioHistory(List<PortfolioSnapshot> history) async {
    try {
      final file = await _getFile(_historyFilename);
      final jsonList = history.map((s) => s.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Errore durante il salvataggio dello storico portafoglio: $e');
    }
  }

  // IMPOSTAZIONI API TOKEN (Caricamento dinamico da app_settings.json, file .env, --dart-define e Platform.environment)
  Future<String?> loadApiToken() async {
    try {
      final file = await _getFile(_settingsFilename);
      if (await file.exists()) {
        final content = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(content);
        final token = data['cardtrader_token'] as String?;
        if (token != null && token.trim().isNotEmpty) {
          debugPrint('🔑 Token CardTrader caricato da app_settings.json: ${token.substring(0, 15)}...');
          return token.trim();
        }
      }
    } catch (e) {
      debugPrint('Errore caricamento impostazioni: $e');
    }

    // 1. Fallback: Lettura dal file .env del progetto
    final dotEnvToken = await _loadFromDotEnvFile();
    if (dotEnvToken != null && dotEnvToken.isNotEmpty) {
      debugPrint('🔑 Token CardTrader caricato ESCLUSIVAMENTE dal file .env: ${dotEnvToken.substring(0, 15)}...');
      return dotEnvToken;
    }

    // 2. Fallback: Lettura da --dart-define=CARDTRADER_TOKEN=...
    const dartDefineToken = String.fromEnvironment('CARDTRADER_TOKEN');
    if (dartDefineToken.isNotEmpty) {
      debugPrint('🔑 Token CardTrader caricato da --dart-define');
      return dartDefineToken;
    }

    // 3. Fallback: Lettura da variabile d'ambiente dell'OS (export CARDTRADER_TOKEN=...)
    try {
      final sysEnvToken = Platform.environment['CARDTRADER_TOKEN'];
      if (sysEnvToken != null && sysEnvToken.trim().isNotEmpty) {
        debugPrint('🔑 Token CardTrader caricato da Platform.environment');
        return sysEnvToken.trim();
      }
    } catch (_) {}

    debugPrint('ℹ️ Nessun token CardTrader trovato (né in Impostazioni, né nel file .env)');
    return null;
  }

  Future<String?> _loadFromDotEnvFile() async {
    try {
      final possiblePaths = [
        '.env',
        '../.env',
        '/Users/lucamiliciani/Developer/tgc_mycard/.env',
        '${Directory.current.path}/.env'
      ];
      for (final path in possiblePaths) {
        final file = File(path);
        if (await file.exists()) {
          final lines = await file.readAsLines();
          for (final line in lines) {
            final trimmed = line.trim();
            if (trimmed.startsWith('#') || !trimmed.contains('=')) continue;
            final parts = trimmed.split('=');
            final key = parts[0].trim();
            final val = parts.sublist(1).join('=').trim().replaceAll('"', '').replaceAll("'", '');
            if (key == 'CARDTRADER_TOKEN' && val.isNotEmpty) {
              return val;
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveApiToken(String token) async {
    try {
      final file = await _getFile(_settingsFilename);
      await file.writeAsString(jsonEncode({'cardtrader_token': token}));
    } catch (e) {
      debugPrint('Errore salvataggio impostazioni: $e');
    }
  }
}
