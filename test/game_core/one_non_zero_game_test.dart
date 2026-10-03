import 'package:flutter_test/flutter_test.dart';
import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/one_non_zero_game.dart';

void main() {
  test('detects boards with exactly one non-zero cell', () {
    expect(hasOneNonZeroCell(Board([
      [0, 0],
      [0, 0],
    ])), isFalse);
    expect(hasOneNonZeroCell(Board([
      [0, 0],
      [0, -7],
    ])), isTrue);
    expect(hasOneNonZeroCell(Board([
      [1, 0],
      [0, 2],
    ])), isFalse);
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
