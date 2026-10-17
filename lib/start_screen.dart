import 'dart:async';
import 'dart:math';
import 'dart:ui';

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
            Positioned.fill(
              child: IgnorePointer(
                child: _BackgroundLens(
                  key: const Key('start-background-lens'),
                  topValue: _ambientFormulas.top.display,
                  bottomValue: _ambientFormulas.bottom.display,
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
                child: _TiltingEquation(
                  key: const Key('start-background-equation-left'),
                  child: const _BackgroundEquation(
                    value: '( 0 ) = 1',
                    color: Color(0x3074d7c4),
                    rotation: 0,
                  ),
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
              right: -40,
              top: screenSize.height * .42,
              child: IgnorePointer(
                child: const _AtmosphericOrb(key: Key('start-atmospheric-orb')),
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
                        const _ShiftingTitle(key: Key('start-title')),
                        const SizedBox(height: 26),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: DecoratedBox(
                              key: const Key('start-glass-panel'),
                              decoration: BoxDecoration(
                                color: const Color(0xd61c263a),
                                border: Border.all(color: const Color(0x2eede0bf)),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x3d000000),
                                    offset: Offset(0, 24),
                                    blurRadius: 48,
                                  ),
                                ],
                              ),
                              child: Stack(
                            children: [
                              const Positioned.fill(
                                child: IgnorePointer(
                                  child: _Meteor(key: Key('start-meteor')),
                                ),
                              ),
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
                                   Padding(
                                     padding: const EdgeInsets.all(10),
                                     child: _RandomDrift(
                                      key: const Key('tutorial-random-drift'),
                                      initialDelay: const Duration(milliseconds: 700),
                                      verticalRange: 26,
                                      child: FilledButton(
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
                                     ),
                                   ),
                                   const SizedBox(height: 12),
                                ],
                                if (widget.savedGame != null) ...[
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: _RandomDrift(
                                    key: const Key('continue-random-drift'),
                                    initialDelay: const Duration(milliseconds: 700),
                                    verticalRange: 26,
                                    child: _MovingGradient(
                                      key: const Key('continue-moving-gradient'),
                                      duration: const Duration(seconds: 25),
                                      initialProgress: .32,
                                      colors: const [Color(0xfff4be55), Color(0xffe98550)],
                                      builder: (context, gradient) => _LivingCorners(
                                      key: const Key('continue-living-corners'),
                                      duration: const Duration(seconds: 14),
                                      initialDelay: const Duration(seconds: 3),
                                      builder: (context, radius) => DecoratedBox(
                                        key: const Key('continue-gradient'),
                                        decoration: BoxDecoration(
                                          gradient: gradient,
                                          borderRadius: radius,
                                        ),
                                        child: FilledButton(
                                          key: const Key('continue-game-button'),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            foregroundColor: const Color(0xff252039),
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.all(16),
                                            shape: RoundedRectangleBorder(borderRadius: radius),
                                          ),
                                          onPressed: widget.onContinue,
                                          child: Row(children: [
                                        Container(
                                          key: const Key('continue-token'),
                                          width: 45,
                                          height: 45,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: const Color(0x29252039),
                                            border: Border.all(color: const Color(0x24252039)),
                                            borderRadius: BorderRadius.circular(11),
                                          ),
                                          child: const Text(
                                            '−1',
                                            style: TextStyle(fontFamily: 'monospace', fontSize: 22),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          const Text('Continue', style: TextStyle(fontWeight: FontWeight.w800)),
                                           Text('${widget.savedGame!.mode == GameMode.oneNonZero ? 'One non-zero' : 'Historical Date'} · ${widget.savedGame!.game.moveCount} moves', style: const TextStyle(fontSize: 12)),
                                        ])),
                                        const Icon(Icons.arrow_forward),
                                          ]),
                                        ),
                                      ),
                                    ),
                                    ),
                                   ),
                                  ),
                                  const SizedBox(height: 22),
                                ],
                                const SizedBox(height: 13),
                                const SizedBox(height: 10),
                                Row(children: [
                                    Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: _ModeCard(key: const Key('start-one-non-zero-button'), icon: '1 → 0', title: 'One non-zero', detail: 'Leave one number on the board', color: const Color(0xff74d7c4), onPressed: () => widget.onStartMode(GameMode.oneNonZero)))),
                                   const SizedBox(width: 8),
                                     Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: _ModeCard(key: const Key('start-historical-date-button'), icon: '12·04·61', title: 'Historical Date', detail: 'Rebuild a date from an event', color: const Color(0xffec765d), onPressed: () => widget.onStartMode(GameMode.historicalDate)))),
                                ]),
                              ],
                                ),
                              ),
                            ],
                              ),
                            ),
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

