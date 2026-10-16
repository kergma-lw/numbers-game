import 'package:flutter/material.dart';
import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/historical_date_game.dart';

const _handleSize = 36.0;
const _cellGap = 4.0;

enum BoardLineKind {
  row('row'),
  column('column');

  const BoardLineKind(this.label);

  final String label;
}

enum BoardHandleSide {
  top('top'),
  bottom('bottom'),
  left('left'),
  right('right');

  const BoardHandleSide(this.label);

  final String label;
}

class BoardLineTarget {
  const BoardLineTarget(this.kind, this.index);

  final BoardLineKind kind;
  final int index;

  bool accepts(BoardLineTarget other) => kind == other.kind && index != other.index;

  @override
  bool operator ==(Object other) =>
      other is BoardLineTarget && kind == other.kind && index == other.index;

  @override
  int get hashCode => Object.hash(kind, index);
}

class GameBoard extends StatelessWidget {
  const GameBoard({
    super.key,
    required this.board,
    required this.visualRows,
    required this.visualColumns,
    required this.selectedCell,
    required this.undoingCells,
    required this.isAnimatingSwap,
    required this.isUndoing,
    required this.onCellPressed,
    required this.onDragStarted,
    required this.onHover,
    required this.onLeave,
    required this.onAccept,
    required this.onDragCancelled,
    this.sourceLineHighlight,
    this.targetLineHighlight,
    this.historicalGame,
    this.isTutorialCellHighlighted,
    this.isTutorialLineHighlighted,
  });

  final Board board;
  final List<int> visualRows;
  final List<int> visualColumns;
  final CellPosition? selectedCell;
  final Set<CellPosition> undoingCells;
  final bool isAnimatingSwap;
  final bool isUndoing;
  final ValueChanged<CellPosition> onCellPressed;
  final ValueChanged<BoardLineTarget> onDragStarted;
  final ValueChanged<BoardLineTarget> onHover;
  final ValueChanged<BoardLineTarget> onLeave;
  final void Function(BoardLineTarget, BoardLineTarget) onAccept;
  final VoidCallback onDragCancelled;
  final BoardLineTarget? sourceLineHighlight;
  final BoardLineTarget? targetLineHighlight;
  final HistoricalDateGame? historicalGame;
  final bool Function(CellPosition)? isTutorialCellHighlighted;
  final bool Function(BoardLineKind, int)? isTutorialLineHighlighted;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardWidth = constraints.maxWidth - 2 * _handleSize;
        final cellWidth = (boardWidth - _cellGap * (board.columnCount - 1)) /
            board.columnCount;
        final cellHeight = cellWidth;
        final boardHeight =
            cellHeight * board.rowCount + _cellGap * (board.rowCount - 1);
        final colorScheme = Theme.of(context).colorScheme;

