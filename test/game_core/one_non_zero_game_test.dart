import 'package:flutter_test/flutter_test.dart';
import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/one_non_zero_game.dart';

void main() {
  test('treats a single positive cell as a win', () {
    final game = OneNonZeroGame(Board([
      [0, 0],
      [0, 7],
    ]));

    expect(game.isWon, isTrue);
    expect(game.isLost, isFalse);
  });

  test('treats a single negative cell as a loss', () {
    final game = OneNonZeroGame(Board([
      [0, 0],
      [0, -7],
    ]));

    expect(game.isWon, isFalse);
    expect(game.isLost, isTrue);
  });

  test('does not finish with zero or multiple non-zero cells', () {
    final zeroGame = OneNonZeroGame(Board([
      [0, 0],
      [0, 0],
    ]));
    final multipleValuesGame = OneNonZeroGame(Board([
      [1, 0],
      [0, -2],
    ]));

    expect(zeroGame.isWon || zeroGame.isLost, isFalse);
    expect(multipleValuesGame.isWon || multipleValuesGame.isLost, isFalse);
  });

  test('counts arithmetic moves and swaps', () {
    final game = OneNonZeroGame(Board([
      [1, 2],
      [3, 4],
    ]))
        .applyArithmeticMove(
          source: const CellPosition(0, 0),
          target: const CellPosition(0, 1),
        )
        .swapRows(0, 1)
        .swapColumns(0, 1);

    expect(game.moveCount, 3);
  });

  test('undo restores the previous move count', () {
    final game = OneNonZeroGame(Board([
      [1, 2],
    ]))
        .applyArithmeticMove(
          source: const CellPosition(0, 0),
          target: const CellPosition(0, 1),
        )
        .undo();

    expect(game.moveCount, 0);
    expect(game.currentBoard.valueAt(const CellPosition(0, 1)), 2);
  });

  test('restart clears move count and restores the starting board', () {
    final game = OneNonZeroGame(Board([
      [1, 2],
    ]))
        .applyArithmeticMove(
          source: const CellPosition(0, 0),
          target: const CellPosition(0, 1),
        )
        .restart();

    expect(game.moveCount, 0);
    expect(game.currentBoard.valueAt(const CellPosition(0, 1)), 2);
    expect(game.canUndo, isFalse);
  });
}
