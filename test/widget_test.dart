import 'package:flutter_test/flutter_test.dart';
import 'package:solo_levelling/main.dart';

void main() {
  testWidgets('SoloLevellingApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SoloLevellingApp());
    expect(find.text('HUNTER HUD'), findsOneWidget);
  });
}
