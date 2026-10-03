import 'package:flutter_test/flutter_test.dart';
import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/game_session.dart';

void main() {
  final initialBoard = Board([
    [1, 2],
    [3, 4],
  ]);

  test('records and undoes arithmetic moves', () {
    final moved = GameSession(initialBoard).applyArithmeticMove(
      source: const CellPosition(0, 0),
      target: const CellPosition(0, 1),
    );

    expect(values(moved.currentBoard), [1, 3, 3, 4]);
    expect(moved.canUndo, isTrue);
    expect(values(moved.undo().currentBoard), [1, 2, 3, 4]);
    expect(moved.undo().canUndo, isFalse);
  });

  test('records row and column swaps independently', () {
    final moved = GameSession(initialBoard).swapRows(0, 1).swapColumns(0, 1);

    expect(values(moved.currentBoard), [4, 3, 2, 1]);
    expect(values(moved.undo().currentBoard), [3, 4, 1, 2]);
    expect(values(moved.undo().undo().currentBoard), [1, 2, 3, 4]);
  });

  test('undo with empty history leaves the session unchanged', () {
    final session = GameSession(initialBoard);

    expect(identical(session.undo(), session), isTrue);
  });

  test('restart restores the initial board and clears history', () {
    final restarted = GameSession(initialBoard)
        .swapRows(0, 1)
        .applyArithmeticMove(
          source: const CellPosition(0, 0),
          target: const CellPosition(0, 1),
        )
        .restart();

    expect(values(restarted.currentBoard), [1, 2, 3, 4]);
    expect(restarted.canUndo, isFalse);
  });
}

List<int> values(Board board) => [
      for (var row = 0; row < board.rowCount; row++)
        for (var column = 0; column < board.columnCount; column++)
          board.valueAt(CellPosition(row, column)),
    ];
