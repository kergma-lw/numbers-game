import 'dart:async';

import 'package:flutter/material.dart';
import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/historical_date_game.dart';
import 'package:numbers_game/game_core/one_non_zero_game.dart';
import 'package:numbers_game/game_core/playable_game.dart';
import 'package:numbers_game/game_ui/game_board.dart';
import 'package:numbers_game/game_ui/game_panels.dart';
import 'package:numbers_game/game_state_store.dart';
import 'package:numbers_game/settings_screen.dart';
import 'package:numbers_game/start_screen.dart';
import 'package:numbers_game/tutorial.dart';
import 'package:numbers_game/tutorial_progress_store.dart';

const _swapAnimationDuration = Duration(milliseconds: 380);

void main() {
  runApp(const NumbersGameApp());
}

class NumbersGameApp extends StatefulWidget {
  const NumbersGameApp({
    super.key,
    this.progressStore,
    this.gameStateStore,
  });

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
  GameMode? _activeMode;
  ModeSettings? _activeSettings;
  bool? _showTutorial;
  bool _showGame = false;
  PlayableGame? _gameToOpen;

  @override
  void initState() {
    super.initState();
    _progressStore = widget.progressStore ?? SharedPreferencesTutorialProgressStore();
    _gameStateStore = widget.gameStateStore ?? SharedPreferencesGameStateStore();
    _appState = _loadAppState();
  }

  Future<_AppState> _loadAppState() async {
    final settings = await _gameStateStore.loadSettings();
    final savedGame = await _gameStateStore.loadCurrentGame();
    _activeMode = savedGame?.mode ?? settings.selectedMode;
    _activeSettings = savedGame?.settings ?? _settingsForMode(settings, _activeMode!);
    return _AppState(
      tutorialWasHandled: await _progressStore.hasCompletedOrDismissed(),
      settings: settings,
      savedGame: savedGame,
    );
  }

  Future<void> _finishTutorial() async {
    await _progressStore.markCompletedOrDismissed();
    if (mounted) {
      setState(() => _showTutorial = false);
    }
  }

  void _startTutorial() => setState(() => _showTutorial = true);

  ModeSettings _settingsForMode(AppSettings settings, GameMode mode) => switch (mode) {
        GameMode.oneNonZero => settings.oneNonZeroSettings,
        GameMode.historicalDate => settings.historicalDateSettings,
      };

  Future<void> _saveGame(PlayableGame game) => _gameStateStore.saveCurrentGame(
        SavedGame(mode: _activeMode!, settings: _activeSettings!, game: game),
      );

