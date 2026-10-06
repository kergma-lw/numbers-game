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
      SavedGame(settings: const GameSettings(), game: original).toJson(),
    );

    expect(restored.settings.mode, GameMode.oneNonZero);
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

    expect(await store.loadSettings(), isA<GameSettings>());
    expect(await store.loadCurrentGame(), isNull);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.containsKey('game_settings'), isFalse);
    expect(preferences.containsKey('current_game'), isFalse);
  });

  test('persists settings for a later store instance', () async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesGameStateStore().saveSettings(
      const GameSettings(boardSize: 3),
    );

    final restoredSettings = await SharedPreferencesGameStateStore().loadSettings();

    expect(restoredSettings.mode, GameMode.oneNonZero);
    expect(restoredSettings.boardSize, 3);
  });
}

List<int> values(Board board) => [
      for (var row = 0; row < board.rowCount; row++)
        for (var column = 0; column < board.columnCount; column++)
          board.valueAt(CellPosition(row, column)),
    ];