class _Meteor extends StatefulWidget {
  const _Meteor({super.key});

  @override
  State<_Meteor> createState() => _MeteorState();
}

class _MeteorState extends State<_Meteor> with SingleTickerProviderStateMixin {
  final _random = Random();
  late final AnimationController _controller;
  Timer? _timer;
  Offset _start = Offset.zero;
  Offset _end = Offset.zero;
  double _angle = -.49;
  bool? _reducedMotion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _timer = Timer(Duration(milliseconds: 35000 + _random.nextInt(25001)), _launch);
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion == reducedMotion) return;
    _reducedMotion = reducedMotion;
    _timer?.cancel();
    if (reducedMotion) {
      _controller.stop();
      _controller.value = 0;
    } else {
      _timer = Timer(Duration(milliseconds: 12000 + _random.nextInt(10001)), _launch);
    }
  }

  void _launch() {
    if (!mounted || _reducedMotion == true) return;
    final size = context.size;
    if (size == null) return;
    switch (_random.nextInt(4)) {
      case 0:
        _start = Offset(-128, size.height * (.14 + _random.nextDouble() * .62));
        _end = Offset(784, 96 + _random.nextDouble() * 208);
        _angle = (-31 + _random.nextDouble() * 14) * pi / 180;
      case 1:
        _start = Offset(size.width + 16, size.height * (.14 + _random.nextDouble() * .62));
        _end = Offset(-784, -304 + _random.nextDouble() * 208);
        _angle = (149 + _random.nextDouble() * 14) * pi / 180;
      case 2:
        _start = Offset(size.width * (.15 + _random.nextDouble() * .66), -16);
        _end = Offset(-192 + _random.nextDouble() * 384, 320);
        _angle = (49 + _random.nextDouble() * 18) * pi / 180;
      case 3:
        _start = Offset(size.width * (.15 + _random.nextDouble() * .66), size.height + 16);
        _end = Offset(-192 + _random.nextDouble() * 384, -320);
        _angle = (-131 + _random.nextDouble() * 18) * pi / 180;
    }
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = Curves.easeOut.transform(_controller.value);
          final opacity = progress < .14
              ? .42 * progress / .14
              : .42 * (1 - (progress - .14) / .86);
          final offset = Offset.lerp(_start, _start + _end, progress)!;
          return Transform.translate(
            offset: offset,
            child: Transform.rotate(
              angle: _angle,
              child: Opacity(
                opacity: opacity.clamp(0, 1),
                child: Container(
                  width: 64,
                  height: 1,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0x1ff4eddf),
                        Color(0xa8f4b94c),
                        Colors.transparent,
                      ],
                      stops: [0, .18, .55, 1],
                    ),
                    boxShadow: [BoxShadow(color: Color(0x47f4b94c), blurRadius: 4)],
                  ),
                  child: const Align(
                    alignment: Alignment(.68, 0),
                    child: SizedBox(
                      width: 3,
                      height: 3,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xfffff4cf),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Color(0xccfff4cf), blurRadius: 4)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
}

class _BackgroundLens extends StatefulWidget {
  const _BackgroundLens({super.key, required this.topValue, required this.bottomValue});

  final String topValue;
  final String bottomValue;

  @override
  State<_BackgroundLens> createState() => _BackgroundLensState();
}

