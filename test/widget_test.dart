// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:personalwardrobe/app.dart';

void main() {
  testWidgets('App renders root tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const WardrobeApp());
    await tester.pumpAndSettle();

    expect(find.text('今日'), findsOneWidget);
    expect(find.text('日历'), findsOneWidget);
  });
}
