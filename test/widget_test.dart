import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/one_non_zero_game.dart';
import 'package:numbers_game/main.dart';

void main() {
  testWidgets('renders the initial board', (WidgetTester tester) async {
    await tester.pumpWidget(const NumbersGameApp());

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Select a source cell.'), findsOneWidget);
    expect(find.text('Moves: 0'), findsOneWidget);
    expect(undoButton(tester).onPressed, isNull);
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
    expect(find.text('Moves: 1'), findsOneWidget);
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

  testWidgets('undo restores the previous board and disables itself',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NumbersGameApp());

    await tester.tap(find.byKey(const Key('cell-0-0')));
    await tester.tap(find.byKey(const Key('cell-0-1')));
    await tester.pump();
    expect(undoButton(tester).onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('undo-button')));
    await tester.pump();

    expect(find.text('Move undone.'), findsOneWidget);
    expect(find.text('Moves: 0'), findsOneWidget);
    expect(find.bySemanticsLabel('Cell 1, 2: 2'), findsOneWidget);
    expect(undoButton(tester).onPressed, isNull);
  });

  testWidgets('restart restores the initial board and clears undo history',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NumbersGameApp());

    await dragTo(
      tester,
      const Key('row-handle-left-0'),
      const Key('row-handle-left-1'),
    );
    expect(undoButton(tester).onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('restart-button')));
    await tester.pump();

    expect(find.text('Game restarted.'), findsOneWidget);
    expect(find.text('Moves: 0'), findsOneWidget);
    expect(find.bySemanticsLabel('Cell 1, 1: 1'), findsOneWidget);
    expect(undoButton(tester).onPressed, isNull);
  });

  testWidgets('swaps rows by dragging a left handle', (WidgetTester tester) async {
    await tester.pumpWidget(const NumbersGameApp());

    await dragTo(
      tester,
      const Key('row-handle-left-0'),
      const Key('row-handle-left-1'),
    );

    expect(find.bySemanticsLabel('Cell 1, 1: 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Cell 2, 1: 1'), findsOneWidget);
  });

  testWidgets('swaps columns by dragging a top handle',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NumbersGameApp());

    await dragTo(
      tester,
      const Key('column-handle-top-0'),
      const Key('column-handle-top-1'),
    );

    expect(find.bySemanticsLabel('Cell 1, 1: 2'), findsOneWidget);
    expect(find.bySemanticsLabel('Cell 1, 2: 1'), findsOneWidget);
  });

  testWidgets('shows a vertical exchange indicator when hovering a row target',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NumbersGameApp());

    final source = find.byKey(const Key('row-handle-right-0'));
    final target = find.byKey(const Key('row-handle-right-1'));
    final gesture = await tester.startGesture(tester.getCenter(source));
    await gesture.moveTo(tester.getCenter(target));
    await tester.pump();

    expect(find.byKey(const Key('swap-indicator')), findsOneWidget);
    expect(find.text('⇅'), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('cancels a swap dropped outside a target',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NumbersGameApp());

    final source = find.byKey(const Key('column-handle-bottom-0'));
    final gesture = await tester.startGesture(tester.getCenter(source));
    await gesture.moveTo(const Offset(0, 0));
    await gesture.up();
    await tester.pump();

    expect(find.text('Swap cancelled.'), findsOneWidget);
    expect(find.bySemanticsLabel('Cell 1, 1: 1'), findsOneWidget);
  });

  testWidgets('right and bottom handles duplicate swap controls',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NumbersGameApp());

    await dragTo(
      tester,
      const Key('row-handle-right-0'),
      const Key('row-handle-right-1'),
    );
    await tester.pumpAndSettle();
    await dragTo(
      tester,
      const Key('column-handle-bottom-0'),
      const Key('column-handle-bottom-1'),
    );

    expect(find.bySemanticsLabel('Cell 1, 1: 4'), findsOneWidget);
  });

  testWidgets('shows a victory message for a winning board',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      NumbersGameApp(
        initialGame: OneNonZeroGame(Board([
          [0, 0],
          [0, 1],
        ])),
      ),
    );

    expect(find.byKey(const Key('victory-message')), findsOneWidget);
    expect(find.text('You won!'), findsOneWidget);
  });
}

Future<void> dragTo(
  WidgetTester tester,
  Key sourceKey,
  Key targetKey,
) async {
  final source = find.byKey(sourceKey);
  final target = find.byKey(targetKey);
  final gesture = await tester.startGesture(tester.getCenter(source));
  await gesture.moveTo(tester.getCenter(target));
  await gesture.up();
  await tester.pumpAndSettle();
}

OutlinedButton undoButton(WidgetTester tester) => tester.widget<OutlinedButton>(
      find.byKey(const Key('undo-button')),
    );
