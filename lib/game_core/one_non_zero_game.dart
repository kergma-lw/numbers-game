import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/game_session.dart';
import 'package:numbers_game/game_core/playable_game.dart';

/// A game mode won by leaving exactly one non-zero cell on the board.
class OneNonZeroGame implements PlayableGame {
  OneNonZeroGame(Board initialBoard)
      : _session = GameSession(initialBoard),
        moveCount = 0;

  const OneNonZeroGame._(this._session, this.moveCount);

  /// Restores a game with its undo history and move count intact.
  factory OneNonZeroGame.restore({
    required GameSession session,
    required int moveCount,
  }) =>
      OneNonZeroGame._(session, moveCount);

  final GameSession _session;
  @override
  final int moveCount;

  @override
  Board get currentBoard => _session.currentBoard;
  @override
  GameSession get session => _session;
  @override
  bool get canUndo => _session.canUndo;

  /// Whether the current board has exactly one positive cell.
  @override
  bool get isWon {
    final value = _singleNonZeroValue(currentBoard);
    return value != null && value > 0;
  }

  /// Whether the current board has exactly one negative cell.
  @override
  bool get isLost {
    final value = _singleNonZeroValue(currentBoard);
    return value != null && value < 0;
  }

  /// Applies an arithmetic move and increments this mode's move count.
  @override
  OneNonZeroGame applyArithmeticMove({
    required CellPosition source,
    required CellPosition target,
  }) =>
      OneNonZeroGame._(
        _session.applyArithmeticMove(source: source, target: target),
        moveCount + 1,
      );

  /// Swaps two rows and increments this mode's move count.
  @override
  OneNonZeroGame swapRows(int first, int second) =>
      OneNonZeroGame._(_session.swapRows(first, second), moveCount + 1);

  /// Swaps two columns and increments this mode's move count.
  @override
  OneNonZeroGame swapColumns(int first, int second) =>
      OneNonZeroGame._(_session.swapColumns(first, second), moveCount + 1);

  /// Undoes a move and restores its previous move count.
  @override
  OneNonZeroGame undo() => canUndo
      ? OneNonZeroGame._(_session.undo(), moveCount - 1)
      : this;

  /// Restarts this mode at its initial board with zero moves.
  @override
  OneNonZeroGame restart() => OneNonZeroGame._(_session.restart(), 0);
}

int? _singleNonZeroValue(Board board) {
  int? nonZeroValue;
  for (var row = 0; row < board.rowCount; row++) {
    for (var column = 0; column < board.columnCount; column++) {
      final value = board.valueAt(CellPosition(row, column));
      if (value != 0) {
        if (nonZeroValue != null) {
          return null;
        }
        nonZeroValue = value;
      }
    }
  }
  return nonZeroValue;
}
