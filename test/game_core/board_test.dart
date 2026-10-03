import 'package:flutter_test/flutter_test.dart';
import 'package:numbers_game/game_core/board.dart';

void main() {
  group('Board construction', () {
    test('rejects empty and non-rectangular grids', () {
      expect(() => Board([]), throwsArgumentError);
      expect(() => Board([[]]), throwsArgumentError);
      expect(() => Board([
            [1],
            [2, 3],
          ]), throwsArgumentError);
    });

    test('allows one-dimensional boards and arbitrary integers', () {
      final board = Board([
        [0, -3, 1 << 200],
      ]);

      expect(board.rowCount, 1);
      expect(board.columnCount, 3);
      expect(board.valueAt(const CellPosition(0, 0)), 0);
      expect(board.valueAt(const CellPosition(0, 1)), -3);
      expect(board.valueAt(const CellPosition(0, 2)), 1 << 200);
    });
  });

  group('arithmetic moves', () {
    test('adds when the target is to the right', () {
      final result = Board([
        [2, 3],
      ]).applyArithmeticMove(
        source: const CellPosition(0, 0),
        target: const CellPosition(0, 1),
      );

      expect(values(result), [2, 5]);
    });

    test('subtracts when the target is to the left', () {
      final result = Board([
        [2, 3],
      ]).applyArithmeticMove(
        source: const CellPosition(0, 1),
        target: const CellPosition(0, 0),
      );

      expect(values(result), [1, 3]);
    });

    test('adds below and subtracts above', () {
      final below = Board([
        [2],
        [3],
      ]).applyArithmeticMove(
        source: const CellPosition(0, 0),
        target: const CellPosition(1, 0),
      );
      final above = Board([
        [2],
        [3],
      ]).applyArithmeticMove(
        source: const CellPosition(1, 0),
        target: const CellPosition(0, 0),
      );

      expect(values(below), [2, 5]);
      expect(values(above), [1, 3]);
    });

    test('uses vertical direction for cells in different rows', () {
      final lowerTarget = Board([
        [0, 2],
        [3, 0],
      ]).applyArithmeticMove(
        source: const CellPosition(0, 1),
        target: const CellPosition(1, 0),
      );
      final upperTarget = Board([
        [0, 2],
        [3, 0],
      ]).applyArithmeticMove(
        source: const CellPosition(1, 0),
        target: const CellPosition(0, 1),
      );

      expect(values(lowerTarget), [0, 2, 5, 0]);
      expect(values(upperTarget), [0, 1, 3, 0]);
    });

    test('supports zero and negative values without changing the source', () {
      final original = Board([
        [-4, 0],
      ]);
      final result = original.applyArithmeticMove(
        source: const CellPosition(0, 0),
        target: const CellPosition(0, 1),
      );

      expect(values(result), [-4, -4]);
      expect(values(original), [-4, 0]);
    });

    test('rejects same-cell and out-of-bounds moves', () {
      final board = Board([
        [1, 2],
      ]);

      expect(
        () => board.applyArithmeticMove(
          source: const CellPosition(0, 0),
          target: const CellPosition(0, 0),
        ),
        throwsArgumentError,
      );
      expect(
        () => board.applyArithmeticMove(
          source: const CellPosition(-1, 0),
          target: const CellPosition(0, 1),
        ),
        throwsRangeError,
      );
    });
  });

  group('swap moves', () {
    test('swaps rows and columns without changing the original board', () {
      final original = Board([
        [1, 2],
        [3, 4],
      ]);
      final rowsSwapped = original.swapRows(0, 1);
      final columnsSwapped = original.swapColumns(0, 1);

      expect(values(rowsSwapped), [3, 4, 1, 2]);
      expect(values(columnsSwapped), [2, 1, 4, 3]);
      expect(values(original), [1, 2, 3, 4]);
    });

    test('rejects equal and out-of-bounds swap indices', () {
      final board = Board([
        [1, 2],
        [3, 4],
      ]);

      expect(() => board.swapRows(0, 0), throwsArgumentError);
      expect(() => board.swapColumns(1, 1), throwsArgumentError);
      expect(() => board.swapRows(0, 2), throwsRangeError);
      expect(() => board.swapColumns(-1, 1), throwsRangeError);
    });
  });

  test('preserves the greatest common divisor of all board values', () {
    final initial = Board([
      [6, 10],
      [-14, 0],
    ]);
    final result = initial
        .applyArithmeticMove(
          source: const CellPosition(0, 1),
          target: const CellPosition(1, 0),
        )
        .swapRows(0, 1)
        .swapColumns(0, 1);

    expect(greatestCommonDivisor(values(initial)), 2);
    expect(greatestCommonDivisor(values(result)), 2);
  });
}

List<int> values(Board board) => [
      for (var row = 0; row < board.rowCount; row++)
        for (var column = 0; column < board.columnCount; column++)
          board.valueAt(CellPosition(row, column)),
    ];

int greatestCommonDivisor(Iterable<int> values) => values
    .map((value) => value.abs())
    .reduce((result, value) {
      while (value != 0) {
        final remainder = result % value;
        result = value;
        value = remainder;
      }
      return result;
    });
