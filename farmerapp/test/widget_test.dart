import 'package:flutter_test/flutter_test.dart';
import 'package:farmerapp/main.dart';

void main() {
  testWidgets(
    'Farmer Market app starts',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const FarmerMarketApp(),
      );

      expect(
        find.text('Farmer Market'),
        findsOneWidget,
      );
    },
  );
}