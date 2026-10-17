import 'dart:async';

import 'package:flutter/material.dart';
import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/historical_date_game.dart';
import 'package:numbers_game/game_core/one_non_zero_game.dart';
import 'package:numbers_game/game_core/playable_game.dart';
import 'package:numbers_game/game_ui/ambient_formula.dart';
import 'package:numbers_game/game_ui/game_board.dart';
import 'package:numbers_game/game_ui/game_panels.dart';
import 'package:numbers_game/game_state_store.dart';
import 'package:numbers_game/settings_screen.dart';
import 'package:numbers_game/start_screen.dart';
import 'package:numbers_game/tutorial.dart';
import 'package:numbers_game/tutorial_progress_store.dart';

const _swapAnimationDuration = Duration(milliseconds: 1180);
const _swapAfterimageDuration = Duration(milliseconds: 1000);

void main() {
  runApp(const NumbersGameApp());
}

class NumbersGameApp extends StatefulWidget {
  const NumbersGameApp({super.key, this.progressStore, this.gameStateStore});

  final TutorialProgressStore? progressStore;
  final GameStateStore? gameStateStore;

  @override
  State<NumbersGameApp> createState() => _NumbersGameAppState();
}

class _NumbersGameAppState extends State<NumbersGameApp> {
  late final TutorialProgressStore _progressStore;
  late final GameStateStore _gameStateStore;
  late final Future<_AppState> _appState;
  AppSettings? _settings;
  SavedGame? _savedGame;
  GameMode? _activeMode;
  ModeSettings? _activeSettings;
  bool? _showTutorial;
  bool? _tutorialWasHandled;
  bool _showGame = false;
  PlayableGame? _gameToOpen;

  @override
  void initState() {
    super.initState();
    _progressStore =
        widget.progressStore ?? SharedPreferencesTutorialProgressStore();
    _gameStateStore =
        widget.gameStateStore ?? SharedPreferencesGameStateStore();
    _appState = _loadAppState();
  }

  Future<_AppState> _loadAppState() async {
    final settings = await _gameStateStore.loadSettings();
    final savedGame = await _gameStateStore.loadCurrentGame();
    _activeMode = savedGame?.mode ?? settings.selectedMode;
    _activeSettings =
        savedGame?.settings ?? _settingsForMode(settings, _activeMode!);
    final tutorialWasHandled = await _progressStore.hasCompletedOrDismissed();
    _tutorialWasHandled = tutorialWasHandled;
    return _AppState(
      tutorialWasHandled: tutorialWasHandled,
      settings: settings,
      savedGame: savedGame,
    );
  }

  Future<void> _finishTutorial() async {
    await _progressStore.markCompletedOrDismissed();
    if (mounted) {
      setState(() {
        _showTutorial = false;
        _tutorialWasHandled = true;
      });
    }
  }

  void _startTutorial() => setState(() => _showTutorial = true);

  ModeSettings _settingsForMode(AppSettings settings, GameMode mode) =>
      switch (mode) {
        GameMode.oneNonZero => settings.oneNonZeroSettings,
        GameMode.historicalDate => settings.historicalDateSettings,
      };

  Future<void> _saveGame(PlayableGame game) async {
    final savedGame = SavedGame(
      mode: _activeMode!,
      settings: _activeSettings!,
      game: game,
    );
    await _gameStateStore.saveCurrentGame(savedGame);
    if (mounted) {
      setState(() => _savedGame = savedGame);
    }
  }

  Future<PlayableGame> _startNewGame(
    AppSettings settings, [
    GameMode? mode,
  ]) async {
    await _gameStateStore.clearCurrentGame();
    _activeMode = mode ?? _activeMode ?? settings.selectedMode;
    _activeSettings = _settingsForMode(settings, _activeMode!);
    final game = switch (_activeMode!) {
      GameMode.oneNonZero => newOneNonZeroGame(
        _activeSettings! as OneNonZeroSettings,
      ),
      GameMode.historicalDate => newHistoricalDateGame(),
    };
    await _saveGame(game);
    return game;
  }

  Future<void> _startMode(AppSettings settings, GameMode mode) async {
    final game = await _startNewGame(settings, mode);
    if (mounted) {
      setState(() {
        _gameToOpen = game;
        _showGame = true;
      });
    }
  }

