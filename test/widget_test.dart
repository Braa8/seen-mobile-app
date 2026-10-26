import 'package:flutter_test/flutter_test.dart';
import 'package:seen_app/app/seen_app.dart';

void main() {
  testWidgets('Seen app builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SeenApp());

    expect(find.byType(SeenApp), findsOneWidget);
  });
}