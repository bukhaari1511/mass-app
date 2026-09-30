import 'package:flutter_test/flutter_test.dart';
import 'package:mass_spare_parts/app/app.dart';

void main() {
  testWidgets('Mass Spare Parts app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MassSparePartsApp());

    // Verify app title exists
    expect(find.text('MASS SPARE PARTS'), findsOneWidget);
  });
}
