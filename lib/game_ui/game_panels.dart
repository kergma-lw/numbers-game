import 'package:flutter/material.dart';
import 'package:numbers_game/game_core/historical_date_game.dart';

class GameActionControls extends StatelessWidget {
  const GameActionControls({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: children,
      );
}

class GameStatusPanel extends StatelessWidget {
  const GameStatusPanel({
    super.key,
    required this.moveCount,
    required this.feedback,
    required this.isWon,
    required this.isLost,
  });

  final int moveCount;
  final String feedback;
  final bool isWon;
  final bool isLost;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text('Moves: $moveCount', key: const Key('move-count')),
          if (isWon)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'You won!',
                key: Key('victory-message'),
                textAlign: TextAlign.center,
              ),
            ),
          if (isLost)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'You lost!',
                key: Key('loss-message'),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 24),
          Semantics(
            liveRegion: true,
            child: Text(
              feedback,
              key: const Key('feedback'),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
}

class HistoricalEventPanel extends StatelessWidget {
  const HistoricalEventPanel({
    super.key,
    required this.game,
  });

  final HistoricalDateGame game;

  @override
  Widget build(BuildContext context) => Card(
        key: const Key('historical-event-card'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(game.event.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                game.formattedDate,
                key: const Key('historical-event-date'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(game.event.description),
            ],
          ),
        ),
      );
}
