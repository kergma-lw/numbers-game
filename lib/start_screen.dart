import 'package:flutter/material.dart';
import 'package:numbers_game/game_state_store.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({
    super.key,
    required this.savedGame,
    required this.showTutorialCallToAction,
    required this.onContinue,
    required this.onStartMode,
    required this.onTutorial,
    required this.onSettings,
  });

  final SavedGame? savedGame;
  final bool showTutorialCallToAction;
  final VoidCallback onContinue;
  final ValueChanged<GameMode> onStartMode;
  final VoidCallback onTutorial;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xfff4eddf);
    const muted = Color(0xffbcb6aa);
    return Scaffold(
      body: Container(
        color: const Color(0xff131a2a),
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  key: Key('start-background-center'),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(-.04, .04),
                      radius: 1.32,
                      colors: [Color(0xff273356), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  key: Key('start-background-coral'),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(.64, .52),
                      radius: .88,
                      colors: [Color(0x2eec765d), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  key: Key('start-background-teal'),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(-.66, -.64),
                      radius: .94,
                      colors: [Color(0x3374d7c4), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              top: 60,
              left: -12,
              child: IgnorePointer(
                child: Text('1 − 1',
                    style: TextStyle(
                        color: Color(0x12f4eddf), fontSize: 112, fontWeight: FontWeight.bold)),
              ),
            ),
            const Positioned(
              right: -12,
              bottom: 60,
              child: IgnorePointer(
                child: Text('4 + 2',
                    style: TextStyle(
                        color: Color(0x12f4eddf), fontSize: 112, fontWeight: FontWeight.bold)),
              ),
            ),
            const Positioned(
              left: 46,
              top: 390,
              child: IgnorePointer(
                child: Text('( 0 ) = 1',
                    style: TextStyle(
                        color: Color(0x3074d7c4),
                        fontFamily: 'monospace',
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const Positioned(
              right: 34,
              top: 142,
              child: IgnorePointer(
                child: Text('∞ − 1',
                    style: TextStyle(
                        color: Color(0x30ec765d),
                        fontFamily: 'monospace',
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            Positioned(
              right: -34,
              top: 330,
              child: IgnorePointer(
                child: Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x3374d7c4)),
                    gradient: const RadialGradient(
                      center: Alignment(-.35, -.45),
                      colors: [Color(0x4574d7c4), Color(0x18131a2a), Colors.transparent],
                    ),
                    boxShadow: const [BoxShadow(color: Color(0x2274d7c4), blurRadius: 32)],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 592),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('DREAM ARITHMETIC PUZZLE',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xff74d7c4), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2)),
                        const SizedBox(height: 10),
                        const Text('NUMBERS\nGAME',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: ink, fontFamily: 'serif', fontSize: 54, height: .82, letterSpacing: 3)),
                        const SizedBox(height: 26),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xdd1c263a),
                            border: Border.all(color: const Color(0x30ede0bf)),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Stack(
                            children: [
                              const Positioned(
                                top: 10,
                                right: 12,
                                child: IgnorePointer(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.fromBorderSide(BorderSide(color: Color(0x38f4b94c))),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (showTutorialCallToAction) ...[
                                  FilledButton(
                                    key: const Key('start-tutorial-call-to-action'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xffb9c4de),
                                      foregroundColor: const Color(0xff30384d),
                                      padding: const EdgeInsets.all(16),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(18)),
                                      ),
                                    ),
                                    onPressed: onTutorial,
                                    child: const Row(
                                      children: [
                                        Icon(Icons.auto_stories_outlined),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Take the tutorial', style: TextStyle(fontWeight: FontWeight.w800)),
                                              Text('Learn moves and transformations', style: TextStyle(fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                if (savedGame != null) ...[
                                  FilledButton(
                                    key: const Key('continue-game-button'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xfff4be55),
                                      foregroundColor: const Color(0xff252039),
                                      padding: const EdgeInsets.all(16),
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
                                    ),
                                    onPressed: onContinue,
                                    child: Row(children: [
                                      const Text('−1', style: TextStyle(fontFamily: 'monospace', fontSize: 22)),
                                      const SizedBox(width: 16),
                                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        const Text('Continue', style: TextStyle(fontWeight: FontWeight.w800)),
                                        Text('${savedGame!.mode == GameMode.oneNonZero ? 'One non-zero' : 'Historical Date'} · ${savedGame!.game.moveCount} moves', style: const TextStyle(fontSize: 12)),
                                      ])),
                                      const Icon(Icons.arrow_forward),
                                    ]),
                                  ),
                                  const SizedBox(height: 22),
                                ],
                                const Text('CHOOSE A NEW PUZZLE', style: TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                const SizedBox(height: 10),
                                Row(children: [
                                  Expanded(child: _ModeCard(key: const Key('start-one-non-zero-button'), icon: '1 → 0', title: 'One non-zero', detail: 'Leave one number on the board', color: const Color(0xff74d7c4), onPressed: () => onStartMode(GameMode.oneNonZero))),
                                  const SizedBox(width: 10),
                                  Expanded(child: _ModeCard(key: const Key('start-historical-date-button'), icon: '12·04·61', title: 'Historical Date', detail: 'Rebuild a date from an event', color: const Color(0xffec765d), onPressed: () => onStartMode(GameMode.historicalDate))),
                                ]),
                              ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          TextButton(key: const Key('how-to-play-button'), onPressed: onTutorial, child: const Text('How to play', style: TextStyle(color: muted))),
                          TextButton(key: const Key('start-settings-button'), onPressed: onSettings, child: const Text('Settings', style: TextStyle(color: muted))),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({super.key, required this.icon, required this.title, required this.detail, required this.color, required this.onPressed});
  final String icon;
  final String title;
  final String detail;
  final Color color;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(14),
          minimumSize: const Size(0, 140),
          alignment: Alignment.centerLeft,
          backgroundColor: color.withValues(alpha: .12),
          side: BorderSide(color: color.withValues(alpha: .35)),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(icon, style: TextStyle(color: color, fontFamily: 'monospace', fontSize: 18)),
          const SizedBox(height: 42),
          Text(title, style: const TextStyle(color: Color(0xfff4eddf), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(detail, style: const TextStyle(color: Color(0xffbcb6aa), fontSize: 11)),
        ]),
      );
}
