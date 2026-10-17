import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/game_session.dart';
import 'package:numbers_game/game_core/historical_date_game.dart';
import 'package:numbers_game/game_core/one_non_zero_game.dart';
import 'package:numbers_game/game_state_store.dart';
import 'package:numbers_game/main.dart';
import 'package:numbers_game/settings_screen.dart';
import 'package:numbers_game/tutorial.dart';
import 'package:numbers_game/tutorial_progress_store.dart';

String feedbackText(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('feedback'))).textSpan!.toPlainText();

void main() {
  testWidgets('renders the initial board', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(feedbackText(tester), 'Choose a source cell. Then choose a target to transform it.');
    expect(find.text('Moves: 0'), findsOneWidget);
    expect(undoButton(tester).onPressed, isNull);
  });

  testWidgets('disables non-essential board animations for reduced motion',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: BoardScreen(),
        ),
      ),
    );

    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale).first).duration,
      Duration.zero,
    );
    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale).first).duration,
      Duration.zero,
    );
  });

  testWidgets('reduced motion completes a swap without transient animation state',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: BoardScreen(),
        ),
      ),
    );

    final source = find.byKey(const Key('row-handle-left-0'));
    final target = find.byKey(const Key('row-handle-left-1'));
    final gesture = await tester.startGesture(tester.getCenter(source));
    await gesture.moveTo(tester.getCenter(target));
    await gesture.up();
    await tester.pump();

    expect(find.byKey(const Key('swap-source-highlight')), findsNothing);
    expect(find.byKey(const Key('swap-target-highlight')), findsNothing);
    expect(find.bySemanticsLabel('Cell 1, 1: 3'), findsOneWidget);
    expect(undoButton(tester).onPressed, isNotNull);
  });

  testWidgets('scales a large cell value to fit the board cell',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BoardScreen(
          initialGame: OneNonZeroGame(Board([
            [123456789, 1],
            [1, 1],
          ])),
        ),
      ),
    );

    expect(find.text('123456789'), findsOneWidget);
    expect(find.byType(FittedBox), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selects a source cell', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

    await tester.tap(find.byKey(const Key('cell-0-0')));
    await tester.pump();

    expect(find.text('1 is the source. Choose a different target cell.'), findsOneWidget);
  });

  testWidgets('applies an arithmetic move after selecting two cells',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

    await tester.tap(find.byKey(const Key('cell-0-0')));
    await tester.tap(find.byKey(const Key('cell-0-1')));
    await tester.pump();

    expect(feedbackText(tester), '1 + 2 = 3. Choose a source cell.');
    final feedback = tester.widget<Text>(find.byKey(const Key('feedback')));
    final headline = (feedback.textSpan! as TextSpan).children!.first as TextSpan;
    expect(headline.style!.fontWeight, FontWeight.w600);
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
    await tester.pump(const Duration(milliseconds: 2210));
    expect(undoButton(tester).onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('undo-button')));
    await tester.pump();

    expect(feedbackText(tester), 'Move undone. Choose a source cell.');
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

    expect(feedbackText(tester), 'Game restarted. Choose a source cell.');
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

  testWidgets('leaves fading afterimages for the affected cells',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

    final source = find.byKey(const Key('row-handle-left-0'));
    final target = find.byKey(const Key('row-handle-left-1'));
    final gesture = await tester.startGesture(tester.getCenter(source));
    await gesture.moveTo(tester.getCenter(target));
    await gesture.up();
    await tester.pump();

    for (final row in [0, 1]) {
      for (final column in [0, 1]) {
        expect(
          find.byKey(Key('swap-afterimage-1-$row-$column')),
          findsOneWidget,
        );
      }
    }

    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.byKey(const Key('swap-afterimage-1-0-0')), findsNothing);
  });

  testWidgets('allows another swap while a swap is animating',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

    final firstSource = find.byKey(const Key('row-handle-left-0'));
    final firstTarget = find.byKey(const Key('row-handle-left-1'));
    final firstGesture = await tester.startGesture(tester.getCenter(firstSource));
    await firstGesture.moveTo(tester.getCenter(firstTarget));
    await firstGesture.up();
    await tester.pump();

    final secondSource = find.byKey(const Key('column-handle-top-0'));
    final secondTarget = find.byKey(const Key('column-handle-top-1'));
    final secondGesture = await tester.startGesture(tester.getCenter(secondSource));
    await secondGesture.moveTo(tester.getCenter(secondTarget));
    await secondGesture.up();
    await tester.pump();

    expect(find.bySemanticsLabel('Cell 1, 1: 4'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1180));
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

  testWidgets('undo restores a row swap immediately',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

    await dragTo(
      tester,
      const Key('row-handle-left-0'),
      const Key('row-handle-left-1'),
    );

    await tester.tap(find.byKey(const Key('undo-button')));
    await tester.pump();

    expect(find.byKey(const Key('swap-source-highlight')), findsNothing);
    expect(find.byKey(const Key('swap-target-highlight')), findsNothing);
    expect(find.bySemanticsLabel('Cell 1, 1: 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Cell 2, 1: 3'), findsOneWidget);
  });

  testWidgets('undo restores a column swap immediately',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: BoardScreen()));

    await dragTo(
      tester,
      const Key('column-handle-top-0'),
      const Key('column-handle-top-1'),
    );

    await tester.tap(find.byKey(const Key('undo-button')));
    await tester.pump();

    expect(find.byKey(const Key('swap-source-highlight')), findsNothing);
    expect(find.byKey(const Key('swap-target-highlight')), findsNothing);
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

    expect(feedbackText(tester), 'Swap cancelled. Drag a row or column handle onto another one.');
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

  testWidgets('renders a Historical Date event and keeps framed cells playable',
      (WidgetTester tester) async {
    final target = Board([
      [0, 20, 7, 1969, 0],
      [0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0],
    ]);
    final game = HistoricalDateGame(
      session: GameSession(target),
      targetBoard: target,
      event: HistoricalEvent(
        title: 'Apollo 11 Moon landing',
        description: 'Apollo 11 astronauts first landed on the Moon.',
        date: DateTime.utc(1969, 7, 20),
      ),
      frame: const DateFrame(0, 1),
      format: const DateFrameFormat(
        order: [DateComponent.day, DateComponent.month, DateComponent.year],
        separator: '.',
      ),
      moveCount: 0,
    );
    await tester.pumpWidget(MaterialApp(home: BoardScreen(initialGame: game)));

    expect(find.byKey(const Key('historical-event-card')), findsOneWidget);
    expect(find.text('Apollo 11 Moon landing'), findsOneWidget);
    expect(find.byKey(const Key('historical-event-date')), findsOneWidget);
    expect(find.text('20.7.1969'), findsOneWidget);
    expect(find.byKey(const Key('historical-date-frame')), findsOneWidget);
    expect(find.byKey(const Key('historical-date-separator-1')), findsOneWidget);
    expect(feedbackText(tester), 'Choose a source cell. Rebuild the date inside the gold frame.');
    await tester.tap(find.byKey(const Key('cell-0-1')));
    await tester.tap(find.byKey(const Key('cell-0-2')));
    await tester.pump();
    expect(find.text('01 moves'), findsOneWidget);
  });

  testWidgets('tutorial advances only after its expected actions',
      (WidgetTester tester) async {
    var finished = false;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: BoardScreen(
            initialGame: tutorialDefinition.initialGame,
            tutorial: tutorialDefinition,
            onTutorialFinished: () async => finished = true,
          ),
        ),
      ),
    );

    expect(find.text('HOW TO PLAY'), findsOneWidget);
    expect(find.byKey(const Key('tutorial-objective')), findsOneWidget);
    expect(find.byKey(const Key('tutorial-progress')), findsOneWidget);
    expect(find.byKey(const Key('tutorial-guided-cell-0-0')), findsOneWidget);
    expect(find.byKey(const Key('tutorial-guided-cell-0-1')), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('cell-1-0')));
    await tester.tap(find.byKey(const Key('cell-1-0')));
    await tester.pump();
    expect(find.textContaining('source cell does not change'), findsWidgets);

    await tester.tap(find.byKey(const Key('cell-0-0')));
    await tester.pump();
    expect(find.byKey(const Key('tutorial-guided-cell-0-1')), findsOneWidget);
    await tester.tap(find.byKey(const Key('cell-0-1')));
    await tester.pump();
    expect(find.textContaining('swaps the whole columns'), findsWidgets);
    expect(find.byKey(const Key('tutorial-guided-handle-top-column-0')), findsOneWidget);

    await dragTutorialTo(
      tester,
      const Key('column-handle-top-0'),
      const Key('column-handle-top-1'),
    );
    expect(find.textContaining('source minus target'), findsWidgets);

    await tester.ensureVisible(find.byKey(const Key('cell-1-1')).first);
    await tester.tap(find.byKey(const Key('cell-1-1')).first);
    await tester.tap(find.byKey(const Key('cell-0-1')).first);
    await tester.pump();
    expect(find.byKey(const Key('finish-tutorial-button')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('finish-tutorial-button')));
    await tester.tap(find.byKey(const Key('finish-tutorial-button')));
    await tester.pump();
    expect(finished, isTrue);
  });

  testWidgets('tutorial can be started from the start screen',
      (WidgetTester tester) async {
    final progress = _FakeTutorialProgressStore(handled: true);
    await tester.pumpWidget(
      NumbersGameApp(
        progressStore: progress,
        gameStateStore: _FakeGameStateStore(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('how-to-play-button')), findsOneWidget);
    await tester.tap(find.byKey(const Key('how-to-play-button')));
    await tester.pump();
    expect(find.byKey(const Key('skip-tutorial-button')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('skip-tutorial-button')));
    await tester.tap(find.byKey(const Key('skip-tutorial-button')));
    await tester.pumpAndSettle();
    expect(progress.handled, isTrue);
    expect(find.byKey(const Key('how-to-play-button')), findsOneWidget);
  });

  testWidgets('first launch opens the start screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      NumbersGameApp(
        progressStore: _FakeTutorialProgressStore(handled: false),
        gameStateStore: _FakeGameStateStore(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('how-to-play-button')), findsOneWidget);
  });

  testWidgets('continues the saved game from the start screen', (WidgetTester tester) async {
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
          currentGame: SavedGame(settings: const OneNonZeroSettings(), game: savedGame),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('continue-game-button')), findsOneWidget);
    await tester.tap(find.byKey(const Key('continue-game-button')));
    await tester.pumpAndSettle();
    expect(find.text('Moves: 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Cell 1, 2: 3'), findsOneWidget);
  });

  testWidgets('new game retains settings and replaces the saved session',
      (WidgetTester tester) async {
    final store = _FakeGameStateStore(
      settings: const AppSettings(
        oneNonZeroSettings: OneNonZeroSettings(boardSize: 3, maxInitialValue: 30),
      ),
      currentGame: SavedGame(
        settings: const OneNonZeroSettings(boardSize: 3, maxInitialValue: 30),
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
    await tester.tap(find.byKey(const Key('continue-game-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('new-game-button')));
    await tester.pumpAndSettle();

    expect(store.clearCount, 1);
    expect(store.settings.oneNonZeroSettings.boardSize, 3);
    expect(store.currentGame!.game.moveCount, 0);
    expect(
      (store.currentGame!.settings as OneNonZeroSettings).maxInitialValue,
      30,
    );
    expect(find.byKey(const Key('cell-2-2')), findsOneWidget);
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
      currentGame: SavedGame(settings: const OneNonZeroSettings(), game: currentGame),
    );
    await tester.pumpWidget(
      NumbersGameApp(
        progressStore: _FakeTutorialProgressStore(handled: true),
        gameStateStore: store,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('continue-game-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('game-mode-one-non-zero')), findsOneWidget);

    await tester.tap(find.byKey(const Key('increase-board-size-button')));
    await tester.tap(find.byKey(const Key('increase-maximum-initial-value-button')));
    await tester.tap(find.byKey(const Key('save-settings-button')));
    await tester.pumpAndSettle();

    expect(store.settings.oneNonZeroSettings.boardSize, 5);
    expect(store.settings.oneNonZeroSettings.maxInitialValue, 30);
    expect(find.text('Moves: 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Cell 1, 2: 3'), findsOneWidget);

    await tester.tap(find.byKey(const Key('new-game-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cell-4-4')), findsOneWidget);
    expect(
      (store.currentGame!.settings as OneNonZeroSettings).boardSize,
      5,
    );
    expect(
      (store.currentGame!.settings as OneNonZeroSettings).maxInitialValue,
      30,
    );
  });

  testWidgets('settings keep the board size at two or more', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(
          settings: AppSettings(
            oneNonZeroSettings: OneNonZeroSettings(boardSize: 2),
          ),
        ),
      ),
    );

    final decreaseButton = tester.widget<IconButton>(
      find.byKey(const Key('decrease-board-size-button')),
    );
    await tester.pump();

    expect(decreaseButton.onPressed, isNull);
    expect(find.byKey(const Key('board-size-value')), findsOneWidget);
    expect(find.text('2 × 2'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const Key('decrease-maximum-initial-value-button')),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('settings select Historical Date mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SettingsScreen(settings: AppSettings())),
    );

    await tester.tap(find.byKey(const Key('game-mode-historical-date')));
    await tester.pump();

    expect(find.byKey(const Key('game-mode-historical-date')), findsOneWidget);
    expect(find.byKey(const Key('board-size-value')), findsNothing);
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
    this.settings = const AppSettings(),
    this.currentGame,
  });

  AppSettings settings;
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
  Future<AppSettings> loadSettings() async => settings;

  @override
  Future<void> saveCurrentGame(SavedGame game) async {
    currentGame = game;
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
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

Future<void> dragTutorialTo(
  WidgetTester tester,
  Key sourceKey,
  Key targetKey,
) async {
  final source = find.byKey(sourceKey);
  final target = find.byKey(targetKey);
  await tester.ensureVisible(source);
  await tester.ensureVisible(target);
  final gesture = await tester.startGesture(tester.getCenter(source));
  await gesture.moveTo(tester.getCenter(target));
  await gesture.up();
  await tester.pump();
}

OutlinedButton undoButton(WidgetTester tester) => tester.widget<OutlinedButton>(
      find.byKey(const Key('undo-button')),
    );