  void _continueGame(SavedGame savedGame) => setState(() {
    _activeMode = savedGame.mode;
    _activeSettings = savedGame.settings;
    _gameToOpen = savedGame.game;
    _showGame = true;
  });

  void _returnToMenu() => setState(() {
    _showGame = false;
    _showTutorial = false;
    _gameToOpen = null;
  });

  Future<void> _openSettings(BuildContext context, AppSettings settings) async {
    final updatedSettings = await Navigator.of(context).push<AppSettings>(
      MaterialPageRoute(builder: (_) => SettingsScreen(settings: settings)),
    );
    if (updatedSettings == null) {
      return;
    }
    await _gameStateStore.saveSettings(updatedSettings);
    if (mounted) {
      setState(() => _settings = updatedSettings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Numbers Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: FutureBuilder<_AppState>(
        future: _appState,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final appState = snapshot.data!;
          final showTutorial = _showTutorial ?? false;
          final savedGame = _savedGame ?? appState.savedGame;
          final settings = _settings ?? appState.settings;
          if (!_showGame && !showTutorial) {
            return StartScreen(
              savedGame: savedGame,
              showTutorialCallToAction:
                  !(_tutorialWasHandled ?? appState.tutorialWasHandled),
              onContinue: savedGame == null
                  ? () {}
                  : () => _continueGame(savedGame),
              onStartMode: (mode) => _startMode(settings, mode),
              onTutorial: _startTutorial,
              onSettings: () => unawaited(_openSettings(context, settings)),
            );
          }
          return BoardScreen(
            key: ValueKey(showTutorial),
            initialGame: showTutorial
                ? tutorialDefinition.initialGame
                : _gameToOpen ??
                      savedGame?.game ??
                      switch (settings.selectedMode) {
                        GameMode.oneNonZero => newOneNonZeroGame(
                          settings.oneNonZeroSettings,
                        ),
                        GameMode.historicalDate => newHistoricalDateGame(),
                      },
            tutorial: showTutorial ? tutorialDefinition : null,
            onTutorialFinished: _finishTutorial,
            onStartTutorial: showTutorial ? null : _startTutorial,
            onGameChanged: showTutorial ? null : _saveGame,
            onNewGame: showTutorial ? null : () => _startNewGame(settings),
            onOpenSettings: showTutorial
                ? null
                : () => _openSettings(context, settings),
            onBackToMenu: _returnToMenu,
          );
        },
      ),
    );
  }
}

class BoardScreen extends StatefulWidget {
  const BoardScreen({
    super.key,
    this.initialGame,
    this.tutorial,
    this.onTutorialFinished,
    this.onStartTutorial,
    this.onGameChanged,
    this.onNewGame,
    this.onOpenSettings,
    this.onBackToMenu,
  });

  final PlayableGame? initialGame;
  final TutorialDefinition? tutorial;
  final Future<void> Function()? onTutorialFinished;
  final VoidCallback? onStartTutorial;
  final Future<void> Function(PlayableGame game)? onGameChanged;
  final Future<PlayableGame> Function()? onNewGame;
  final Future<void> Function()? onOpenSettings;
  final VoidCallback? onBackToMenu;

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  late PlayableGame _game;
  CellPosition? _arithmeticSource;
  BoardLineTarget? _swapSource;
  BoardLineTarget? _swapTarget;
  BoardLineTarget? _animatedSwapSource;
  BoardLineTarget? _animatedSwapTarget;
  bool _isAnimatingSwap = false;
  int _swapAnimationId = 0;
  Timer? _swapAnimationTimer;
  final List<BoardSwapAfterimage> _swapAfterimages = [];
  final List<Timer> _swapAfterimageTimers = [];
  bool _isResolving = false;
  CellPosition? _resolvingCell;
  String? _resolvingEquation;
  Timer? _resolutionTimer;
  late GameFeedback _feedback;
  late AmbientFormulaPair _ambientFormulas;
  int _tutorialStepIndex = 0;
  bool _tutorialCompleted = false;

