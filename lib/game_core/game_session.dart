import 'package:numbers_game/game_core/board.dart';

/// An immutable game session with an initial board and undo history.
class GameSession {
  GameSession(Board initialBoard)
      : _initialBoard = initialBoard,
        currentBoard = initialBoard,
        _history = const [];

  const GameSession._(this._initialBoard, this.currentBoard, this._history);

  /// Restores a session previously saved by the application.
  factory GameSession.restore({
    required Board initialBoard,
    required Board currentBoard,
    required List<Board> history,
  }) =>
      GameSession._(initialBoard, currentBoard, List<Board>.unmodifiable(history));

  final Board _initialBoard;
  final Board currentBoard;
  final List<Board> _history;

  Board get initialBoard => _initialBoard;
  List<Board> get history => _history;

  /// Whether an earlier board state can be restored.
  bool get canUndo => _history.isNotEmpty;

  /// Applies an arithmetic move and saves the current board for undo.
  GameSession applyArithmeticMove({
    required CellPosition source,
    required CellPosition target,
  }) =>
      _withMove(
        currentBoard.applyArithmeticMove(source: source, target: target),
      );

  /// Swaps two rows and saves the current board for undo.
  GameSession swapRows(int first, int second) =>
      _withMove(currentBoard.swapRows(first, second));

  /// Swaps two columns and saves the current board for undo.
  GameSession swapColumns(int first, int second) =>
      _withMove(currentBoard.swapColumns(first, second));

  /// Restores the board before the most recent successful move.
  ///
  /// Calling this when no history exists leaves the session unchanged.
  GameSession undo() {
    if (!canUndo) {
      return this;
    }
    return GameSession._(
      _initialBoard,
      _history.last,
      List<Board>.unmodifiable(_history.sublist(0, _history.length - 1)),
    );
  }

  /// Restores the initial board and clears all undo history.
  GameSession restart() => GameSession._(_initialBoard, _initialBoard, const []);

  GameSession _withMove(Board nextBoard) => GameSession._(
        _initialBoard,
        nextBoard,
        List<Board>.unmodifiable([..._history, currentBoard]),
      );
}
