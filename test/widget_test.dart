// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:catering_inventory_store_management_system/app.dart';

void main() {
  testWidgets('renders the inventory app shell', (tester) async {
    await tester.pumpWidget(const CateringInventoryApp());

    expect(find.text('Good morning'), findsOneWidget);
    expect(find.text('Ruth'), findsOneWidget);

    await tester.tap(find.text('Inventory'));
    await tester.pumpAndSettle();

    expect(find.text('Inventory'), findsWidgets);

    await tester.tap(find.text('Suppliers'));
    await tester.pumpAndSettle();

    expect(find.text('Suppliers'), findsWidgets);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    expect(find.text('More modules'), findsOneWidget);

    await tester.tap(find.text('Kitchen Issues'));
    await tester.pumpAndSettle();

    expect(find.text('Kitchen Issues'), findsWidgets);
  });
}