  Board get _board => _game.currentBoard;
  HistoricalDateGame? get _historicalGame =>
      _game is HistoricalDateGame ? _game as HistoricalDateGame : null;
  TutorialStep? get _tutorialStep =>
      widget.tutorial == null || _tutorialCompleted
      ? null
      : widget.tutorial!.steps[_tutorialStepIndex];

  bool get _isTutorial => widget.tutorial != null;
  bool get _disableAnimations => MediaQuery.disableAnimationsOf(context);
  GameFeedback get _sourcePrompt => GameFeedback(
    'Choose a source cell.',
    _historicalGame == null
        ? 'Then choose a target to transform it.'
        : 'Rebuild the date inside the gold frame.',
  );

  bool _isTutorialCellHighlighted(CellPosition position) {
    final step = _tutorialStep;
    if (step?.action != TutorialAction.arithmeticMove) {
      return false;
    }
    return _arithmeticSource == null
        ? step!.source == position
        : step!.target == position;
  }

  bool _isTutorialLineHighlighted(BoardLineKind kind, int index) {
    final step = _tutorialStep;
    if (step?.action != TutorialAction.swapColumns ||
        kind != BoardLineKind.column) {
      return false;
    }
    return _swapSource == null
        ? step!.firstLine == index
        : step!.secondLine == index;
  }

  @override
  void initState() {
    super.initState();
    _game =
        widget.initialGame ??
        OneNonZeroGame(
          Board([
            [1, 2],
            [3, 4],
          ]),
        );
    _ambientFormulas = AmbientFormulaPair.random();
    _feedback = _tutorialStep == null
        ? _sourcePrompt
        : GameFeedback(_tutorialStep!.instruction);
  }

  void _selectCell(CellPosition position) {
    if (_isResolving) {
      return;
    }

    final source = _arithmeticSource;
    if (source == null) {
      final step = _tutorialStep;
      if (step != null &&
          (step.action != TutorialAction.arithmeticMove ||
              step.source != position)) {
        _showTutorialFeedback();
        return;
      }
      setState(() {
        _arithmeticSource = position;
        _feedback = GameFeedback(
          '${_board.valueAt(position)} is the source.',
          'Choose a different target cell.',
        );
      });
      return;
    }

    if (source == position) {
      setState(() {
        _feedback = const GameFeedback('Choose a different target cell.');
      });
      return;
    }

    final step = _tutorialStep;
    if (step != null && !step.matchesArithmetic(source, position)) {
      _showTutorialFeedback();
      return;
    }

    final sourceValue = _board.valueAt(source);
    final targetValue = _board.valueAt(position);
    final adds =
        position.row > source.row ||
        (position.row == source.row && position.column > source.column);
    final result = adds ? sourceValue + targetValue : sourceValue - targetValue;
    final disableAnimations = _disableAnimations;
    setState(() {
      _game = _game.applyArithmeticMove(source: source, target: position);
      _arithmeticSource = null;
      _isResolving = !disableAnimations;
      _resolvingCell = disableAnimations ? null : position;
      _resolvingEquation = disableAnimations
          ? null
          : '${_formatOperand(sourceValue)} ${adds ? '+' : '−'} ${_formatOperand(targetValue)}';
      _feedback = GameFeedback(
        '$sourceValue ${adds ? '+' : '−'} $targetValue = $result.',
        'Choose a source cell.',
      );
    });
    _persistGame();
    _advanceTutorial();
    if (!disableAnimations) {
      _resolutionTimer = Timer(const Duration(milliseconds: 2210), () {
        if (mounted) {
          setState(() {
            _isResolving = false;
            _resolvingCell = null;
            _resolvingEquation = null;
          });
        }
      });
    }
  }

  String _formatOperand(int value) => value < 0 ? '($value)' : '$value';

  void _startSwap(BoardLineTarget source) {
    if (_isResolving) {
      return;
    }
    final step = _tutorialStep;
    if (step != null &&
        (step.action != TutorialAction.swapColumns ||
            source.kind != BoardLineKind.column ||
            source.index != step.firstLine)) {
      _showTutorialFeedback();
      return;
    }
    setState(() {
      _arithmeticSource = null;
      _swapSource = source;
      _swapTarget = null;
      _feedback = GameFeedback(
        'Dragging ${source.kind.label} ${source.index + 1}.',
        'Drop it on another ${source.kind.label}.',
      );
    });
  }

