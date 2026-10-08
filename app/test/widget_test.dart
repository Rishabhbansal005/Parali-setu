import 'package:flutter_test/flutter_test.dart';
import 'package:parali_setu/main.dart';

void main() {
  testWidgets('ParaliSetuApp boots smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ParaliSetuApp());
    expect(find.text('पराली सेतु'), findsOneWidget);
    expect(find.text('हिंदी'), findsOneWidget);
    expect(find.text('Hindi'), findsOneWidget);
  });
}
