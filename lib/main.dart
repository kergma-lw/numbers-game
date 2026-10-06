import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/one_non_zero_game.dart';
import 'package:numbers_game/game_state_store.dart';
import 'package:numbers_game/tutorial.dart';
import 'package:numbers_game/tutorial_progress_store.dart';

const _swapAnimationDuration = Duration(milliseconds: 380);
const _handleSize = 36.0;
const _cellGap = 4.0;

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
  bool? _showTutorial;

  @override
  void initState() {
    super.initState();
    _progressStore = widget.progressStore ?? SharedPreferencesTutorialProgressStore();
    _gameStateStore = widget.gameStateStore ?? SharedPreferencesGameStateStore();
    _appState = _loadAppState();
  }

  Future<_AppState> _loadAppState() async => _AppState(
        tutorialWasHandled: await _progressStore.hasCompletedOrDismissed(),
        settings: await _gameStateStore.loadSettings(),
        savedGame: await _gameStateStore.loadCurrentGame(),
      );

  Future<void> _finishTutorial() async {
    await _progressStore.markCompletedOrDismissed();
    if (mounted) {
      setState(() => _showTutorial = false);
    }
  }

  void _startTutorial() => setState(() => _showTutorial = true);

  Future<void> _saveGame(GameSettings settings, OneNonZeroGame game) =>
      _gameStateStore.saveCurrentGame(SavedGame(settings: settings, game: game));

  Future<OneNonZeroGame> _startNewGame(GameSettings settings) async {
    await _gameStateStore.clearCurrentGame();
    final game = newGame(settings);
    await _saveGame(settings, game);
    return game;
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
          final showTutorial = _showTutorial ?? !appState.tutorialWasHandled;
          final savedGame = appState.savedGame;
          final settings = savedGame?.settings ?? appState.settings;
          return BoardScreen(
            key: ValueKey(showTutorial),
            initialGame: showTutorial
                ? tutorialDefinition.initialGame
                : savedGame?.game ?? newGame(settings),
            tutorial: showTutorial ? tutorialDefinition : null,
            onTutorialFinished: _finishTutorial,
            onStartTutorial: showTutorial ? null : _startTutorial,
            onGameChanged: showTutorial ? null : (game) => _saveGame(settings, game),
            onNewGame: showTutorial ? null : () => _startNewGame(settings),
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
  });

  final OneNonZeroGame? initialGame;
  final TutorialDefinition? tutorial;
  final Future<void> Function()? onTutorialFinished;
  final VoidCallback? onStartTutorial;
  final Future<void> Function(OneNonZeroGame game)? onGameChanged;
  final Future<OneNonZeroGame> Function()? onNewGame;

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  late OneNonZeroGame _game;
  CellPosition? _arithmeticSource;
  _LineTarget? _swapSource;
  _LineTarget? _swapTarget;
  _LineTarget? _animatedSwapSource;
  _LineTarget? _animatedSwapTarget;
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
  TutorialStep? get _tutorialStep => widget.tutorial == null || _tutorialCompleted
      ? null
      : widget.tutorial!.steps[_tutorialStepIndex];

  bool get _isTutorial => widget.tutorial != null;

  bool _isTutorialCellHighlighted(CellPosition position) {
    final step = _tutorialStep;
    if (step?.action != TutorialAction.arithmeticMove) {
      return false;
    }
    return _arithmeticSource == null
        ? step!.source == position
        : step!.target == position;
  }

  bool _isTutorialLineHighlighted(_LineKind kind, int index) {
    final step = _tutorialStep;
    if (step?.action != TutorialAction.swapColumns || kind != _LineKind.column) {
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

  void _startSwap(_LineTarget source) {
    if (_isAnimatingSwap || _isUndoing) {
      return;
    }
    final step = _tutorialStep;
    if (step != null &&
        (step.action != TutorialAction.swapColumns || source.kind != _LineKind.column ||
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

  void _hoverSwapTarget(_LineTarget target) {
    if (_swapSource?.accepts(target) ?? false) {
      setState(() => _swapTarget = target);
    }
  }

  void _leaveSwapTarget(_LineTarget target) {
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

  void _completeSwap(_LineTarget source, _LineTarget target) {
    if (!source.accepts(target) || _isAnimatingSwap) {
      return;
    }
    final step = _tutorialStep;
    if (step != null &&
        (source.kind != _LineKind.column || !step.matchesColumnSwap(source.index, target.index))) {
      _cancelSwap();
      _showTutorialFeedback();
      return;
    }

    final rows = _normalOrder(_board.rowCount);
    final columns = _normalOrder(_board.columnCount);
    if (source.kind == _LineKind.row) {
      _swapIndices(rows, source.index, target.index);
    } else {
      _swapIndices(columns, source.index, target.index);
    }

    setState(() {
      _game = source.kind == _LineKind.row
          ? _game.swapRows(source.index, target.index)
          : _game.swapColumns(source.index, target.index);
      _moveHistory.add(_LineSwap(source, target));
      _visualRows = rows;
      _visualColumns = columns;
      _animatedSwapSource = source;
      _animatedSwapTarget = target;
      _swapSource = null;
      _swapTarget = null;
      _isAnimatingSwap = true;
      _feedback = '${source.kind.label.capitalize()} swapped.';
    });
    _persistGame();
    _advanceTutorial();

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

  bool _isSwapLineActive(_LineKind kind, int index) =>
      (_swapSource?.kind == kind && _swapSource?.index == index) ||
      (_swapTarget?.kind == kind && _swapTarget?.index == index);

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
    setState(() {
      _game = restoredGame;
      _resetInteraction();
      _isUndoing = true;
      _undoingCells = changedCells;
      _feedback = 'Move undone.';
    });
    _persistGame();
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

  void _animateUndoneSwap(OneNonZeroGame restoredGame, _LineSwap swap) {
    final rows = _normalOrder(_board.rowCount);
    final columns = _normalOrder(_board.columnCount);
    if (swap.source.kind == _LineKind.row) {
      _swapIndices(rows, swap.source.index, swap.target.index);
    } else {
      _swapIndices(columns, swap.source.index, swap.target.index);
    }

    setState(() {
      _game = restoredGame;
      _resetInteraction();
      _visualRows = rows;
      _visualColumns = columns;
      _animatedSwapSource = swap.source;
      _animatedSwapTarget = swap.target;
      _isAnimatingSwap = true;
      _feedback = 'Move undone.';
    });
    _persistGame();

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
    final swapIndicator = _swapTarget?.kind == _LineKind.row ? '⇅' : '⇄';
    return Scaffold(
      appBar: AppBar(title: const Text('Numbers Game')),
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
                    const SizedBox(height: 12),
                     Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
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
                    Text(
                      'Moves: ${_game.moveCount}',
                      key: const Key('move-count'),
                      textAlign: TextAlign.center,
                    ),
                    if (_game.isWon)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'You won!',
                          key: Key('victory-message'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (_game.isLost)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'You lost!',
                          key: Key('loss-message'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                       builder: (context, constraints) {
                         final boardSize = math.min(
                           constraints.maxWidth - 2 * _handleSize,
                           300.0,
                         );
                         final cellWidth =
                             (boardSize - _cellGap * (_board.columnCount - 1)) /
                                 _board.columnCount;
                         final cellHeight =
                             (boardSize - _cellGap * (_board.rowCount - 1)) /
                                 _board.rowCount;
                         final colorScheme = Theme.of(context).colorScheme;
                         final sourceHighlight =
                             _swapSource ?? _animatedSwapSource;
                         final targetHighlight =
                             _swapTarget ?? _animatedSwapTarget;

                          Widget lineHighlight(
                           _LineTarget target, {
                           required bool isDropTarget,
                         }) {
                           final isRow = target.kind == _LineKind.row;
                           return Positioned(
                             left: isRow
                                 ? _handleSize
                                 : _handleSize +
                                     target.index * (cellWidth + _cellGap),
                             top: isRow
                                 ? _handleSize +
                                     target.index * (cellHeight + _cellGap)
                                 : _handleSize,
                             width: isRow ? boardSize : cellWidth,
                             height: isRow ? cellHeight : boardSize,
                             child: IgnorePointer(
                                child: AnimatedContainer(
                                  key: Key(
                                    isDropTarget
                                        ? 'swap-target-highlight'
                                        : 'swap-source-highlight',
                                  ),
                                  duration: const Duration(milliseconds: 120),
                                 decoration: BoxDecoration(
                                   color: isDropTarget
                                       ? colorScheme.secondaryContainer.withValues(
                                           alpha: 0.55,
                                         )
                                       : colorScheme.primaryContainer.withValues(
                                           alpha: 0.35,
                                         ),
                                 ),
                               ),
                             ),
                           );
                          }

                          Widget tutorialArrow({
                            required Key key,
                            required double left,
                            required double top,
                          }) => Positioned(
                            left: left,
                            top: top,
                            width: 36,
                            height: 36,
                            child: IgnorePointer(
                              child: Icon(
                                Icons.arrow_downward,
                                key: key,
                                size: 36,
                                color: colorScheme.tertiary,
                              ),
                            ),
                          );

                         return SizedBox(
                          width: boardSize + 2 * _handleSize,
                          height: boardSize + 2 * _handleSize,
                          child: Stack(
                            children: [
                              for (var column = 0;
                                  column < _board.columnCount;
                                  column++) ...[
                                _positionedHandle(
                                 target: _LineTarget(_LineKind.column, column),
                                 side: _HandleSide.top,
                                 left: _handleSize + column * (cellWidth + _cellGap),
                                  top: 0,
                                  width: cellWidth,
                                  height: _handleSize,
                                ),
                                _positionedHandle(
                                 target: _LineTarget(_LineKind.column, column),
                                 side: _HandleSide.bottom,
                                 left: _handleSize + column * (cellWidth + _cellGap),
                                  top: _handleSize + boardSize,
                                  width: cellWidth,
                                  height: _handleSize,
                                ),
                              ],
                               for (var row = 0; row < _board.rowCount; row++) ...[
                                _positionedHandle(
                                 target: _LineTarget(_LineKind.row, row),
                                 side: _HandleSide.left,
                                 left: 0,
                                 top: _handleSize + row * (cellHeight + _cellGap),
                                  width: _handleSize,
                                  height: cellHeight,
                                ),
                                _positionedHandle(
                                  target: _LineTarget(_LineKind.row, row),
                                 side: _HandleSide.right,
                                 left: _handleSize + boardSize,
                                 top: _handleSize + row * (cellHeight + _cellGap),
                                  width: _handleSize,
                                  height: cellHeight,
                                 ),
                               ],
                               if (sourceHighlight case final _LineTarget source)
                                 lineHighlight(source, isDropTarget: false),
                               if (targetHighlight case final _LineTarget target)
                                 lineHighlight(target, isDropTarget: true),
                                for (var row = 0; row < _board.rowCount; row++)
                                for (var column = 0;
                                    column < _board.columnCount;
                                    column++)
                                  AnimatedPositioned(
                                     duration: _swapAnimationDuration,
                                     curve: Curves.easeInOutCubicEmphasized,
                                     left: _handleSize +
                                         _visualColumns[column] *
                                             (cellWidth + _cellGap),
                                     top: _handleSize +
                                         _visualRows[row] *
                                             (cellHeight + _cellGap),
                                    width: cellWidth,
                                    height: cellHeight,
                                     child: _BoardCell(
                                      position: CellPosition(row, column),
                                      value: _board.valueAt(
                                        CellPosition(row, column),
                                      ),
                                         selected: _arithmeticSource ==
                                             CellPosition(row, column),
                                        undoing: _undoingCells.contains(
                                          CellPosition(row, column),
                                        ),
                                        onPressed: _selectCell,
                                    ),
                                     ),
                              for (var row = 0; row < _board.rowCount; row++)
                                for (var column = 0;
                                    column < _board.columnCount;
                                    column++)
                                  if (_isTutorialCellHighlighted(
                                    CellPosition(row, column),
                                  ))
                                    tutorialArrow(
                                      key: Key('tutorial-arrow-cell-$row-$column'),
                                      left: _handleSize +
                                          column * (cellWidth + _cellGap) +
                                          (cellWidth - 36) / 2,
                                      top: _handleSize +
                                          row * (cellHeight + _cellGap) -
                                          12,
                                    ),
                              for (var column = 0;
                                  column < _board.columnCount;
                                  column++)
                                if (_isTutorialLineHighlighted(
                                  _LineKind.column,
                                  column,
                                ))
                                  tutorialArrow(
                                    key: Key('tutorial-arrow-column-$column'),
                                    left: _handleSize +
                                        column * (cellWidth + _cellGap) +
                                        (cellWidth - 36) / 2,
                                    top: 0,
                                  ),
                              if (_swapTarget != null)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: Center(
                                      child: Text(
                                        swapIndicator,
                                        key: Key('swap-indicator'),
                                        style: TextStyle(fontSize: 36),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _feedback,
                        key: const Key('feedback'),
                        textAlign: TextAlign.center,
                      ),
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

  Widget _positionedHandle({
    required _LineTarget target,
    required _HandleSide side,
    required double left,
    required double top,
    required double width,
    required double height,
  }) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: _LineHandle(
        target: target,
        side: side,
        isActive: _isSwapLineActive(target.kind, target.index),
        enabled: !_isAnimatingSwap && !_isUndoing,
        onDragStarted: _startSwap,
        onHover: _hoverSwapTarget,
        onLeave: _leaveSwapTarget,
        onAccept: _completeSwap,
        onDragCancelled: _cancelSwap,
      ),
    );
  }
}

class _BoardCell extends StatelessWidget {
  const _BoardCell({
    required this.position,
    required this.value,
    required this.selected,
    required this.undoing,
    required this.onPressed,
  });

  final CellPosition position;
  final int value;
  final bool selected;
  final bool undoing;
  final ValueChanged<CellPosition> onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Cell ${position.row + 1}, ${position.column + 1}: $value',
      child: AnimatedScale(
        scale: undoing ? 1.08 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: OutlinedButton(
          key: Key('cell-${position.row}-${position.column}'),
          style: OutlinedButton.styleFrom(
            backgroundColor: selected
                ? colorScheme.primaryContainer
                : undoing
                    ? colorScheme.tertiaryContainer
                    : null,
            padding: const EdgeInsets.all(8),
          ),
          onPressed: () => onPressed(position),
          child: Text('$value', style: Theme.of(context).textTheme.headlineMedium),
        ),
      ),
    );
  }
}

class _LineHandle extends StatefulWidget {
  const _LineHandle({
    required this.target,
    required this.side,
    required this.isActive,
    required this.enabled,
    required this.onDragStarted,
    required this.onHover,
    required this.onLeave,
    required this.onAccept,
    required this.onDragCancelled,
  });

  final _LineTarget target;
  final _HandleSide side;
  final bool isActive;
  final bool enabled;
  final ValueChanged<_LineTarget> onDragStarted;
  final ValueChanged<_LineTarget> onHover;
  final ValueChanged<_LineTarget> onLeave;
  final void Function(_LineTarget, _LineTarget) onAccept;
  final VoidCallback onDragCancelled;

  @override
  State<_LineHandle> createState() => _LineHandleState();
}

class _LineHandleState extends State<_LineHandle> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<_LineTarget>(
      onWillAcceptWithDetails: (details) {
        if (!details.data.accepts(widget.target)) {
          return false;
        }
        widget.onHover(widget.target);
        return true;
      },
      onLeave: (_) => widget.onLeave(widget.target),
      onAcceptWithDetails: (details) => widget.onAccept(details.data, widget.target),
      builder: (context, candidateData, rejectedData) {
        return MouseRegion(
          cursor: widget.enabled ? SystemMouseCursors.grab : MouseCursor.defer,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Draggable<_LineTarget>(
            data: widget.target,
            maxSimultaneousDrags: widget.enabled ? 1 : 0,
            onDragStarted: () => widget.onDragStarted(widget.target),
            onDragEnd: (_) => widget.onDragCancelled(),
            feedback: Material(
              color: Colors.transparent,
              child: _handleIcon(context, active: true),
            ),
            childWhenDragging: Opacity(
              opacity: 0.35,
              child: _handleIcon(context, active: widget.isActive),
            ),
            child: _handleIcon(
              context,
              active: widget.isActive || candidateData.isNotEmpty,
            ),
          ),
        );
      },
    );
  }

  Widget _handleIcon(BuildContext context, {required bool active}) {
    final colorScheme = Theme.of(context).colorScheme;
    final highlighted = active || _isHovered;
    final backgroundColor = active
        ? colorScheme.secondaryContainer
        : _isHovered
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.55)
            : Colors.transparent;
    return Semantics(
      label:
          '${widget.side.label} handle for ${widget.target.kind.label} ${widget.target.index + 1}',
      child: AnimatedContainer(
        key: Key(
          '${widget.target.kind.name}-handle-${widget.side.name}-${widget.target.index}',
        ),
        duration: const Duration(milliseconds: 120),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          widget.target.kind == _LineKind.row
              ? Icons.drag_indicator
              : Icons.drag_handle,
          size: 16,
          color: highlighted ? colorScheme.onSurfaceVariant : colorScheme.outline,
        ),
      ),
    );
  }
}

enum _LineKind {
  row('row'),
  column('column');

  const _LineKind(this.label);

  final String label;
}

enum _HandleSide {
  top('top'),
  bottom('bottom'),
  left('left'),
  right('right');

  const _HandleSide(this.label);

  final String label;
}

class _LineTarget {
  const _LineTarget(this.kind, this.index);

  final _LineKind kind;
  final int index;

  bool accepts(_LineTarget other) => kind == other.kind && index != other.index;

  @override
  bool operator ==(Object other) =>
      other is _LineTarget && kind == other.kind && index == other.index;

  @override
  int get hashCode => Object.hash(kind, index);
}

class _LineSwap {
  const _LineSwap(this.source, this.target);

  final _LineTarget source;
  final _LineTarget target;
}

class _AppState {
  const _AppState({
    required this.tutorialWasHandled,
    required this.settings,
    required this.savedGame,
  });

  final bool tutorialWasHandled;
  final GameSettings settings;
  final SavedGame? savedGame;
}

extension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