  void _hoverSwapTarget(BoardLineTarget target) {
    if (_swapSource?.accepts(target) ?? false) {
      setState(() => _swapTarget = target);
    }
  }

  void _leaveSwapTarget(BoardLineTarget target) {
    if (_swapTarget == target) {
      setState(() => _swapTarget = null);
    }
  }

  void _cancelSwap() {
    if (_swapSource != null || _swapTarget != null) {
      setState(() {
        _swapSource = null;
        _swapTarget = null;
        _feedback = const GameFeedback(
          'Swap cancelled.',
          'Drag a row or column handle onto another one.',
        );
      });
    }
  }

  void _completeSwap(BoardLineTarget source, BoardLineTarget target) {
    if (!source.accepts(target)) {
      return;
    }
    final step = _tutorialStep;
    if (step != null &&
        (source.kind != BoardLineKind.column ||
            !step.matchesColumnSwap(source.index, target.index))) {
      _cancelSwap();
      _showTutorialFeedback();
      return;
    }

    final disableAnimations = _disableAnimations;
    final afterimages = disableAnimations
        ? const <BoardSwapAfterimage>[]
        : _afterimagesForSwap(source, target);

    setState(() {
      _game = source.kind == BoardLineKind.row
          ? _game.swapRows(source.index, target.index)
          : _game.swapColumns(source.index, target.index);
      _animatedSwapSource = disableAnimations ? null : source;
      _animatedSwapTarget = disableAnimations ? null : target;
      _swapSource = null;
      _swapTarget = null;
      _isAnimatingSwap = !disableAnimations;
      _swapAnimationId++;
      _swapAfterimages.addAll(afterimages);
      _feedback = GameFeedback(
        '${source.kind.label.capitalize()}s swapped.',
        'Choose a source cell.',
      );
    });
    _persistGame();
    _advanceTutorial();
    if (disableAnimations) {
      return;
    }

    _swapAnimationTimer?.cancel();
    _swapAnimationTimer = Timer(_swapAnimationDuration, () {
      if (mounted) {
        setState(() {
          _animatedSwapSource = null;
          _animatedSwapTarget = null;
          _isAnimatingSwap = false;
        });
      }
    });
    if (afterimages.isNotEmpty) {
      late final Timer afterimageTimer;
      afterimageTimer = Timer(_swapAfterimageDuration, () {
        if (mounted) {
          setState(
            () => _swapAfterimages.removeWhere(
              (ghost) => afterimages.contains(ghost),
            ),
          );
        }
        _swapAfterimageTimers.remove(afterimageTimer);
      });
      _swapAfterimageTimers.add(afterimageTimer);
    }
  }

  List<BoardSwapAfterimage> _afterimagesForSwap(
    BoardLineTarget source,
    BoardLineTarget target,
  ) {
    final positions = <CellPosition>{};
    if (source.kind == BoardLineKind.row) {
      for (var column = 0; column < _board.columnCount; column++) {
        positions.add(CellPosition(source.index, column));
        positions.add(CellPosition(target.index, column));
      }
    } else {
      for (var row = 0; row < _board.rowCount; row++) {
        positions.add(CellPosition(row, source.index));
        positions.add(CellPosition(row, target.index));
      }
    }
    return [
      for (final position in positions)
        BoardSwapAfterimage(
          id: _swapAnimationId + 1,
          position: position,
          value: _board.valueAt(position),
          dragSource: source.kind == BoardLineKind.row
              ? position.row == source.index
              : position.column == source.index,
          dragTarget: target.kind == BoardLineKind.row
              ? position.row == target.index
              : position.column == target.index,
        ),
    ];
  }

  void _undo() {
    if (!_game.canUndo || _isResolving) {
      return;
    }
    final restoredGame = _game.undo();
    if (_isTutorial && _tutorialStepIndex > 0) {
      _tutorialStepIndex--;
      _tutorialCompleted = false;
    }
    setState(() {
      _game = restoredGame;
      _resetInteraction();
      _feedback = const GameFeedback('Move undone.', 'Choose a source cell.');
    });
    _persistGame();
  }

