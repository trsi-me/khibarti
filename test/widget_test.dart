import 'package:flutter_test/flutter_test.dart';

import 'package:khibarti/app.dart';

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const KhibartiApp());
    expect(find.text('LOGIN'), findsOneWidget);
  });
}
