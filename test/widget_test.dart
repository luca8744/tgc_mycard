import 'package:flutter_test/flutter_test.dart';
import 'package:tgc_mycard/main.dart';
import 'package:tgc_mycard/services/cardtrader_service.dart';

void main() {
  testWidgets('TCG MyCard app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const TcgMyCardApp());
    expect(find.text('TCG MyCard'), findsOneWidget);
  });

  test('CardTraderService searches Loki Secret Rare and One Piece codes correctly', () async {
    final service = CardTraderService();

    // Test 1: Query combinata
    final result1 = await service.searchCard('Loki op17-119', 'One Piece');
    expect(result1, isNotNull);
    expect(result1!.name, contains('Loki'));
    expect(result1.cardNumber, equals('OP17-119'));
    expect(result1.imageUrl, contains('OP17-119_EN.png'));

    // Test 2: Solo codice OP17-119
    final result2 = await service.searchCard('op17-119', 'One Piece');
    expect(result2, isNotNull);
    expect(result2!.cardNumber, equals('OP17-119'));
    expect(result2.name, contains('Loki'));

    // Test 3: Spaziatura variante op 17 119
    final result3 = await service.searchCard('Loki op 17 119', 'One Piece');
    expect(result3, isNotNull);
    expect(result3!.cardNumber, equals('OP17-119'));
  });
}
