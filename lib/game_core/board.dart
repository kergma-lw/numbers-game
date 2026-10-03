/// A zero-based position on a game board.
class CellPosition {
  const CellPosition(this.row, this.column);

  final int row;
  final int column;

  @override
  bool operator ==(Object other) =>
      other is CellPosition && row == other.row && column == other.column;

  @override
  int get hashCode => Object.hash(row, column);

  @override
  String toString() => 'CellPosition($row, $column)';
}

/// An immutable rectangular grid of integers used by the game.
///
/// A board must have at least one row and one column. All operations return a
/// new board, leaving this instance unchanged.
class Board {
  Board(List<List<int>> cells) : _cells = _validatedCopy(cells);

  final List<List<int>> _cells;

  int get rowCount => _cells.length;
  int get columnCount => _cells.first.length;

  /// Returns the value at [position].
  int valueAt(CellPosition position) {
    _validatePosition(position);
    return _cells[position.row][position.column];
  }

  /// Applies an arithmetic move from [source] to [target].
  ///
  /// The source remains unchanged. A target below or to the right of its source
  /// receives their sum; a target above or to the left receives
  /// `source - target`. For cells in different rows, their vertical relation
  /// determines the operation.
  Board applyArithmeticMove({
    required CellPosition source,
    required CellPosition target,
  }) {
    _validatePosition(source);
    _validatePosition(target);
    if (source == target) {
      throw ArgumentError.value(
        target,
        'target',
        'must differ from the source',
      );
    }

    final nextCells = _copyCells();
    final sourceValue = valueAt(source);
    final targetValue = valueAt(target);
    final adds = target.row > source.row ||
        (target.row == source.row && target.column > source.column);
    nextCells[target.row][target.column] =
        adds ? sourceValue + targetValue : sourceValue - targetValue;
    return Board(nextCells);
  }

  /// Returns a board with the two distinct rows at [first] and [second] swapped.
  Board swapRows(int first, int second) {
    _validateRow(first);
    _validateRow(second);
    _validateDistinctIndices(first, second, 'rows');

    final nextCells = _copyCells();
    final row = nextCells[first];
    nextCells[first] = nextCells[second];
    nextCells[second] = row;
    return Board(nextCells);
  }

  /// Returns a board with the two distinct columns at [first] and [second] swapped.
  Board swapColumns(int first, int second) {
    _validateColumn(first);
    _validateColumn(second);
    _validateDistinctIndices(first, second, 'columns');

    final nextCells = _copyCells();
    for (final row in nextCells) {
      final value = row[first];
      row[first] = row[second];
      row[second] = value;
    }
    return Board(nextCells);
  }

  List<List<int>> _copyCells() =>
      _cells.map((row) => List<int>.from(row)).toList(growable: false);

  static List<List<int>> _validatedCopy(List<List<int>> cells) {
    if (cells.isEmpty) {
      throw ArgumentError.value(cells, 'cells', 'must contain at least one row');
    }
    if (cells.first.isEmpty) {
      throw ArgumentError.value(cells, 'cells', 'must contain at least one column');
    }

    final columnCount = cells.first.length;
    if (cells.any((row) => row.length != columnCount)) {
      throw ArgumentError.value(cells, 'cells', 'must be rectangular');
    }
    return cells.map((row) => List<int>.unmodifiable(row)).toList(growable: false);
  }

  void _validatePosition(CellPosition position) {
    _validateRow(position.row);
    _validateColumn(position.column);
  }

  void _validateRow(int row) => _validateIndex(row, rowCount, 'row');

  void _validateColumn(int column) =>
      _validateIndex(column, columnCount, 'column');

  static void _validateIndex(int index, int count, String name) {
    if (index < 0 || index >= count) {
      throw RangeError.range(index, 0, count - 1, name);
    }
  }

  static void _validateDistinctIndices(int first, int second, String kind) {
    if (first == second) {
      throw ArgumentError.value(second, 'second', 'must select two distinct $kind');
    }
  }
}
