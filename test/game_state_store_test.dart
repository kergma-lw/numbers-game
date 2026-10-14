import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:numbers_game/game_core/board.dart';
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
}

List<int> values(Board board) => [
      for (var row = 0; row < board.rowCount; row++)
        for (var column = 0; column < board.columnCount; column++)
          board.valueAt(CellPosition(row, column)),
    ];
