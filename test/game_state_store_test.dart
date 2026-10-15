import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/game_session.dart';
import 'package:numbers_game/game_core/historical_date_game.dart';
import 'package:numbers_game/game_core/one_non_zero_game.dart';
import 'package:numbers_game/game_state_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('round-trips a game with its undo history', () {
    final original = OneNonZeroGame(Board([
      [1, 2],
      [3, 4],
    ]))
        .applyArithmeticMove(
          source: const CellPosition(0, 0),
          target: const CellPosition(0, 1),
        )
        .swapRows(0, 1);

    final restored = SavedGame.fromJson(
      SavedGame(settings: const OneNonZeroSettings(), game: original).toJson(),
    );

    expect(restored.mode, GameMode.oneNonZero);
    expect((restored.settings as OneNonZeroSettings).maxInitialValue, 10);
    expect(restored.game.moveCount, 2);
    expect(values(restored.game.currentBoard), [3, 4, 1, 3]);
    expect(values(restored.game.undo().currentBoard), [1, 3, 3, 4]);
    expect(restored.game.undo().undo().canUndo, isFalse);
  });

  test('uses defaults and discards an unsupported saved game', () async {
    SharedPreferences.setMockInitialValues({
      'current_game': '{"version":999}',
      'game_settings': 'not json',
    });
    final store = SharedPreferencesGameStateStore();

    expect(await store.loadSettings(), isA<AppSettings>());
    expect(await store.loadCurrentGame(), isNull);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.containsKey('game_settings'), isFalse);
    expect(preferences.containsKey('current_game'), isFalse);
  });

  test('persists settings for a later store instance', () async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesGameStateStore().saveSettings(
      const AppSettings(
        oneNonZeroSettings: OneNonZeroSettings(boardSize: 3, maxInitialValue: 30),
      ),
    );

    final restoredSettings = await SharedPreferencesGameStateStore().loadSettings();

    expect(restoredSettings.selectedMode, GameMode.oneNonZero);
    expect(restoredSettings.oneNonZeroSettings.boardSize, 3);
    expect(restoredSettings.oneNonZeroSettings.maxInitialValue, 30);
  });

  test('round-trips a Historical Date game and its level metadata', () {
    final target = Board([
      [0, 20, 7, 1969, 0],
      [0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0],
    ]);
    final original = HistoricalDateGame(
      session: GameSession(target).applyArithmeticMove(
        source: const CellPosition(0, 1),
        target: const CellPosition(0, 2),
      ),
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
      moveCount: 1,
    );

    final restored = SavedGame.fromJson(
      SavedGame(
        mode: GameMode.historicalDate,
        settings: const HistoricalDateSettings(),
        game: original,
      ).toJson(),
    );

    final game = restored.game as HistoricalDateGame;
    expect(restored.mode, GameMode.historicalDate);
    expect(game.event.date, DateTime.utc(1969, 7, 20));
    expect(game.frame.column, 1);
    expect(game.format.separator, '.');
    expect(values(game.targetBoard), values(target));
    expect(game.moveCount, 1);
  });

  test('loads version two One Non-Zero saves', () {
    final restored = SavedGame.fromJson({
      'version': 2,
      'mode': 'oneNonZero',
      'settings': {'boardSize': 2, 'maxInitialValue': 10},
      'game': {
        'initialBoard': {
          'cells': [
            [1, 2],
            [3, 4],
          ],
        },
        'currentBoard': {
          'cells': [
            [1, 2],
            [3, 4],
          ],
        },
        'history': [],
        'moveCount': 0,
      },
    });

    expect(restored.game, isA<OneNonZeroGame>());
  });

  test('generates a board within the configured range', () {
    final game = newOneNonZeroGame(
      const OneNonZeroSettings(boardSize: 3, maxInitialValue: 5),
      random: Random(1),
    );

    expect(game.currentBoard.rowCount, 3);
    expect(game.currentBoard.columnCount, 3);
    for (final value in values(game.currentBoard)) {
      expect(value, inInclusiveRange(1, 5));
    }
  });

  test('generates a rectangular Historical Date board with a locale-specific target', () {
    final game = newHistoricalDateGame(random: Random(1), locale: 'en_US');

    expect(game.currentBoard.rowCount, 3);
    expect(game.currentBoard.columnCount, 5);
    expect(game.targetBoard.rowCount, 3);
    expect(game.format.order, [DateComponent.month, DateComponent.day, DateComponent.year]);
    expect(game.format.separator, '/');
    for (var row = 0; row < game.targetBoard.rowCount; row++) {
      for (var column = 0; column < game.targetBoard.columnCount; column++) {
        final insideFrame = row == game.frame.row &&
            column >= game.frame.column &&
            column < game.frame.column + 3;
        if (!insideFrame) {
          expect(game.targetBoard.valueAt(CellPosition(row, column)), 0);
        }
      }
    }
    expect(values(game.currentBoard), isNot(values(game.targetBoard)));
    final targetValues = {
      game.event.date.day,
      game.event.date.month,
      game.event.date.year,
    };
    final counts = <int, int>{};
    final startValues = values(game.currentBoard);
    for (final value in startValues) {
      counts[value] = (counts[value] ?? 0) + 1;
    }
    expect(
      targetValues.every((targetValue) =>
          startValues.any((value) => value.abs() == targetValue)),
      isFalse,
    );
    expect(counts.values.every((count) => count <= 2), isTrue);
  });
}

List<int> values(Board board) => [
      for (var row = 0; row < board.rowCount; row++)
        for (var column = 0; column < board.columnCount; column++)
          board.valueAt(CellPosition(row, column)),
    ];
