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

class GameFeedback {
  const GameFeedback(this.primary, [this.context]);

  final String primary;
  final String? context;
}

class GameStatusPanel extends StatelessWidget {
  const GameStatusPanel({
    super.key,
    required this.moveCount,
    required this.feedback,
    required this.isWon,
    required this.isLost,
    this.showMoveCount = true,
  });

  final int moveCount;
  final GameFeedback feedback;
  final bool isWon;
  final bool isLost;
  final bool showMoveCount;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          if (showMoveCount) Text('Moves: $moveCount', key: const Key('move-count')),
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
            label: [feedback.primary, feedback.context].whereType<String>().join(' '),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: feedback.primary,
                    style: const TextStyle(
                      color: Color(0xfff4eddf),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (feedback.context != null) TextSpan(text: ' ${feedback.context}'),
                ],
              ),
              key: const Key('feedback'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xffbcb6aa), fontSize: 14),
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
  Widget build(BuildContext context) => Container(
        key: const Key('historical-event-card'),
        margin: const EdgeInsets.only(top: 20, bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.fromRGBO(86, 56, 83, .90), Color.fromRGBO(52, 43, 74, .92)],
          ),
          border: Border.all(color: const Color.fromRGBO(236, 118, 93, .38)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(21),
            bottomRight: Radius.circular(14),
          ),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 20)],
        ),
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RESTORE THE DATE',
                style: TextStyle(
                  color: Color(0xfff3a486),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                game.formattedDate,
                key: const Key('historical-event-date'),
                style: const TextStyle(
                  color: Color(0xffffe6ae),
                  fontFamily: 'serif',
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                game.event.title,
                style: const TextStyle(
                  color: Color(0xfff4eddf),
                  fontFamily: 'serif',
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(game.event.description, style: const TextStyle(color: Color(0xffbcb6aa), fontSize: 12)),
            ],
          ),
        ),
      );
}