class _BackgroundLensState extends State<_BackgroundLens>
    with SingleTickerProviderStateMixin {
  final _random = Random();
  late final AnimationController _controller;
  Timer? _timer;
  Offset _from = const Offset(.18, .16);
  Offset _to = const Offset(.18, .16);
  bool? _reducedMotion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 24))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _timer = Timer(const Duration(milliseconds: 500), _startSegment);
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion == reducedMotion) return;
    _reducedMotion = reducedMotion;
    _timer?.cancel();
    if (reducedMotion) {
      _controller.stop();
      _controller.value = 0;
      _from = const Offset(.18, .16);
      _to = _from;
    } else {
      _timer = Timer(const Duration(milliseconds: 1800), _startSegment);
    }
  }

  void _startSegment() {
    if (!mounted || _reducedMotion == true) return;
    _from = Offset.lerp(_from, _to, _controller.value)!;
    _to = Offset(
      _random.nextDouble(),
      -.2 + _random.nextDouble() * 1.4,
    );
    _controller.duration = Duration(milliseconds: 24000 + _random.nextInt(20001));
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            const lensSize = 208.0;
            final position = Offset.lerp(
              _from,
              _to,
              const Cubic(.42, 0, .25, 1).transform(_controller.value),
            )!;
            final horizontalRange = max(0.0, constraints.maxWidth - lensSize);
            final verticalRange = max(0.0, constraints.maxHeight - lensSize);
            final left = horizontalRange * position.dx;
            final top = verticalRange * position.dy;
            return Stack(
              children: [
                Positioned(
                  left: left,
                  top: top,
                  child: Opacity(
                opacity: .62,
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bounds) => const RadialGradient(
                    colors: [
                      Colors.black,
                      Colors.black,
                      Color(0x7a000000),
                      Colors.transparent,
                    ],
                    stops: [.43, .43, .67, .82],
                  ).createShader(bounds),
                  child: ClipOval(
                    child: SizedBox(
                      width: lensSize,
                      height: lensSize,
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          const Positioned.fill(
                            child: ColoredBox(color: Color(0xff131a2a)),
                          ),
                          const Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment(-.04, .04),
                                  radius: 1.48,
                                  colors: [Color(0xff273356), Colors.transparent],
                                ),
                              ),
                            ),
                          ),
                          const Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment(.64, .52),
                                  radius: 1.16,
                                  colors: [Color(0x2eec765d), Colors.transparent],
                                ),
                              ),
                            ),
                          ),
                          const Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment(-.66, -.64),
                                  radius: 1.22,
                                  colors: [Color(0x3374d7c4), Colors.transparent],
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..scaleByDouble(1.18, 1.18, 1, 1),
                              child: Transform.translate(
                                offset: Offset(-left, -top),
                                child: SizedBox(
                                  width: constraints.maxWidth,
                                  height: constraints.maxHeight,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 64,
                                        left: -8,
                                        child: _BackgroundNumber(value: widget.topValue),
                                      ),
                                      Positioned(
                                        right: 64,
                                        bottom: 32,
                                        child: _BackgroundNumber(value: widget.bottomValue, bottom: true),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
                ),
              ],
            );
          },
        ),
      );
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

class _TiltingEquation extends StatefulWidget {
  const _TiltingEquation({super.key, required this.child});

  final Widget child;

  @override
  State<_TiltingEquation> createState() => _TiltingEquationState();
}

class _TiltingEquationState extends State<_TiltingEquation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _reducedMotion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 50),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion == reducedMotion) return;
    _reducedMotion = reducedMotion;
    if (reducedMotion) {
      _controller.stop();
      _controller.value = 0;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          final progress = Curves.easeInOut.transform(_controller.value);
          final travel = MediaQuery.sizeOf(context).height * .20;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translateByDouble(0, -travel * progress, 0, 1)
              ..rotateZ(-.314 + .700 * progress),
            child: child,
          );
        },
      );

}

class _RandomDrift extends StatefulWidget {
  const _RandomDrift({
    super.key,
    required this.initialDelay,
    required this.child,
    this.verticalRange = 6,
  });

  final Duration initialDelay;
  final Widget child;
  final double verticalRange;

  @override
  State<_RandomDrift> createState() => _RandomDriftState();
}