  Future<PlayableGame> _startNewGame(AppSettings settings, [GameMode? mode]) async {
    await _gameStateStore.clearCurrentGame();
    _activeMode = mode ?? _activeMode ?? settings.selectedMode;
    _activeSettings = _settingsForMode(settings, _activeMode!);
    final game = switch (_activeMode!) {
      GameMode.oneNonZero => newOneNonZeroGame(_activeSettings! as OneNonZeroSettings),
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
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final appState = snapshot.data!;
          final showTutorial = _showTutorial ?? false;
          final savedGame = appState.savedGame;
          final settings = _settings ?? appState.settings;
          if (!_showGame && !showTutorial) {
            return StartScreen(
              savedGame: savedGame,
              onContinue: savedGame == null ? () {} : () => _continueGame(savedGame),
              onStartMode: (mode) => _startMode(settings, mode),
              onTutorial: _startTutorial,
              onSettings: () => unawaited(_openSettings(context, settings)),
            );
          }
          return BoardScreen(
            key: ValueKey(showTutorial),
            initialGame: showTutorial
                ? tutorialDefinition.initialGame
                : _gameToOpen ?? savedGame?.game ??
                    switch (settings.selectedMode) {
                      GameMode.oneNonZero => newOneNonZeroGame(settings.oneNonZeroSettings),
                      GameMode.historicalDate => newHistoricalDateGame(),
                    },
            tutorial: showTutorial ? tutorialDefinition : null,
            onTutorialFinished: _finishTutorial,
            onStartTutorial: showTutorial ? null : _startTutorial,
            onGameChanged: showTutorial ? null : _saveGame,
            onNewGame: showTutorial ? null : () => _startNewGame(settings),
            onOpenSettings: showTutorial ? null : () => _openSettings(context, settings),
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
  });

  final PlayableGame? initialGame;
  final TutorialDefinition? tutorial;
  final Future<void> Function()? onTutorialFinished;
  final VoidCallback? onStartTutorial;
  final Future<void> Function(PlayableGame game)? onGameChanged;
  final Future<PlayableGame> Function()? onNewGame;
  final Future<void> Function()? onOpenSettings;

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
  List<int> _visualRows = [0, 1];
  List<int> _visualColumns = [0, 1];
  bool _isAnimatingSwap = false;
  bool _isUndoing = false;
  Set<CellPosition> _undoingCells = {};
  Timer? _undoAnimationTimer;
  final List<_LineSwap?> _moveHistory = [];
  String _feedback = 'Select a source cell.';
  int _tutorialStepIndex = 0;
  bool _tutorialCompleted = false;

  Board get _board => _game.currentBoard;
  HistoricalDateGame? get _historicalGame =>
      _game is HistoricalDateGame ? _game as HistoricalDateGame : null;
  TutorialStep? get _tutorialStep => widget.tutorial == null || _tutorialCompleted
      ? null
      : widget.tutorial!.steps[_tutorialStepIndex];

  bool get _isTutorial => widget.tutorial != null;
  bool get _disableAnimations => MediaQuery.disableAnimationsOf(context);

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
    if (step?.action != TutorialAction.swapColumns || kind != BoardLineKind.column) {
      return false;
    }
    return _swapSource == null ? step!.firstLine == index : step!.secondLine == index;
  }

  @override
  void initState() {
    super.initState();
    _game = widget.initialGame ??
        OneNonZeroGame(Board([
          [1, 2],
          [3, 4],
        ]));
    _visualRows = _normalOrder(_board.rowCount);
    _visualColumns = _normalOrder(_board.columnCount);
    _feedback = _tutorialStep?.instruction ?? _feedback;
  }

  void _selectCell(CellPosition position) {
    if (_isAnimatingSwap || _isUndoing) {
      return;
    }

    final source = _arithmeticSource;
    if (source == null) {
      final step = _tutorialStep;
      if (step != null && (step.action != TutorialAction.arithmeticMove || step.source != position)) {
        _showTutorialFeedback();
        return;
      }
      setState(() {
        _arithmeticSource = position;
        _feedback = 'Source selected. Choose a target cell.';
      });
      return;
    }

    if (source == position) {
      setState(() {
        _feedback = 'Choose a different target cell.';
      });
      return;
    }

    final step = _tutorialStep;
    if (step != null && !step.matchesArithmetic(source, position)) {
      _showTutorialFeedback();
      return;
    }

    setState(() {
      _game = _game.applyArithmeticMove(source: source, target: position);
      _moveHistory.add(null);
      _arithmeticSource = null;
      _feedback = 'Move applied.';
    });
    _persistGame();
    _advanceTutorial();
  }

