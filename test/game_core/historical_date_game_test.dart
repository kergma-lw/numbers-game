import 'package:flutter_test/flutter_test.dart';
import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/game_session.dart';
import 'package:numbers_game/game_core/historical_date_game.dart';

void main() {
  test('wins only when the exact target board is restored', () {
    final target = Board([
      [0, 0, 0, 0, 0],
      [0, 20, 7, 1969, 0],
      [0, 0, 0, 0, 0],
    ]);
    final game = HistoricalDateGame(
      session: GameSession(target).applyArithmeticMove(
        source: const CellPosition(1, 1),
        target: const CellPosition(1, 2),
      ),
      targetBoard: target,
      event: HistoricalEvent(
        title: 'Apollo 11 Moon landing',
        description: 'Apollo 11 astronauts first landed on the Moon.',
        date: DateTime.utc(1969, 7, 20),
      ),
      frame: const DateFrame(1, 1),
      format: const DateFrameFormat(
        order: [DateComponent.day, DateComponent.month, DateComponent.year],
        separator: '.',
      ),
      moveCount: 1,
    );

    expect(game.isWon, isFalse);
    expect(game.undo().isWon, isTrue);
    expect(game.isLost, isFalse);
  });

  test('locale formats capture order and separator', () {
    expect(DateFrameFormat.forLocale('en_US').order,
        [DateComponent.month, DateComponent.day, DateComponent.year]);
    expect(DateFrameFormat.forLocale('ja_JP').order,
        [DateComponent.year, DateComponent.month, DateComponent.day]);
    expect(DateFrameFormat.forLocale('fr_FR').separator, '.');
  });

  test('formats the displayed target date from its captured frame format', () {
    final game = HistoricalDateGame(
      session: GameSession(Board([
        [4, 10, 1957],
      ])),
      targetBoard: Board([
        [4, 10, 1957],
      ]),
      event: HistoricalEvent(
        title: 'Sputnik 1 launch',
        description: 'Sputnik 1 was launched into orbit.',
        date: DateTime.utc(1957, 10, 4),
      ),
      frame: const DateFrame(0, 0),
      format: const DateFrameFormat(
        order: [DateComponent.month, DateComponent.day, DateComponent.year],
        separator: '/',
      ),
      moveCount: 0,
    );

    expect(game.formattedDate, '10/4/1957');
  });

  test('a subtraction-only scramble is solved by reversing its moves', () {
    final target = Board([
      [0, 4, 10, 1957],
      [0, 0, 0, 0],
    ]);
    const moves = [
      (source: CellPosition(1, 2), target: CellPosition(0, 1)),
      (source: CellPosition(1, 3), target: CellPosition(0, 2)),
      (source: CellPosition(1, 1), target: CellPosition(0, 0)),
    ];

    final scrambled = moves.fold(
      target,
      (board, move) => board.applyArithmeticMove(
        source: move.source,
        target: move.target,
      ),
    );
    final restored = moves.reversed.fold(
      scrambled,
      (board, move) => board.applyArithmeticMove(
        source: move.source,
        target: move.target,
      ),
    );

    expect(
      [
        for (var row = 0; row < target.rowCount; row++)
          for (var column = 0; column < target.columnCount; column++)
            restored.valueAt(CellPosition(row, column)),
      ],
      [
        for (var row = 0; row < target.rowCount; row++)
          for (var column = 0; column < target.columnCount; column++)
            target.valueAt(CellPosition(row, column)),
      ],
    );
  });
}