class _RandomDriftState extends State<_RandomDrift>
    with SingleTickerProviderStateMixin {
  final _random = Random();
  late final AnimationController _controller;
  Timer? _timer;
  Offset _fromOffset = Offset.zero;
  Offset _toOffset = Offset.zero;
  double _fromRotation = 0;
  double _toRotation = 0;
  bool? _reducedMotion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 7))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _timer = Timer(const Duration(milliseconds: 400), _startSegment);
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion == reducedMotion) return;
    _reducedMotion = reducedMotion;
    _timer?.cancel();
    if (reducedMotion) {
      _controller.stop();
      _controller.value = 0;
      _fromOffset = Offset.zero;
      _toOffset = Offset.zero;
      _fromRotation = 0;
      _toRotation = 0;
    } else {
      _timer = Timer(widget.initialDelay, _startSegment);
    }
  }

  void _startSegment() {
    if (!mounted || _reducedMotion == true) return;
    _fromOffset = Offset.lerp(_fromOffset, _toOffset, _controller.value)!;
    _fromRotation = lerpDouble(_fromRotation, _toRotation, _controller.value)!;
    _toOffset = Offset(
      (_random.nextDouble() - .5) * 10,
      (_random.nextDouble() - .5) * 2 * widget.verticalRange,
    );
    _toRotation = (_random.nextDouble() - .5) * 6;
    _controller.duration = Duration(milliseconds: 14000 + _random.nextInt(12001));
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          final progress = const Cubic(.42, 0, .25, 1).transform(_controller.value);
          final offset = Offset.lerp(_fromOffset, _toOffset, progress)!;
          final rotation = lerpDouble(_fromRotation, _toRotation, progress)!;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translateByDouble(offset.dx, offset.dy, 0, 1)
              ..rotateZ(rotation * pi / 180),
            child: child,
          );
        },
      );
}

class _MovingGradient extends StatefulWidget {
  const _MovingGradient({
    super.key,
    required this.duration,
    required this.colors,
    required this.builder,
    this.initialProgress = 0,
  });

  final Duration duration;
  final List<Color> colors;
  final Widget Function(BuildContext context, LinearGradient gradient) builder;
  final double initialProgress;

  @override
  State<_MovingGradient> createState() => _MovingGradientState();
}

class _MovingGradientState extends State<_MovingGradient>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _reducedMotion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.value = widget.initialProgress;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion == reducedMotion) return;
    _reducedMotion = reducedMotion;
    if (reducedMotion) {
      _controller.stop();
      _controller.value = 0;
    } else {
      if (_controller.value == 0) _controller.value = widget.initialProgress;
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = Curves.easeInOut.transform(_controller.value) * 4;
          const positions = [
            Offset(0, 0),
            Offset(1, 0),
            Offset(1, 1),
            Offset(0, 1),
            Offset(0, 0),
          ];
          final index = progress.floor().clamp(0, positions.length - 2);
          final position = Offset.lerp(
            positions[index],
            positions[index + 1],
            progress - index,
          )!;
          const excess = .70;
          final begin = Alignment(
            -1 - 2 * excess * position.dx,
            -1 - 2 * excess * position.dy,
          );
          final end = Alignment(
            1 + 2 * excess * (1 - position.dx),
            1 + 2 * excess * (1 - position.dy),
          );
          return widget.builder(
            context,
            LinearGradient(begin: begin, end: end, colors: widget.colors),
          );
        },
      );
}

class _ShiftingTitle extends StatefulWidget {
  const _ShiftingTitle({super.key});

  @override
  State<_ShiftingTitle> createState() => _ShiftingTitleState();
}

