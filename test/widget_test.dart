import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/one_non_zero_game.dart';
import 'package:numbers_game/main.dart';
import 'package:numbers_game/tutorial.dart';
import 'package:numbers_game/tutorial_progress_store.dart';

void main() {
  testWidgets('renders the initial board', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Select a source cell.'), findsOneWidget);
    expect(find.text('Moves: 0'), findsOneWidget);
    expect(undoButton(tester).onPressed, isNull);
  });

  testWidgets('selects a source cell', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

    await tester.tap(find.byKey(const Key('cell-0-0')));
    await tester.pump();

    expect(find.text('Source selected. Choose a target cell.'), findsOneWidget);
  });

  testWidgets('applies an arithmetic move after selecting two cells',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

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
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

    await tester.tap(find.byKey(const Key('cell-0-0')));
    await tester.tap(find.byKey(const Key('cell-0-0')));
    await tester.pump();

    expect(find.text('Choose a different target cell.'), findsOneWidget);
  });

  testWidgets('undo restores the previous board and disables itself',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

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
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

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
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

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
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

    await dragTo(
      tester,
      const Key('column-handle-top-0'),
      const Key('column-handle-top-1'),
    );

    expect(find.bySemanticsLabel('Cell 1, 1: 2'), findsOneWidget);
    expect(find.bySemanticsLabel('Cell 1, 2: 1'), findsOneWidget);
  });

  testWidgets('undo uses the swap animation for a row swap',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

    await dragTo(
      tester,
      const Key('row-handle-left-0'),
      const Key('row-handle-left-1'),
    );

    await tester.tap(find.byKey(const Key('undo-button')));
    await tester.pump();

    expect(find.byKey(const Key('swap-source-highlight')), findsOneWidget);
    expect(find.byKey(const Key('swap-target-highlight')), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Cell 1, 1: 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Cell 2, 1: 3'), findsOneWidget);
  });

  testWidgets('undo uses the swap animation for a column swap',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

    await dragTo(
      tester,
      const Key('column-handle-top-0'),
      const Key('column-handle-top-1'),
    );

    await tester.tap(find.byKey(const Key('undo-button')));
    await tester.pump();

    expect(find.byKey(const Key('swap-source-highlight')), findsOneWidget);
    expect(find.byKey(const Key('swap-target-highlight')), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Cell 1, 1: 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Cell 1, 2: 2'), findsOneWidget);
  });

  testWidgets('shows a vertical exchange indicator when hovering a row target',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

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
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

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
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

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
      MaterialApp(home: BoardScreen(
        initialGame: OneNonZeroGame(Board([
          [0, 0],
          [0, 1],
        ])),
      )),
    );

    expect(find.byKey(const Key('victory-message')), findsOneWidget);
    expect(find.text('You won!'), findsOneWidget);
  });

  testWidgets('shows a loss message for a board with one negative cell',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: BoardScreen(
        initialGame: OneNonZeroGame(Board([
          [0, 0],
          [0, -1],
        ])),
      )),
    );

    expect(find.byKey(const Key('loss-message')), findsOneWidget);
    expect(find.text('You lost!'), findsOneWidget);
    expect(find.byKey(const Key('victory-message')), findsNothing);
  });

  testWidgets('tutorial advances only after its expected actions',
      (WidgetTester tester) async {
    var finished = false;
    await tester.pumpWidget(
      MaterialApp(
        home: BoardScreen(
          initialGame: tutorialDefinition.initialGame,
          tutorial: tutorialDefinition,
          onTutorialFinished: () async => finished = true,
        ),
      ),
    );

    expect(find.byKey(const Key('tutorial-arrow-cell-0-0')), findsOneWidget);
    expect(find.byKey(const Key('tutorial-arrow-cell-0-1')), findsNothing);
    await tester.tap(find.byKey(const Key('cell-1-0')));
    await tester.pump();
    expect(find.textContaining('source cell does not change'), findsWidgets);

    await tester.tap(find.byKey(const Key('cell-0-0')));
    await tester.pump();
    expect(find.byKey(const Key('tutorial-arrow-cell-0-1')), findsOneWidget);
    await tester.tap(find.byKey(const Key('cell-0-1')));
    await tester.pump();
    expect(find.textContaining('swaps the whole columns'), findsWidgets);
    expect(find.byKey(const Key('tutorial-arrow-column-0')), findsOneWidget);

    await dragTo(
      tester,
      const Key('column-handle-top-0'),
      const Key('column-handle-top-1'),
    );
    expect(find.textContaining('source minus target'), findsWidgets);

    await tester.ensureVisible(find.byKey(const Key('cell-1-1')));
    await tester.tap(find.byKey(const Key('cell-1-1')));
    await tester.tap(find.byKey(const Key('cell-0-1')));
    await tester.pump();
    expect(find.byKey(const Key('finish-tutorial-button')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('finish-tutorial-button')));
    await tester.tap(find.byKey(const Key('finish-tutorial-button')));
    await tester.pump();
    expect(finished, isTrue);
  });

  testWidgets('completed tutorial is not opened automatically and can be restarted',
      (WidgetTester tester) async {
    final progress = _FakeTutorialProgressStore(handled: true);
    await tester.pumpWidget(NumbersGameApp(progressStore: progress));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('start-tutorial-button')), findsOneWidget);
    await tester.tap(find.byKey(const Key('start-tutorial-button')));
    await tester.pump();
    expect(find.byKey(const Key('skip-tutorial-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('skip-tutorial-button')));
    await tester.pumpAndSettle();
    expect(progress.handled, isTrue);
    expect(find.byKey(const Key('start-tutorial-button')), findsOneWidget);
  });

  testWidgets('first launch opens the tutorial', (WidgetTester tester) async {
    await tester.pumpWidget(
      NumbersGameApp(progressStore: _FakeTutorialProgressStore(handled: false)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('skip-tutorial-button')), findsOneWidget);
  });

  testWidgets('tutorial restart returns to its first step', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BoardScreen(
          initialGame: tutorialDefinition.initialGame,
          tutorial: tutorialDefinition,
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('cell-0-0')));
    await tester.tap(find.byKey(const Key('cell-0-1')));
    await tester.pump();
    expect(find.textContaining('swaps the whole columns'), findsWidgets);

    await tester.tap(find.byKey(const Key('restart-button')));
    await tester.pump();
    expect(find.textContaining('source cell does not change'), findsWidgets);
    expect(find.text('Moves: 0'), findsOneWidget);
  });
}

class _FakeTutorialProgressStore implements TutorialProgressStore {
  _FakeTutorialProgressStore({required this.handled});

  bool handled;

  @override
  Future<bool> hasCompletedOrDismissed() async => handled;

  @override
  Future<void> markCompletedOrDismissed() async {
    handled = true;
  }
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