  void _startSwap(BoardLineTarget source) {
    if (_isAnimatingSwap || _isUndoing) {
      return;
    }
    final step = _tutorialStep;
    if (step != null &&
        (step.action != TutorialAction.swapColumns || source.kind != BoardLineKind.column ||
            source.index != step.firstLine)) {
      _showTutorialFeedback();
      return;
    }
    setState(() {
      _arithmeticSource = null;
      _swapSource = source;
      _swapTarget = null;
      _feedback = 'Drag to another ${source.kind.label} to swap.';
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
        _feedback = 'Swap cancelled.';
      });
    }
  }

  void _completeSwap(BoardLineTarget source, BoardLineTarget target) {
    if (!source.accepts(target) || _isAnimatingSwap) {
      return;
    }
    final step = _tutorialStep;
    if (step != null &&
        (source.kind != BoardLineKind.column || !step.matchesColumnSwap(source.index, target.index))) {
      _cancelSwap();
      _showTutorialFeedback();
      return;
    }

    final rows = _normalOrder(_board.rowCount);
    final columns = _normalOrder(_board.columnCount);
    if (source.kind == BoardLineKind.row) {
      _swapIndices(rows, source.index, target.index);
    } else {
      _swapIndices(columns, source.index, target.index);
    }
    final disableAnimations = _disableAnimations;

    setState(() {
      _game = source.kind == BoardLineKind.row
          ? _game.swapRows(source.index, target.index)
          : _game.swapColumns(source.index, target.index);
      _moveHistory.add(_LineSwap(source, target));
      _visualRows = disableAnimations ? _normalOrder(_board.rowCount) : rows;
      _visualColumns = disableAnimations ? _normalOrder(_board.columnCount) : columns;
      _animatedSwapSource = disableAnimations ? null : source;
      _animatedSwapTarget = disableAnimations ? null : target;
      _swapSource = null;
      _swapTarget = null;
      _isAnimatingSwap = !disableAnimations;
      _feedback = '${source.kind.label.capitalize()} swapped.';
    });
    _persistGame();
    _advanceTutorial();
    if (disableAnimations) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _visualRows = _normalOrder(_board.rowCount);
        _visualColumns = _normalOrder(_board.columnCount);
      });
      Future<void>.delayed(_swapAnimationDuration, () {
        if (mounted) {
          setState(() {
            _animatedSwapSource = null;
            _animatedSwapTarget = null;
            _isAnimatingSwap = false;
          });
        }
      });
    });
  }

  List<int> _normalOrder(int length) => List<int>.generate(length, (index) => index);

  void _swapIndices(List<int> values, int first, int second) {
    final value = values[first];
    values[first] = values[second];
    values[second] = value;
  }

  void _undo() {
    if (!_game.canUndo || _isAnimatingSwap || _isUndoing) {
      return;
    }
    final restoredGame = _game.undo();
    final undoneMove = _moveHistory.isNotEmpty ? _moveHistory.removeLast() : null;
    if (_isTutorial && _tutorialStepIndex > 0) {
      _tutorialStepIndex--;
      _tutorialCompleted = false;
    }
    if (undoneMove != null) {
      _animateUndoneSwap(restoredGame, undoneMove);
      return;
    }
    final changedCells = <CellPosition>{
      for (var row = 0; row < _board.rowCount; row++)
        for (var column = 0; column < _board.columnCount; column++)
          if (_board.valueAt(CellPosition(row, column)) !=
              restoredGame.currentBoard.valueAt(CellPosition(row, column)))
            CellPosition(row, column),
    };
    final disableAnimations = _disableAnimations;
    setState(() {
      _game = restoredGame;
      _resetInteraction();
      _isUndoing = !disableAnimations;
      _undoingCells = disableAnimations ? {} : changedCells;
      _feedback = 'Move undone.';
    });
    _persistGame();
    if (disableAnimations) {
      return;
    }
    _undoAnimationTimer = Timer(_swapAnimationDuration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _isUndoing = false;
        _undoingCells = {};
      });
    });
  }

  void _animateUndoneSwap(PlayableGame restoredGame, _LineSwap swap) {
    final rows = _normalOrder(_board.rowCount);
    final columns = _normalOrder(_board.columnCount);
    if (swap.source.kind == BoardLineKind.row) {
      _swapIndices(rows, swap.source.index, swap.target.index);
    } else {
      _swapIndices(columns, swap.source.index, swap.target.index);
    }
    final disableAnimations = _disableAnimations;

    setState(() {
      _game = restoredGame;
      _resetInteraction();
      _visualRows = disableAnimations ? _normalOrder(_board.rowCount) : rows;
      _visualColumns = disableAnimations ? _normalOrder(_board.columnCount) : columns;
      _animatedSwapSource = disableAnimations ? null : swap.source;
      _animatedSwapTarget = disableAnimations ? null : swap.target;
      _isAnimatingSwap = !disableAnimations;
      _feedback = 'Move undone.';
    });
    _persistGame();
    if (disableAnimations) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _visualRows = _normalOrder(_board.rowCount);
        _visualColumns = _normalOrder(_board.columnCount);
      });
      Future<void>.delayed(_swapAnimationDuration, () {
        if (mounted) {
          setState(() {
            _animatedSwapSource = null;
            _animatedSwapTarget = null;
            _isAnimatingSwap = false;
          });
        }
      });
    });
  }

  void _restart() {
    setState(() {
      _game = _game.restart();
      _moveHistory.clear();
      _tutorialStepIndex = 0;
      _tutorialCompleted = false;
      _resetInteraction();
      _feedback = 'Game restarted.';
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
      _moveHistory.clear();
      _tutorialStepIndex = 0;
      _tutorialCompleted = false;
      _resetInteraction();
      _feedback = 'New game started.';
    });
  }

  void _advanceTutorial() {
    if (!_isTutorial) {
      return;
    }
    setState(() {
      if (_tutorialStepIndex == widget.tutorial!.steps.length - 1) {
        _tutorialCompleted = true;
        _feedback = 'Tutorial complete.';
      } else {
        _tutorialStepIndex++;
        _feedback = widget.tutorial!.steps[_tutorialStepIndex].instruction;
      }
    });
  }

  void _showTutorialFeedback() {
    setState(() {
      _arithmeticSource = null;
      _feedback = _tutorialStep?.instruction ?? 'Follow the tutorial instruction.';
    });
  }

  void _resetInteraction() {
    _undoAnimationTimer?.cancel();
    _undoAnimationTimer = null;
    _arithmeticSource = null;
    _swapSource = null;
    _swapTarget = null;
    _animatedSwapSource = null;
    _animatedSwapTarget = null;
    _visualRows = _normalOrder(_board.rowCount);
    _visualColumns = _normalOrder(_board.columnCount);
    _isAnimatingSwap = false;
    _isUndoing = false;
    _undoingCells = {};
  }

  @override
  void dispose() {
    _undoAnimationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Numbers Game'),
        actions: [
          if (widget.onOpenSettings != null)
            IconButton(
              key: const Key('settings-button'),
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () => unawaited(widget.onOpenSettings!()),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                     Text(
                       _tutorialCompleted
                           ? 'Tutorial complete!'
                           : _tutorialStep?.instruction ??
                               'Select a source cell, then a target cell.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                     ),
                      if (_historicalGame case final HistoricalDateGame game)
                        HistoricalEventPanel(game: game),
                     const SizedBox(height: 12),
                      GameActionControls(
                       children: [
                         OutlinedButton.icon(
                          key: const Key('undo-button'),
                          onPressed: _game.canUndo && !_isAnimatingSwap && !_isUndoing
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
                          if (widget.onNewGame != null)
                            OutlinedButton.icon(
                              key: const Key('new-game-button'),
                              onPressed: _startNewGame,
                              icon: const Icon(Icons.add),
                              label: const Text('New game'),
                            ),
                         if (_isTutorial && !_tutorialCompleted)
                           OutlinedButton(
                             key: const Key('skip-tutorial-button'),
                             onPressed: widget.onTutorialFinished,
                             child: const Text('Skip tutorial'),
                           ),
                         if (!_isTutorial && widget.onStartTutorial != null)
                           OutlinedButton(
                             key: const Key('start-tutorial-button'),
                             onPressed: widget.onStartTutorial,
                             child: const Text('Tutorial'),
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
                       visualRows: _visualRows,
                       visualColumns: _visualColumns,
                       selectedCell: _arithmeticSource,
                       undoingCells: _undoingCells,
                       isAnimatingSwap: _isAnimatingSwap,
                       isUndoing: _isUndoing,
                       disableAnimations: _disableAnimations,
                       sourceLineHighlight: _swapSource ?? _animatedSwapSource,
                       targetLineHighlight: _swapTarget ?? _animatedSwapTarget,
                       historicalGame: _historicalGame,
                       isTutorialCellHighlighted: _isTutorialCellHighlighted,
                       isTutorialLineHighlighted: _isTutorialLineHighlighted,
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
                     ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}

class _LineSwap {
  const _LineSwap(this.source, this.target);

  final BoardLineTarget source;
  final BoardLineTarget target;
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
