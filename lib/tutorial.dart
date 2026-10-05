import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/one_non_zero_game.dart';

enum TutorialAction { arithmeticMove, swapColumns }

class TutorialStep {
  const TutorialStep({
    required this.instruction,
    required this.action,
    this.source,
    this.target,
    this.firstLine,
    this.secondLine,
  });

  final String instruction;
  final TutorialAction action;
  final CellPosition? source;
  final CellPosition? target;
  final int? firstLine;
  final int? secondLine;

  bool matchesArithmetic(CellPosition source, CellPosition target) =>
      action == TutorialAction.arithmeticMove &&
      this.source == source &&
      this.target == target;

  bool matchesColumnSwap(int first, int second) =>
      action == TutorialAction.swapColumns &&
      ((firstLine == first && secondLine == second) ||
          (firstLine == second && secondLine == first));
}

class TutorialDefinition {
  const TutorialDefinition({required this.initialGame, required this.steps});

  final OneNonZeroGame initialGame;
  final List<TutorialStep> steps;
}

final tutorialDefinition = TutorialDefinition(
  initialGame: OneNonZeroGame(Board([
    [1, -1],
    [1, 0],
  ])),
  steps: const [
    TutorialStep(
      instruction: 'The number in the source cell does not change. When the target is to its right, add the two numbers in the target cell. Select 1, then -1 to make 0.',
      action: TutorialAction.arithmeticMove,
      source: CellPosition(0, 0),
      target: CellPosition(0, 1),
    ),
    TutorialStep(
      instruction: 'Dragging one column handle onto another swaps the whole columns. The numbers keep their values; only their positions change. Drag the indicated top handle to the other one.',
      action: TutorialAction.swapColumns,
      firstLine: 0,
      secondLine: 1,
    ),
    TutorialStep(
      instruction: 'When the target is above the source, replace its number with source minus target. The source number does not change. Select the lower-right 1, then the upper-right 1 to make 0.',
      action: TutorialAction.arithmeticMove,
      source: CellPosition(1, 1),
      target: CellPosition(0, 1),
    ),
  ],
);