  void _restart() {
    setState(() {
      _game = _game.restart();
      _ambientFormulas = AmbientFormulaPair.random();
      _tutorialStepIndex = 0;
      _tutorialCompleted = false;
      _resetInteraction();
      _feedback = const GameFeedback(
        'Game restarted.',
        'Choose a source cell.',
      );
    });
    _persistGame();
  }

  void _persistGame() {
    final onGameChanged = widget.onGameChanged;
    if (onGameChanged != null) {
      unawaited(onGameChanged(_game));
    }
  }

  Future<void> _startNewGame() async {
    final onNewGame = widget.onNewGame;
    if (onNewGame == null) {
      return;
    }
    final game = await onNewGame();
    if (!mounted) {
      return;
    }
    setState(() {
      _game = game;
      _tutorialStepIndex = 0;
      _tutorialCompleted = false;
      _resetInteraction();
      _feedback = const GameFeedback(
        'New game started.',
        'Choose a source cell.',
      );
    });
  }

  void _advanceTutorial() {
    if (!_isTutorial) {
      return;
    }
    setState(() {
      if (_tutorialStepIndex == widget.tutorial!.steps.length - 1) {
        _tutorialCompleted = true;
        _feedback = const GameFeedback('Tutorial complete.');
      } else {
        _tutorialStepIndex++;
        _feedback = GameFeedback(
          widget.tutorial!.steps[_tutorialStepIndex].instruction,
        );
      }
    });
  }

  void _showTutorialFeedback() {
    setState(() {
      _arithmeticSource = null;
      _feedback = GameFeedback(
        _tutorialStep?.instruction ?? 'Follow the tutorial instruction.',
      );
    });
  }

  void _resetInteraction() {
    _swapAnimationTimer?.cancel();
    for (final timer in _swapAfterimageTimers) {
      timer.cancel();
    }
    _swapAfterimageTimers.clear();
    _resolutionTimer?.cancel();
    _arithmeticSource = null;
    _swapSource = null;
    _swapTarget = null;
    _animatedSwapSource = null;
    _animatedSwapTarget = null;
    _isAnimatingSwap = false;
    _swapAfterimages.clear();
    _isResolving = false;
    _resolvingCell = null;
    _resolvingEquation = null;
  }

