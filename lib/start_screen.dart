import 'dart:math';

import 'package:flutter/material.dart';
import 'package:numbers_game/game_state_store.dart';
import 'package:numbers_game/game_ui/ambient_formula.dart';

class StartScreen extends StatefulWidget {
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
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  late final AmbientFormulaPair _ambientFormulas;

  @override
  void initState() {
    super.initState();
    _ambientFormulas = AmbientFormulaPair.random(Random());
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xfff4eddf);
    const muted = Color(0xffbcb6aa);
    final screenSize = MediaQuery.sizeOf(context);
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
            Positioned(
              top: 64,
              left: -8,
              child: IgnorePointer(
                child: _BackgroundNumber(
                  key: Key('start-background-number-top'),
                  value: _ambientFormulas.top.display,
                ),
              ),
            ),
            Positioned(
              right: 64,
              bottom: 32,
              child: IgnorePointer(
                child: _BackgroundNumber(
                  key: Key('start-background-number-bottom'),
                  value: _ambientFormulas.bottom.display,
                  bottom: true,
                ),
              ),
            ),
            Positioned(
              left: screenSize.width * .09,
              top: screenSize.height * .70,
              child: IgnorePointer(
                child: _BackgroundEquation(
                  key: const Key('start-background-equation-left'),
                  value: '( 0 ) = 1',
                  color: const Color(0x3074d7c4),
                  rotation: -.314,
                ),
              ),
            ),
            Positioned(
              right: screenSize.width * .08,
              top: screenSize.height * .15,
              child: IgnorePointer(
                child: _BackgroundEquation(
                  key: const Key('start-background-equation-right'),
                  value: '∞ − 1',
                  color: const Color(0x33ec765d),
                  rotation: .227,
                ),
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
                                if (widget.showTutorialCallToAction) ...[
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
                                    onPressed: widget.onTutorial,
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
                                if (widget.savedGame != null) ...[
                                  FilledButton(
                                    key: const Key('continue-game-button'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xfff4be55),
                                      foregroundColor: const Color(0xff252039),
                                      padding: const EdgeInsets.all(16),
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
                                    ),
                                    onPressed: widget.onContinue,
                                    child: Row(children: [
                                      const Text('−1', style: TextStyle(fontFamily: 'monospace', fontSize: 22)),
                                      const SizedBox(width: 16),
                                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        const Text('Continue', style: TextStyle(fontWeight: FontWeight.w800)),
                                         Text('${widget.savedGame!.mode == GameMode.oneNonZero ? 'One non-zero' : 'Historical Date'} · ${widget.savedGame!.game.moveCount} moves', style: const TextStyle(fontSize: 12)),
                                      ])),
                                      const Icon(Icons.arrow_forward),
                                    ]),
                                  ),
                                  const SizedBox(height: 22),
                                ],
                                const Text('CHOOSE A NEW PUZZLE', style: TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                const SizedBox(height: 10),
                                Row(children: [
                                   Expanded(child: _ModeCard(key: const Key('start-one-non-zero-button'), icon: '1 → 0', title: 'One non-zero', detail: 'Leave one number on the board', color: const Color(0xff74d7c4), onPressed: () => widget.onStartMode(GameMode.oneNonZero))),
                                  const SizedBox(width: 10),
                                   Expanded(child: _ModeCard(key: const Key('start-historical-date-button'), icon: '12·04·61', title: 'Historical Date', detail: 'Rebuild a date from an event', color: const Color(0xffec765d), onPressed: () => widget.onStartMode(GameMode.historicalDate))),
                                ]),
                              ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          TextButton(key: const Key('how-to-play-button'), onPressed: widget.onTutorial, child: const Text('How to play', style: TextStyle(color: muted))),
                          TextButton(key: const Key('start-settings-button'), onPressed: widget.onSettings, child: const Text('Settings', style: TextStyle(color: muted))),
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

class _BackgroundNumber extends StatelessWidget {
  const _BackgroundNumber({super.key, required this.value, this.bottom = false});

  final String value;
  final bool bottom;

  @override
  Widget build(BuildContext context) {
    final fontSize = (MediaQuery.sizeOf(context).width * .19).clamp(128.0, 272.0).toDouble();
    final transform = Matrix4.identity()
      ..rotateZ(bottom ? .157 : -.192)
      ..setEntry(1, 0, bottom ? .122 : -.122);
    return Transform(
      alignment: Alignment.center,
      transform: transform,
      child: Text(
        value,
        softWrap: false,
        style: TextStyle(
          color: const Color(0x13f4eddf),
          fontFamily: 'monospace',
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          height: .72,
          letterSpacing: -fontSize * .12,
        ),
      ),
    );
  }
}

class _BackgroundEquation extends StatelessWidget {
  const _BackgroundEquation({
    super.key,
    required this.value,
    required this.color,
    required this.rotation,
  });

  final String value;
  final Color color;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    final fontSize = (MediaQuery.sizeOf(context).width * .026).clamp(17.6, 32.0).toDouble();
    return Transform.rotate(
      angle: rotation,
      child: Text(
        value,
        softWrap: false,
        style: TextStyle(
          color: color,
          fontFamily: 'monospace',
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: fontSize * .08,
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