class _ShiftingTitleState extends State<_ShiftingTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _reducedMotion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 66),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion == reducedMotion) return;
    _reducedMotion = reducedMotion;
    if (reducedMotion) {
      _controller.stop();
      _controller.value = 0;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = Curves.easeInOut.transform(_controller.value);
          const colors = [
            Color(0xfff4eddf),
            Color(0xffe7b6c3),
            Color(0xffcbb3db),
            Color(0xff9dbfdb),
            Color(0xffa8c9ad),
            Color(0xffe4cb8d),
            Color(0xffe9ae8b),
          ];
          final segment = progress * (colors.length - 1);
          final start = segment.floor().clamp(0, colors.length - 1);
          final end = (start + 1).clamp(0, colors.length - 1);
          final color = Color.lerp(colors[start], colors[end], segment - start)!;
          return Text(
            'NUMBERS\nGAME',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontFamily: 'serif',
              fontSize: 54,
              height: .82,
              letterSpacing: 3,
              shadows: const [
                Shadow(color: Color(0x47000000), offset: Offset(0, 2.4)),
                Shadow(color: Color(0x14f4eddf), blurRadius: 32),
              ],
            ),
          );
        },
      );

}

class _AtmosphericOrb extends StatefulWidget {
  const _AtmosphericOrb({super.key});

  @override
  State<_AtmosphericOrb> createState() => _AtmosphericOrbState();
}

class _AtmosphericOrbState extends State<_AtmosphericOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _reducedMotion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion == reducedMotion) return;
    _reducedMotion = reducedMotion;
    if (reducedMotion) {
      _controller.stop();
      _controller.value = 0;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = Curves.easeInOut.transform(_controller.value);
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translateByDouble(-19.2 * progress, 16 * progress, 0, 1)
              ..rotateZ(-.279 + (.227 + .279) * progress)
              ..scaleByDouble(1 + .08 * progress, 1 + .08 * progress, 1, 1),
            child: child,
          );
        },
        child: Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0x3374d7c4)),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.elliptical(60, 61),
              topRight: Radius.elliptical(68, 55),
              bottomRight: Radius.elliptical(65, 73),
              bottomLeft: Radius.elliptical(63, 67),
            ),
            gradient: const RadialGradient(
              center: Alignment(-.34, -.50),
              colors: [
                Color.fromRGBO(255, 255, 255, .34),
                Color.fromRGBO(116, 215, 196, .16),
                Color.fromRGBO(19, 26, 42, .08),
                Colors.transparent,
              ],
              stops: [0, .30, .68, 1],
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x14030a19), offset: Offset(-8, -11), blurRadius: 22),
              BoxShadow(color: Color(0x1474d7c4), blurRadius: 48),
            ],
          ),
        ),
      );

}

class _LivingCorners extends StatefulWidget {
  const _LivingCorners({
    super.key,
    required this.duration,
    required this.initialDelay,
    required this.builder,
  });

  final Duration duration;
  final Duration initialDelay;
  final Widget Function(BuildContext context, BorderRadius radius) builder;

  @override
  State<_LivingCorners> createState() => _LivingCornersState();
}

class _LivingCornersState extends State<_LivingCorners>
    with SingleTickerProviderStateMixin {
  static const _initial = BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(11),
    bottomLeft: Radius.circular(22),
    bottomRight: Radius.circular(12),
  );
  static const _softened = BorderRadius.only(
    topLeft: Radius.circular(11),
    topRight: Radius.circular(22),
    bottomLeft: Radius.circular(12),
    bottomRight: Radius.circular(23),
  );

  late final AnimationController _controller;
  bool? _reducedMotion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.value =
        widget.initialDelay.inMilliseconds % widget.duration.inMilliseconds /
            widget.duration.inMilliseconds;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion == reducedMotion) {
      return;
    }
    _reducedMotion = reducedMotion;
    if (reducedMotion) {
      _controller.stop();
      _controller.value = 0;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => widget.builder(
          context,
          BorderRadius.lerp(
            _initial,
            _softened,
            Curves.easeInOut.transform(_controller.value),
          )!,
        ),
      );
}

class _MovingModeGradients extends StatefulWidget {
  const _MovingModeGradients({
    super.key,
    required this.duration,
    required this.color,
    required this.isTeal,
    required this.builder,
  });

  final Duration duration;
  final Color color;
  final bool isTeal;
  final Widget Function(LinearGradient gradient, RadialGradient glow) builder;

  @override
  State<_MovingModeGradients> createState() => _MovingModeGradientsState();
}

