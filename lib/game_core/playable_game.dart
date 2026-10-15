import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/game_session.dart';

/// The operations and state shared by every playable game mode.
abstract interface class PlayableGame {
  GameSession get session;
  Board get currentBoard;
  int get moveCount;
  bool get canUndo;
  bool get isWon;
  bool get isLost;

  PlayableGame applyArithmeticMove({
    required CellPosition source,
    required CellPosition target,
  });
  PlayableGame swapRows(int first, int second);
  PlayableGame swapColumns(int first, int second);
  PlayableGame undo();
  PlayableGame restart();
}
