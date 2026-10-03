import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numbers_game/main.dart';

void main() {
  testWidgets('renders the initial board', (WidgetTester tester) async {
    await tester.pumpWidget(const NumbersGameApp());

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Select a source cell.'), findsOneWidget);
  });

  testWidgets('selects a source cell', (WidgetTester tester) async {
    await tester.pumpWidget(const NumbersGameApp());

    await tester.tap(find.byKey(const Key('cell-0-0')));
    await tester.pump();

    expect(find.text('Source selected. Choose a target cell.'), findsOneWidget);
  });

  testWidgets('applies an arithmetic move after selecting two cells',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NumbersGameApp());

    await tester.tap(find.byKey(const Key('cell-0-0')));
    await tester.tap(find.byKey(const Key('cell-0-1')));
    await tester.pump();

    expect(find.text('Move applied.'), findsOneWidget);
    expect(find.text('2'), findsNothing);
    expect(find.text('3'), findsNWidgets(2));
  });

  testWidgets('shows feedback when target is the selected source',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NumbersGameApp());

    await tester.tap(find.byKey(const Key('cell-0-0')));
    await tester.tap(find.byKey(const Key('cell-0-0')));
    await tester.pump();

    expect(find.text('Choose a different target cell.'), findsOneWidget);
  });
}
