import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/one_non_zero_game.dart';
import 'package:numbers_game/game_state_store.dart';
import 'package:numbers_game/main.dart';
import 'package:numbers_game/settings_screen.dart';
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
    await tester.pumpWidget(
      NumbersGameApp(
        progressStore: progress,
        gameStateStore: _FakeGameStateStore(),
      ),
    );
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
      NumbersGameApp(
        progressStore: _FakeTutorialProgressStore(handled: false),
        gameStateStore: _FakeGameStateStore(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('skip-tutorial-button')), findsOneWidget);
  });

  testWidgets('restores the saved game automatically', (WidgetTester tester) async {
    final savedGame = OneNonZeroGame(Board([
      [1, 2],
      [3, 4],
    ])).applyArithmeticMove(
      source: const CellPosition(0, 0),
      target: const CellPosition(0, 1),
    );
    await tester.pumpWidget(
      NumbersGameApp(
        progressStore: _FakeTutorialProgressStore(handled: true),
        gameStateStore: _FakeGameStateStore(
          currentGame: SavedGame(settings: const GameSettings(), game: savedGame),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Moves: 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Cell 1, 2: 3'), findsOneWidget);
  });

  testWidgets('new game retains settings and replaces the saved session',
      (WidgetTester tester) async {
    final store = _FakeGameStateStore(
      settings: const GameSettings(boardSize: 3),
      currentGame: SavedGame(
        settings: const GameSettings(boardSize: 3),
        game: OneNonZeroGame(Board([
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])).swapRows(0, 1),
      ),
    );
    await tester.pumpWidget(
      NumbersGameApp(
        progressStore: _FakeTutorialProgressStore(handled: true),
        gameStateStore: store,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('new-game-button')));
    await tester.pumpAndSettle();

    expect(store.clearCount, 1);
    expect(store.settings.boardSize, 3);
    expect(store.currentGame!.game.moveCount, 0);
    expect(find.bySemanticsLabel('Cell 3, 3: 9'), findsOneWidget);
  });

  testWidgets('settings update future games without changing the current game',
      (WidgetTester tester) async {
    final currentGame = OneNonZeroGame(Board([
      [1, 2],
      [3, 4],
    ])).applyArithmeticMove(
      source: const CellPosition(0, 0),
      target: const CellPosition(0, 1),
    );
    final store = _FakeGameStateStore(
      currentGame: SavedGame(settings: const GameSettings(), game: currentGame),
    );
    await tester.pumpWidget(
      NumbersGameApp(
        progressStore: _FakeTutorialProgressStore(handled: true),
        gameStateStore: store,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('game-mode-one-non-zero')), findsOneWidget);

    await tester.tap(find.byKey(const Key('increase-board-size-button')));
    await tester.tap(find.byKey(const Key('save-settings-button')));
    await tester.pumpAndSettle();

    expect(store.settings.boardSize, 3);
    expect(find.text('Moves: 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Cell 1, 2: 3'), findsOneWidget);

    await tester.tap(find.byKey(const Key('new-game-button')));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Cell 3, 3: 9'), findsOneWidget);
  });

  testWidgets('settings keep the board size at two or more', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SettingsScreen(settings: GameSettings())),
    );

    final decreaseButton = tester.widget<IconButton>(
      find.byKey(const Key('decrease-board-size-button')),
    );
    await tester.pump();

    expect(decreaseButton.onPressed, isNull);
    expect(find.byKey(const Key('board-size-value')), findsOneWidget);
    expect(find.text('2 × 2'), findsOneWidget);
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

class _FakeGameStateStore implements GameStateStore {
  _FakeGameStateStore({
    this.settings = const GameSettings(),
    this.currentGame,
  });

  GameSettings settings;
  SavedGame? currentGame;
  int clearCount = 0;

  @override
  Future<void> clearCurrentGame() async {
    clearCount++;
    currentGame = null;
  }

  @override
  Future<SavedGame?> loadCurrentGame() async => currentGame;

  @override
  Future<GameSettings> loadSettings() async => settings;

  @override
  Future<void> saveCurrentGame(SavedGame game) async {
    currentGame = game;
  }

  @override
  Future<void> saveSettings(GameSettings settings) async {
    this.settings = settings;
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