  @override
  void dispose() {
    _swapAnimationTimer?.cancel();
    for (final timer in _swapAfterimageTimers) {
      timer.cancel();
    }
    _resolutionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTutorial = _isTutorial;
    final isOneNonZero = !isTutorial && _game is OneNonZeroGame;
    final isHistoricalDate = !isTutorial && _game is HistoricalDateGame;
    final usesPuzzlePresentation =
        isTutorial || isHistoricalDate || (isOneNonZero && _board.rowCount > 2);
    final boardVisualConfig = isTutorial
        ? BoardVisualConfig.tutorial
        : isHistoricalDate
        ? BoardVisualConfig.historicalDate
        : isOneNonZero && _board.rowCount > 2
        ? BoardVisualConfig.oneNonZero
        : BoardVisualConfig.standard;
    final baseTheme = Theme.of(context);
    final theme = isTutorial
        ? baseTheme.copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xffb9c4de),
              onPrimary: Color(0xff30384d),
              primaryContainer: Color(0xff9caed2),
              onPrimaryContainer: Color(0xfff1f4ff),
              secondary: Color(0xffd9e3ff),
              secondaryContainer: Color(0xff6f80a0),
              tertiary: Color(0xffd9e3ff),
              tertiaryContainer: Color(0xff3d465d),
              surface: Color(0xff151923),
              onSurface: Color(0xfff4eddf),
              surfaceContainer: Color(0xff2e384d),
              surfaceContainerHighest: Color(0xff515e7c),
              outline: Color(0xffc7d2ed),
            ),
            scaffoldBackgroundColor: const Color(0xff151923),
          )
        : isHistoricalDate
        ? baseTheme.copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xfff3a486),
              onPrimary: Color(0xff44283c),
              primaryContainer: Color(0xffda7a6d),
              onPrimaryContainer: Color(0xffffe3b6),
              secondary: Color(0xfff4b94c),
              secondaryContainer: Color(0xffa37d48),
              tertiary: Color(0xffffd782),
              tertiaryContainer: Color(0xff57384f),
              surface: Color(0xff171525),
              onSurface: Color(0xfff4eddf),
              surfaceContainer: Color(0xff44314f),
              surfaceContainerHighest: Color(0xff674665),
              outline: Color(0xfff3a486),
            ),
            scaffoldBackgroundColor: const Color(0xff171525),
          )
        : isOneNonZero
        ? baseTheme.copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xff74d7c4),
              onPrimary: Color(0xff102f38),
              primaryContainer: Color(0xff5aa89e),
              onPrimaryContainer: Color(0xffb9fff1),
              secondary: Color(0xfff4b94c),
              secondaryContainer: Color(0xffa37d48),
              tertiary: Color(0xffb9fff1),
              tertiaryContainer: Color(0xff234a59),
              surface: Color(0xff131a2a),
              onSurface: Color(0xfff4eddf),
              surfaceContainer: Color(0xff183e4e),
              surfaceContainerHighest: Color(0xff366471),
              outline: Color(0xff74d7c4),
            ),
            scaffoldBackgroundColor: const Color(0xff131a2a),
          )
        : baseTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: usesPuzzlePresentation
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(isOneNonZero ? 'ONE NON-ZERO' : 'Numbers Game'),
                centerTitle: true,
                actions: [
                  if (isOneNonZero)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          '${_game.moveCount.toString().padLeft(2, '0')} moves',
                          style: const TextStyle(
                            color: Color(0xff74d7c4),
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  if (widget.onOpenSettings != null)
                    IconButton(
                      key: const Key('settings-button'),
                      icon: const Icon(Icons.settings),
                      tooltip: 'Settings',
                      onPressed: () => unawaited(widget.onOpenSettings!()),
                    ),
                ],
              ),
        body: Container(
          decoration: isTutorial
              ? const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-.04, .04),
                    radius: 1.35,
                    colors: [Color(0xff30384d), Color(0xff151923)],
                  ),
                )
              : isHistoricalDate
              ? const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-.66, -.66),
                    radius: 1.5,
                    colors: [Color(0xff513b5d), Color(0xff171525)],
                  ),
                )
              : isOneNonZero
              ? const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-.55, -.7),
                    radius: 1.3,
                    colors: [Color(0xff1f5364), Color(0xff131a2a)],
                  ),
                )
              : null,
          child: Stack(
            children: [
              if (isTutorial) ...[
                Positioned(
                  top: 54,
                  left: -18,
                  child: IgnorePointer(
                    child: Text(
                      _ambientFormulas.top.display,
                      style: const TextStyle(
                        color: Color(0x0df4eddf),
                        fontSize: 110,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -16,
                  bottom: 24,
                  child: IgnorePointer(
                    child: Text(
                      _ambientFormulas.bottom.display,
                      style: const TextStyle(
                        color: Color(0x0df4eddf),
                        fontSize: 110,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ] else if (isOneNonZero) ...[
                Positioned(
                  top: 54,
                  left: -18,
                  child: IgnorePointer(
                    child: Text(
                      _ambientFormulas.top.display,
                      style: const TextStyle(
                        color: Color(0x0df4eddf),
                        fontSize: 110,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -16,
                  bottom: 24,
                  child: IgnorePointer(
                    child: Text(
                      _ambientFormulas.bottom.display,
                      style: const TextStyle(
                        color: Color(0x0df4eddf),
                        fontSize: 110,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              if (isHistoricalDate) ...[
                Positioned(
                  top: 54,
                  left: -18,
                  child: IgnorePointer(
                    child: Text(
                      _ambientFormulas.top.display,
                      style: const TextStyle(
                        color: Color(0x0df4eddf),
                        fontSize: 110,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -16,
                  bottom: 24,
                  child: IgnorePointer(
                    child: Text(
                      _ambientFormulas.bottom.display,
                      style: const TextStyle(
                        color: Color(0x0df4eddf),
                        fontSize: 110,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              SafeArea(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isTutorial
                            ? 448
                            : usesPuzzlePresentation
                            ? 620
                            : 420,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (usesPuzzlePresentation)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    TextButton(
                                      key: const Key('back-to-menu-button'),
                                      onPressed: widget.onBackToMenu,
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xffbcb6aa,
                                        ),
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                      ),
                                      child: const Text(
                                        '← Back to menu',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          isTutorial
                                              ? 'TUTORIAL'
                                              : isHistoricalDate
                                              ? 'HISTORICAL DATE'
                                              : 'ONE NON-ZERO',
                                          style: const TextStyle(
                                            color: Color(0xfff4eddf),
                                            fontFamily: 'serif',
                                            fontSize: 23,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          isTutorial
                                              ? '${_tutorialStepIndex + 1} / ${widget.tutorial!.steps.length}'
                                              : '${_game.moveCount.toString().padLeft(2, '0')} moves',
                                          style: TextStyle(
                                            color: isTutorial
                                                ? const Color(0xffc7d2ed)
                                                : isHistoricalDate
                                                ? const Color(0xfff3a486)
                                                : const Color(0xff74d7c4),
                                            fontFamily: 'monospace',
                                            fontSize: 12,
                                          ),
                                        ),
                                        if (widget.onOpenSettings != null)
                                          IconButton(
                                            key: const Key('settings-button'),
                                            icon: const Icon(
                                              Icons.settings_outlined,
                                              size: 18,
                                            ),
                                            tooltip: 'Settings',
                                            onPressed: () => unawaited(
                                              widget.onOpenSettings!(),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            if (isTutorial)
                              _TutorialObjective(stepIndex: _tutorialStepIndex)
                            else if (!usesPuzzlePresentation)
                              Text(
                                _tutorialCompleted
                                    ? 'Tutorial complete!'
                                    : _tutorialStep?.instruction ?? 'Select a source cell, then a target cell.',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                            if (_historicalGame
                                case final HistoricalDateGame game)
                              HistoricalEventPanel(game: game),
                            if (isOneNonZero && _board.rowCount > 2)
                              const _OneNonZeroObjective(),
                            const SizedBox(height: 12),
                            if (!isTutorial)
                              GameActionControls(
                                children: [
                                  OutlinedButton.icon(
                                    key: const Key('undo-button'),
                                    onPressed: _game.canUndo && !_isResolving
                                        ? _undo
                                        : null,
                                    icon: const Icon(Icons.undo),
                                    label: const Text('Undo'),
                                  ),
                                  OutlinedButton.icon(
                                    key: const Key('restart-button'),
                                    onPressed: _restart,
                                    icon: const Icon(Icons.restart_alt),
                                    label: const Text('Restart'),
                                  ),
                                  if (widget.onNewGame != null &&
                                      !isHistoricalDate)
                                    OutlinedButton.icon(
                                      key: const Key('new-game-button'),
                                      onPressed: _startNewGame,
                                      icon: const Icon(Icons.add),
                                      label: const Text('New game'),
                                    ),
                                  if (!_isTutorial &&
                                      (!isOneNonZero || isHistoricalDate) &&
                                      widget.onStartTutorial != null)
                                    OutlinedButton(
                                      key: const Key('start-tutorial-button'),
                                      onPressed: widget.onStartTutorial,
                                      child: Text(
                                        usesPuzzlePresentation
                                            ? '? Rules'
                                            : 'Tutorial',
                                      ),
                                    ),
                                ],
                              ),
                            if (_tutorialCompleted)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: FilledButton(
                                  key: const Key('finish-tutorial-button'),
                                  onPressed: widget.onTutorialFinished,
                                  child: const Text('Play'),
                                ),
                              ),
                            const SizedBox(height: 12),
                            const SizedBox(height: 24),
                            GameBoard(
                              board: _board,
                              selectedCell: _arithmeticSource,
                              swapAfterimages: _swapAfterimages,
                              isAnimatingSwap: _isAnimatingSwap,
                              swapSource: _animatedSwapSource,
                              swapTarget: _animatedSwapTarget,
                              swapAnimationId: _swapAnimationId,
                              disableAnimations: _disableAnimations,
                              resolvingCell: _resolvingCell,
                              resolvingEquation: _resolvingEquation,
                              visualConfig: boardVisualConfig,
                              sourceLineHighlight: _swapSource,
                              targetLineHighlight: _swapTarget,
                              historicalGame: _historicalGame,
                              isTutorialCellHighlighted:
                                  _isTutorialCellHighlighted,
                              isTutorialLineHighlighted:
                                  _isTutorialLineHighlighted,
                              onCellPressed: _selectCell,
                              onDragStarted: _startSwap,
                              onHover: _hoverSwapTarget,
                              onLeave: _leaveSwapTarget,
                              onAccept: _completeSwap,
                              onDragCancelled: _cancelSwap,
                            ),
                            const SizedBox(height: 24),
                            GameStatusPanel(
                              moveCount: _game.moveCount,
                              feedback: _feedback,
                              isWon: _game.isWon,
                              isLost: _game.isLost,
                              showMoveCount: !usesPuzzlePresentation,
                            ),
                            if (isTutorial)
                              _TutorialProgress(
                                stepIndex: _tutorialStepIndex,
                                count: widget.tutorial!.steps.length,
                              ),
                            if (usesPuzzlePresentation)
                              Padding(
                                padding: EdgeInsets.only(top: 18),
                                child: isTutorial
                                    ? TextButton(
                                        key: const Key('skip-tutorial-button'),
                                        onPressed: widget.onTutorialFinished,
                                        child: const Text(
                                          'Skip tutorial',
                                          style: TextStyle(
                                            color: Color(0xffb9c4de),
                                            fontSize: 12,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        'Drag the marks at a row or column edge to swap it · How moves work',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xffbcb6aa),
                                          fontSize: 12,
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
          ),
        ),
      ),
    );
  }
}

class _OneNonZeroObjective extends StatelessWidget {
  const _OneNonZeroObjective();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 18),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xff234a59), Color(0xff1b3146)],
      ),
      border: Border.all(color: const Color(0x3d74d7c4)),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(15),
        bottomLeft: Radius.circular(18),
        bottomRight: Radius.circular(14),
      ),
      boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 20)],
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leave one positive number.',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 21,
            color: Color(0xfff4eddf),
          ),
        ),
        SizedBox(height: 3),
        Text(
          'Turn every other cell into 0.',
          style: TextStyle(color: Color(0xffbcb6aa), fontSize: 13),
        ),
      ],
    ),
  );
}

class _TutorialObjective extends StatelessWidget {
  const _TutorialObjective({required this.stepIndex});

  final int stepIndex;

  @override
  Widget build(BuildContext context) {
    const objectives = [
      (title: 'Make a zero.', detail: 'Tap the upper-left 1, then −1.'),
      (
        title: 'Swap the columns.',
        detail: 'Drag the highlighted top handle to the other one.',
      ),
      (
        title: 'Make the last zero.',
        detail: 'Tap the lower-right 1, then the upper-right 1.',
      ),
    ];
    final objective = objectives[stepIndex.clamp(0, objectives.length - 1)];
    return Container(
      key: const Key('tutorial-objective'),
      margin: const EdgeInsets.only(top: 20, bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(59, 68, 91, .90),
            Color.fromRGBO(42, 48, 67, .92),
          ],
        ),
        border: Border.all(color: const Color.fromRGBO(205, 215, 239, .28)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(21),
          bottomRight: Radius.circular(14),
        ),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            objective.title,
            style: const TextStyle(
              color: Color(0xfff4eddf),
              fontFamily: 'serif',
              fontSize: 25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            objective.detail,
            style: const TextStyle(color: Color(0xffd2d0c8), fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class _TutorialProgress extends StatelessWidget {
  const _TutorialProgress({required this.stepIndex, required this.count});

  final int stepIndex;
  final int count;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Semantics(
      label: 'Tutorial progress: step ${stepIndex + 1} of $count',
      child: Row(
        key: const Key('tutorial-progress'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < count; index++)
            Container(
              key: Key('tutorial-progress-$index'),
              width: 24,
              height: 5,
              margin: EdgeInsets.only(right: index == count - 1 ? 0 : 6),
              decoration: BoxDecoration(
                color: index == stepIndex
                    ? const Color(0xffd9e3ff)
                    : const Color.fromRGBO(205, 215, 239, .22),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
        ],
      ),
    ),
  );
}

class _AppState {
  const _AppState({
    required this.tutorialWasHandled,
    required this.settings,
    required this.savedGame,
  });

  final bool tutorialWasHandled;
  final AppSettings settings;
  final SavedGame? savedGame;
}

extension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