        Widget lineHighlight(
          BoardLineTarget target, {
          required bool isDropTarget,
        }) {
          final isRow = target.kind == BoardLineKind.row;
          return Positioned(
            left: isRow
                ? _handleSize
                : _handleSize + target.index * (cellWidth + _cellGap),
            top: isRow
                ? _handleSize + target.index * (cellHeight + _cellGap)
                : _handleSize,
            width: isRow ? boardWidth : cellWidth,
            height: isRow ? cellHeight : boardHeight,
            child: IgnorePointer(
              child: AnimatedContainer(
                key: Key(isDropTarget
                    ? 'swap-target-highlight'
                    : 'swap-source-highlight'),
                duration: const Duration(milliseconds: 120),
                decoration: BoxDecoration(
                  color: isDropTarget
                      ? colorScheme.secondaryContainer.withValues(alpha: 0.55)
                      : colorScheme.primaryContainer.withValues(alpha: 0.35),
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
          width: boardWidth + 2 * _handleSize,
          height: boardHeight + 2 * _handleSize,
          child: Stack(
            children: [
              for (var column = 0; column < board.columnCount; column++) ...[
                _positionedHandle(
                  target: BoardLineTarget(BoardLineKind.column, column),
                  side: BoardHandleSide.top,
                  left: _handleSize + column * (cellWidth + _cellGap),
                  top: 0,
                  width: cellWidth,
                  height: _handleSize,
                ),
                _positionedHandle(
                  target: BoardLineTarget(BoardLineKind.column, column),
                  side: BoardHandleSide.bottom,
                  left: _handleSize + column * (cellWidth + _cellGap),
                  top: _handleSize + boardHeight,
                  width: cellWidth,
                  height: _handleSize,
                ),
              ],
              for (var row = 0; row < board.rowCount; row++) ...[
                _positionedHandle(
                  target: BoardLineTarget(BoardLineKind.row, row),
                  side: BoardHandleSide.left,
                  left: 0,
                  top: _handleSize + row * (cellHeight + _cellGap),
                  width: _handleSize,
                  height: cellHeight,
                ),
                _positionedHandle(
                  target: BoardLineTarget(BoardLineKind.row, row),
                  side: BoardHandleSide.right,
                  left: _handleSize + boardWidth,
                  top: _handleSize + row * (cellHeight + _cellGap),
                  width: _handleSize,
                  height: cellHeight,
                ),
              ],
              if (sourceLineHighlight case final source?)
                lineHighlight(source, isDropTarget: false),
              if (targetLineHighlight case final target?)
                lineHighlight(target, isDropTarget: true),
              if (historicalGame case final game?)
                DateFrameDecoration(
                  game: game,
                  cellWidth: cellWidth,
                  cellHeight: cellHeight,
                ),
              for (var row = 0; row < board.rowCount; row++)
                for (var column = 0; column < board.columnCount; column++)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeInOutCubicEmphasized,
                    left: _handleSize +
                        visualColumns[column] * (cellWidth + _cellGap),
                    top: _handleSize +
                        visualRows[row] * (cellHeight + _cellGap),
                    width: cellWidth,
                    height: cellHeight,
                    child: GameCell(
                      position: CellPosition(row, column),
                      value: board.valueAt(CellPosition(row, column)),
                      selected: selectedCell == CellPosition(row, column),
                      undoing: undoingCells.contains(CellPosition(row, column)),
                      onPressed: onCellPressed,
                    ),
                  ),
              for (var row = 0; row < board.rowCount; row++)
                for (var column = 0; column < board.columnCount; column++)
                  if (isTutorialCellHighlighted?.call(CellPosition(row, column)) ?? false)
                    tutorialArrow(
                      key: Key('tutorial-arrow-cell-$row-$column'),
                      left: _handleSize +
                          column * (cellWidth + _cellGap) +
                          (cellWidth - 36) / 2,
                      top: _handleSize + row * (cellHeight + _cellGap) - 12,
                    ),
              for (var column = 0; column < board.columnCount; column++)
                if (isTutorialLineHighlighted?.call(BoardLineKind.column, column) ?? false)
                  tutorialArrow(
                    key: Key('tutorial-arrow-column-$column'),
                    left: _handleSize +
                        column * (cellWidth + _cellGap) +
                        (cellWidth - 36) / 2,
                    top: 0,
                  ),
              if (targetLineHighlight != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Text(
                        targetLineHighlight!.kind == BoardLineKind.row ? '⇅' : '⇄',
                        key: const Key('swap-indicator'),
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _positionedHandle({
    required BoardLineTarget target,
    required BoardHandleSide side,
    required double left,
    required double top,
    required double width,
    required double height,
  }) => Positioned(
        left: left,
        top: top,
        width: width,
        height: height,
        child: EdgeSwapHandle(
          target: target,
          side: side,
          isActive: sourceLineHighlight == target || targetLineHighlight == target,
          enabled: !isAnimatingSwap && !isUndoing,
          onDragStarted: onDragStarted,
          onHover: onHover,
          onLeave: onLeave,
          onAccept: onAccept,
          onDragCancelled: onDragCancelled,
        ),
      );
}

class GameCell extends StatelessWidget {
  const GameCell({
    super.key,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fontSize = (constraints.biggest.shortestSide * 0.55)
                  .clamp(12.0, 32.0)
                  .toDouble();
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$value',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: fontSize,
                      ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class EdgeSwapHandle extends StatefulWidget {
  const EdgeSwapHandle({
    super.key,
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

  final BoardLineTarget target;
  final BoardHandleSide side;
  final bool isActive;
  final bool enabled;
  final ValueChanged<BoardLineTarget> onDragStarted;
  final ValueChanged<BoardLineTarget> onHover;
  final ValueChanged<BoardLineTarget> onLeave;
  final void Function(BoardLineTarget, BoardLineTarget) onAccept;
  final VoidCallback onDragCancelled;

  @override
  State<EdgeSwapHandle> createState() => _EdgeSwapHandleState();
}

class _EdgeSwapHandleState extends State<EdgeSwapHandle> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) => DragTarget<BoardLineTarget>(
        onWillAcceptWithDetails: (details) {
          if (!details.data.accepts(widget.target)) {
            return false;
          }
          widget.onHover(widget.target);
          return true;
        },
        onLeave: (_) => widget.onLeave(widget.target),
        onAcceptWithDetails: (details) => widget.onAccept(details.data, widget.target),
        builder: (context, candidateData, rejectedData) => MouseRegion(
          cursor: widget.enabled ? SystemMouseCursors.grab : MouseCursor.defer,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Draggable<BoardLineTarget>(
            data: widget.target,
            maxSimultaneousDrags: widget.enabled ? 1 : 0,
            onDragStarted: () => widget.onDragStarted(widget.target),
            onDragEnd: (_) => widget.onDragCancelled(),
            feedback: Material(color: Colors.transparent, child: _icon(context, active: true)),
            childWhenDragging: Opacity(
              opacity: 0.35,
              child: _icon(context, active: widget.isActive),
            ),
            child: _icon(context, active: widget.isActive || candidateData.isNotEmpty),
          ),
        ),
      );

  Widget _icon(BuildContext context, {required bool active}) {
    final colorScheme = Theme.of(context).colorScheme;
    final highlighted = active || _isHovered;
    final backgroundColor = active
        ? colorScheme.secondaryContainer
        : _isHovered
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.55)
            : Colors.transparent;
    return Semantics(
      label: '${widget.side.label} handle for ${widget.target.kind.label} ${widget.target.index + 1}',
      child: AnimatedContainer(
        key: Key('${widget.target.kind.name}-handle-${widget.side.name}-${widget.target.index}'),
        duration: const Duration(milliseconds: 120),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          widget.target.kind == BoardLineKind.row
              ? Icons.drag_indicator
              : Icons.drag_handle,
          size: 16,
          color: highlighted ? colorScheme.onSurfaceVariant : colorScheme.outline,
        ),
      ),
    );
  }
}

class DateFrameDecoration extends StatelessWidget {
  const DateFrameDecoration({
    super.key,
    required this.game,
    required this.cellWidth,
    required this.cellHeight,
  });

  final HistoricalDateGame game;
  final double cellWidth;
  final double cellHeight;

  @override
  Widget build(BuildContext context) {
    final width = cellWidth * 3 + _cellGap * 2;
    return Positioned(
      key: const Key('historical-date-frame'),
      left: _handleSize + game.frame.column * (cellWidth + _cellGap),
      top: _handleSize + game.frame.row * (cellHeight + _cellGap),
      width: width,
      height: cellHeight,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.tertiary, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              for (var index = 1; index < 3; index++)
                Positioned(
                  left: index * cellWidth + (index - 0.5) * _cellGap - 4,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Text(
                      game.format.separator,
                      key: Key('historical-date-separator-$index'),
                      style: Theme.of(context).textTheme.titleLarge,
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
