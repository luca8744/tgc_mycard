import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/card_item.dart';

class BulkImportService {
  /// Carica le carte dimostrative di fabbrica dal file assets/sample_cards.json
  static Future<List<CardItem>> loadFactorySampleCards() async {
    final String content =
        await rootBundle.loadString('assets/sample_cards.json');
    final List<dynamic> jsonList = jsonDecode(content);
    return jsonList
        .map((e) => CardItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Converte una stringa JSON in lista di carte
  static List<CardItem> importFromJsonString(String jsonContent) {
    final List<dynamic> jsonList = jsonDecode(jsonContent);
    return jsonList
        .map((e) => CardItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Converte la lista di carte in stringa JSON formattata per l'esportazione
  static String exportToJsonString(List<CardItem> cards) {
    final List<Map<String, dynamic>> jsonList =
        cards.map((c) => c.toJson()).toList();
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(jsonList);
  }

  /// Apre il selettore di file per scegliere un file JSON da importare
  static Future<List<CardItem>?> pickAndImportJsonFile() async {
    final result = await FilePickerPlatform.instance.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.isNotEmpty && result.first.path != null) {
      final file = File(result.first.path!);
      final content = await file.readAsString();
      return importFromJsonString(content);
    }
    return null;
  }
}