class _MovingModeGradientsState extends State<_MovingModeGradients>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _reducedMotion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion == reducedMotion) return;
    _reducedMotion = reducedMotion;
    if (reducedMotion) {
      _controller.stop();
      _controller.value = 0;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = Curves.easeInOut.transform(_controller.value) * 4;
          final radialPositions = widget.isTeal ? const [
            Offset(0, 0),
            Offset(1, 0),
            Offset(1, 1),
            Offset(0, 1),
            Offset(0, 0),
          ] : const [
            Offset(1, 0),
            Offset(0, 0),
            Offset(0, 1),
            Offset(1, 1),
            Offset(1, 0),
          ];
          final linearPositions = widget.isTeal ? const [
            Offset(.5, .5),
            Offset(.65, .35),
            Offset(.5, .5),
            Offset(.35, .65),
            Offset(.5, .5),
          ] : const [
            Offset(.5, .5),
            Offset(.35, .65),
            Offset(.5, .5),
            Offset(.65, .35),
            Offset(.5, .5),
          ];
          final index = progress.floor().clamp(0, radialPositions.length - 2);
          final t = progress - index;
          final radialPosition = Offset.lerp(radialPositions[index], radialPositions[index + 1], t)!;
          final linearPosition = Offset.lerp(linearPositions[index], linearPositions[index + 1], t)!;
          final gradient = LinearGradient(
            begin: Alignment(-1 - linearPosition.dx, -1 - linearPosition.dy),
            end: Alignment(2 - linearPosition.dx, 2 - linearPosition.dy),
            colors: widget.isTeal
                ? const [Color(0xff304565), Color(0xff2b3855), Color(0xff26324d)]
                : const [Color(0xff3d3a5d), Color(0xff363a59), Color(0xff29354d)],
            stops: widget.isTeal ? const [0, .58, 1] : const [0, .55, 1],
          );
          final glow = RadialGradient(
            center: Alignment(-.8 + 1.6 * radialPosition.dx, -.56 + 1.12 * radialPosition.dy),
            radius: 1.08,
            colors: [widget.color.withValues(alpha: widget.isTeal ? .26 : .24), Colors.transparent],
          );
          return widget.builder(gradient, glow);
        },
      );
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({super.key, required this.icon, required this.title, required this.detail, required this.color, required this.onPressed});
  final String icon;
  final String title;
  final String detail;
  final Color color;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    final isTeal = color == const Color(0xff74d7c4);
    Widget buildCard(LinearGradient gradient, RadialGradient glow) => _LivingCorners(
          key: Key(isTeal ? 'start-mode-living-teal' : 'start-mode-living-coral'),
          duration: Duration(seconds: isTeal ? 12 : 13),
          initialDelay: Duration(seconds: isTeal ? 0 : 4),
          builder: (context, radius) => DecoratedBox(
            key: Key(isTeal ? 'start-mode-gradient-teal' : 'start-mode-gradient-coral'),
            decoration: BoxDecoration(gradient: gradient, borderRadius: radius),
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: glow, borderRadius: radius),
              child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(14),
            minimumSize: const Size(0, 134),
            alignment: Alignment.centerLeft,
            backgroundColor: Colors.transparent,
            side: const BorderSide(color: Color(0x2eede0bf)),
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(icon, style: TextStyle(color: color, fontFamily: 'monospace', fontSize: 18)),
            const SizedBox(height: 42),
            Text(title, style: const TextStyle(color: Color(0xfff4eddf), fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(detail, style: const TextStyle(color: Color(0xffbcb6aa), fontSize: 11)),
          ]),
              ),
            ),
          ),
        );
    return _RandomDrift(
      key: Key(isTeal ? 'start-mode-random-drift-teal' : 'start-mode-random-drift-coral'),
      initialDelay: Duration(milliseconds: isTeal ? 2300 : 3900),
      verticalRange: 32,
      child: _MovingModeGradients(
        key: Key(isTeal ? 'start-mode-moving-teal-gradient' : 'start-mode-moving-coral-gradient'),
        duration: const Duration(seconds: 100),
        color: color,
        isTeal: isTeal,
        builder: buildCard,
      ),
    );
  }
}
