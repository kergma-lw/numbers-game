import 'package:flutter_test/flutter_test.dart';
import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/tutorial.dart';

void main() {
  test('the tutorial sequence wins the fixed board', () {
    var game = tutorialDefinition.initialGame;

    for (final step in tutorialDefinition.steps) {
      switch (step.action) {
        case TutorialAction.arithmeticMove:
          game = game.applyArithmeticMove(source: step.source!, target: step.target!);
        case TutorialAction.swapColumns:
          game = game.swapColumns(step.firstLine!, step.secondLine!);
      }
    }

    expect(game.isWon, isTrue);
    expect(game.currentBoard.valueAt(const CellPosition(1, 1)), 1);
  });
}
