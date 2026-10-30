import 'package:flutter_test/flutter_test.dart';
import 'package:jantarmantar/main.dart';

void main() {
  testWidgets('Jantar Mantar App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const JantarMantarApp());
    expect(find.byType(JantarMantarApp), findsOneWidget);
  });
}
