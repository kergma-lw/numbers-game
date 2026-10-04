import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/one_non_zero_game.dart';

const _swapAnimationDuration = Duration(milliseconds: 380);
const _handleSize = 36.0;
const _cellGap = 4.0;

void main() {
  runApp(const NumbersGameApp());
}

class NumbersGameApp extends StatelessWidget {
  const NumbersGameApp({super.key, this.initialGame});

  final OneNonZeroGame? initialGame;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Numbers Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: BoardScreen(initialGame: initialGame),
    );
  }
}

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key, this.initialGame});

  final OneNonZeroGame? initialGame;

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

  Board get _board => _game.currentBoard;

  @override
  void initState() {
    super.initState();
    _game = widget.initialGame ??
        OneNonZeroGame(Board([
          [1, 2],
          [3, 4],
        ]));
  }

  void _selectCell(CellPosition position) {
    if (_isAnimatingSwap || _isUndoing) {
      return;
    }

    final source = _arithmeticSource;
    if (source == null) {
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

    setState(() {
      _game = _game.applyArithmeticMove(source: source, target: position);
      _moveHistory.add(null);
      _arithmeticSource = null;
      _feedback = 'Move applied.';
    });
  }

  void _startSwap(_LineTarget source) {
    if (_isAnimatingSwap || _isUndoing) {
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
      _resetInteraction();
      _feedback = 'Game restarted.';
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
                      ],
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

extension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
