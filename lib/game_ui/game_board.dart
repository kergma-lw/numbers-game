import 'package:flutter/material.dart';
import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/historical_date_game.dart';

const _handleSize = 28.0;
const _cellGap = 8.0;

class BoardVisualConfig {
  const BoardVisualConfig({
    required this.boardInset,
    required this.handleGap,
    required this.decorated,
    this.boardGradient,
    this.boardBorder,
    this.boardRadius,
    this.idleCellGradient,
    this.sourceCellGradient,
    this.targetCellGradient,
    this.idleCellBorder,
    this.sourceCellBorder,
    this.targetCellBorder,
    this.handleBackground,
    this.handleBorder,
    this.handleColor,
    this.sourceHandleColor,
    this.targetHandleColor,
  });

  static const standard = BoardVisualConfig(
    boardInset: 0,
    handleGap: 0,
    decorated: false,
  );

  static const oneNonZero = BoardVisualConfig(
    boardInset: 20,
    handleGap: 7,
    decorated: true,
    boardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromRGBO(24, 62, 78, .86),
        Color.fromRGBO(17, 42, 61, .90),
      ],
    ),
    boardBorder: Color.fromRGBO(116, 215, 196, .34),
    boardRadius: BorderRadius.only(
      topLeft: Radius.circular(25),
      topRight: Radius.circular(17),
      bottomLeft: Radius.circular(22),
      bottomRight: Radius.circular(18),
    ),
    idleCellGradient: LinearGradient(
      colors: [
        Color.fromRGBO(54, 100, 113, .92),
        Color.fromRGBO(28, 65, 82, .96),
      ],
    ),
    sourceCellGradient: LinearGradient(
      colors: [
        Color.fromRGBO(90, 168, 158, .95),
        Color.fromRGBO(35, 103, 110, .98),
      ],
    ),
    targetCellGradient: LinearGradient(
      colors: [
        Color.fromRGBO(163, 125, 72, .92),
        Color.fromRGBO(93, 69, 67, .98),
      ],
    ),
    idleCellBorder: Color.fromRGBO(116, 215, 196, .17),
    sourceCellBorder: Color(0xffb9fff1),
    targetCellBorder: Color(0xffffe0a1),
    handleBackground: Color.fromRGBO(35, 86, 99, .40),
    handleBorder: Color.fromRGBO(116, 215, 196, .23),
    handleColor: Color.fromRGBO(166, 238, 224, .72),
    sourceHandleColor: Color(0xff102f38),
    targetHandleColor: Color(0xfffff2d6),
  );

  static const historicalDate = BoardVisualConfig(
    boardInset: 20,
    handleGap: 7,
    decorated: true,
    boardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromRGBO(69, 46, 76, .90),
        Color.fromRGBO(44, 37, 65, .94),
      ],
    ),
    boardBorder: Color.fromRGBO(236, 118, 93, .44),
    boardRadius: BorderRadius.all(Radius.circular(24)),
    idleCellGradient: LinearGradient(
      colors: [
        Color.fromRGBO(103, 70, 101, .93),
        Color.fromRGBO(63, 48, 82, .97),
      ],
    ),
    sourceCellGradient: LinearGradient(
      colors: [
        Color.fromRGBO(218, 122, 109, .97),
        Color.fromRGBO(123, 69, 98, .99),
      ],
    ),
    targetCellGradient: LinearGradient(
      colors: [
        Color.fromRGBO(163, 125, 72, .92),
        Color.fromRGBO(93, 69, 67, .98),
      ],
    ),
    idleCellBorder: Color.fromRGBO(239, 168, 145, .20),
    sourceCellBorder: Color(0xffffe3b6),
    targetCellBorder: Color(0xffffe0a1),
    handleBackground: Color.fromRGBO(95, 59, 91, .46),
    handleBorder: Color.fromRGBO(236, 118, 93, .28),
    handleColor: Color.fromRGBO(255, 191, 162, .80),
    sourceHandleColor: Color(0xff44283c),
    targetHandleColor: Color(0xfffff2d6),
  );

  static const tutorial = BoardVisualConfig(
    boardInset: 20,
    handleGap: 7,
    decorated: true,
    boardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromRGBO(46, 56, 77, .92),
        Color.fromRGBO(30, 37, 53, .95),
      ],
    ),
    boardBorder: Color.fromRGBO(205, 215, 239, .30),
    boardRadius: BorderRadius.all(Radius.circular(24)),
    idleCellGradient: LinearGradient(
      colors: [
        Color.fromRGBO(81, 94, 124, .94),
        Color.fromRGBO(49, 60, 84, .98),
      ],
    ),
    sourceCellGradient: LinearGradient(
      colors: [
        Color.fromRGBO(156, 174, 210, .98),
        Color.fromRGBO(82, 103, 139, .99),
      ],
    ),
    targetCellGradient: LinearGradient(
      colors: [
        Color.fromRGBO(111, 128, 160, .98),
        Color.fromRGBO(61, 77, 105, .98),
      ],
    ),
    idleCellBorder: Color.fromRGBO(215, 224, 244, .18),
    sourceCellBorder: Color(0xfff1f4ff),
    targetCellBorder: Color(0xffe4ebff),
    handleBackground: Color.fromRGBO(56, 66, 91, .50),
    handleBorder: Color.fromRGBO(205, 215, 239, .25),
    handleColor: Color.fromRGBO(220, 227, 247, .78),
    sourceHandleColor: Color(0xff30384d),
    targetHandleColor: Color(0xffffffff),
  );

  final double boardInset;
  final double handleGap;
  final bool decorated;
  final Gradient? boardGradient;
  final Color? boardBorder;
  final BorderRadius? boardRadius;
  final Gradient? idleCellGradient;
  final Gradient? sourceCellGradient;
  final Gradient? targetCellGradient;
  final Color? idleCellBorder;
  final Color? sourceCellBorder;
  final Color? targetCellBorder;
  final Color? handleBackground;
  final Color? handleBorder;
  final Color? handleColor;
  final Color? sourceHandleColor;
  final Color? targetHandleColor;
}

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

  bool accepts(BoardLineTarget other) =>
      kind == other.kind && index != other.index;

  @override
  bool operator ==(Object other) =>
      other is BoardLineTarget && kind == other.kind && index == other.index;

  @override
  int get hashCode => Object.hash(kind, index);
}

class BoardSwapAfterimage {
  const BoardSwapAfterimage({
    required this.id,
    required this.position,
    required this.value,
    required this.dragSource,
    required this.dragTarget,
  });

  final int id;
  final CellPosition position;
  final int value;
  final bool dragSource;
  final bool dragTarget;
}

BorderRadius _cellBorderRadius(CellPosition position) => BorderRadius.only(
  topLeft: Radius.circular(position.row.isEven ? 14 : 20),
  topRight: Radius.circular(position.column.isEven ? 20 : 14),
  bottomLeft: Radius.circular(position.column.isEven ? 14 : 20),
  bottomRight: Radius.circular(position.row.isEven ? 20 : 14),
);

class GameBoard extends StatelessWidget {
  const GameBoard({
    super.key,
    required this.board,
    required this.selectedCell,
    required this.swapAfterimages,
    required this.isAnimatingSwap,
    this.swapSource,
    this.swapTarget,
    this.swapAnimationId = 0,
    required this.disableAnimations,
    this.resolvingCell,
    this.resolvingEquation,
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
    this.visualConfig = BoardVisualConfig.standard,
  });

  final Board board;
  final CellPosition? selectedCell;
  final List<BoardSwapAfterimage> swapAfterimages;
  final bool isAnimatingSwap;
  final BoardLineTarget? swapSource;
  final BoardLineTarget? swapTarget;
  final int swapAnimationId;
  final bool disableAnimations;
  final CellPosition? resolvingCell;
  final String? resolvingEquation;
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
  final BoardVisualConfig visualConfig;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardInset = visualConfig.boardInset;
        final handleGap = visualConfig.handleGap;
        final boardWidth =
            constraints.maxWidth -
            2 * _handleSize -
            2 * handleGap -
            2 * boardInset;
        final cellWidth =
            (boardWidth - _cellGap * (board.columnCount - 1)) /
            board.columnCount;
        final cellHeight = cellWidth;
        final boardHeight =
            cellHeight * board.rowCount + _cellGap * (board.rowCount - 1);
        final frameWidth = boardWidth + 2 * boardInset;
        final frameHeight = boardHeight + 2 * boardInset;
        final handleCellWidth =
            (frameWidth - _cellGap * (board.columnCount - 1)) /
            board.columnCount;
        final handleCellHeight =
            (frameHeight - _cellGap * (board.rowCount - 1)) / board.rowCount;
        final colorScheme = Theme.of(context).colorScheme;
        final dimmingSource =
            sourceLineHighlight ?? (isAnimatingSwap ? swapSource : null);
        final dimmingTarget =
            targetLineHighlight ?? (isAnimatingSwap ? swapTarget : null);
        bool inLine(BoardLineTarget line, int row, int column) =>
            line.kind == BoardLineKind.row
            ? row == line.index
            : column == line.index;
        bool fromSwapSource(int row, int column) {
          final source = swapSource;
          final target = swapTarget;
          if (!isAnimatingSwap ||
              source == null ||
              target == null ||
              !inLine(source, row, column) && !inLine(target, row, column))
            return false;
          return inLine(target, row, column);
        }

        bool fromSwapTarget(int row, int column) {
          final source = swapSource;
          final target = swapTarget;
          if (!isAnimatingSwap ||
              source == null ||
              target == null ||
              !inLine(source, row, column) && !inLine(target, row, column))
            return false;
          return inLine(source, row, column);
        }

        Offset swapOffsetFor(int row, int column) {
          final source = swapSource;
          final target = swapTarget;
          if (!isAnimatingSwap || source == null || target == null)
            return Offset.zero;
          if (source.kind == BoardLineKind.row &&
              (row == source.index || row == target.index)) {
            final oldRow = row == source.index ? target.index : source.index;
            return Offset(0, (oldRow - row) * (cellHeight + _cellGap));
          }
          if (source.kind == BoardLineKind.column &&
              (column == source.index || column == target.index)) {
            final oldColumn = column == source.index
                ? target.index
                : source.index;
            return Offset((oldColumn - column) * (cellWidth + _cellGap), 0);
          }
          return Offset.zero;
        }

        Widget lineHighlight(
          BoardLineTarget target, {
          required bool isDropTarget,
        }) {
          final isRow = target.kind == BoardLineKind.row;
          return Positioned(
            left: isRow
                ? _handleSize + handleGap + boardInset
                : _handleSize +
                      handleGap +
                      boardInset +
                      target.index * (cellWidth + _cellGap),
            top: isRow
                ? _handleSize +
                      handleGap +
                      boardInset +
                      target.index * (cellHeight + _cellGap)
                : _handleSize + handleGap + boardInset,
            width: isRow ? boardWidth : cellWidth,
            height: isRow ? cellHeight : boardHeight,
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
                      ? colorScheme.secondaryContainer.withValues(alpha: 0.55)
                      : colorScheme.primaryContainer.withValues(alpha: 0.35),
                ),
              ),
            ),
          );
        }

        return SizedBox(
          width: frameWidth + 2 * _handleSize + 2 * handleGap,
          height: frameHeight + 2 * _handleSize + 2 * handleGap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: _handleSize + handleGap,
                top: _handleSize + handleGap,
                width: frameWidth,
                height: frameHeight,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: visualConfig.boardGradient,
                      color: visualConfig.decorated
                          ? null
                          : colorScheme.surfaceContainer,
                      border: Border.all(
                        color:
                            visualConfig.boardBorder ??
                            colorScheme.primary.withValues(alpha: .32),
                      ),
                      borderRadius:
                          visualConfig.boardRadius ?? BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .22),
                          blurRadius: 28,
                        ),
                        if (visualConfig.decorated)
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: .10),
                            blurRadius: 28,
                            spreadRadius: -4,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              for (var column = 0; column < board.columnCount; column++) ...[
                _positionedHandle(
                  target: BoardLineTarget(BoardLineKind.column, column),
                  side: BoardHandleSide.top,
                  left:
                      _handleSize +
                      handleGap +
                      column * (handleCellWidth + _cellGap),
                  top: 0,
                  width: handleCellWidth,
                  height: _handleSize,
                ),
                _positionedHandle(
                  target: BoardLineTarget(BoardLineKind.column, column),
                  side: BoardHandleSide.bottom,
                  left:
                      _handleSize +
                      handleGap +
                      column * (handleCellWidth + _cellGap),
                  top: _handleSize + handleGap + frameHeight,
                  width: handleCellWidth,
                  height: _handleSize,
                ),
              ],
              for (var row = 0; row < board.rowCount; row++) ...[
                _positionedHandle(
                  target: BoardLineTarget(BoardLineKind.row, row),
                  side: BoardHandleSide.left,
                  left: 0,
                  top:
                      _handleSize +
                      handleGap +
                      row * (handleCellHeight + _cellGap),
                  width: _handleSize,
                  height: handleCellHeight,
                ),
                _positionedHandle(
                  target: BoardLineTarget(BoardLineKind.row, row),
                  side: BoardHandleSide.right,
                  left: _handleSize + handleGap + frameWidth,
                  top:
                      _handleSize +
                      handleGap +
                      row * (handleCellHeight + _cellGap),
                  width: _handleSize,
                  height: handleCellHeight,
                ),
              ],
              if (!visualConfig.decorated)
                if (sourceLineHighlight case final source?)
                  lineHighlight(source, isDropTarget: false),
              if (!visualConfig.decorated)
                if (targetLineHighlight case final target?)
                  lineHighlight(target, isDropTarget: true),
              for (var row = 0; row < board.rowCount; row++)
                for (var column = 0; column < board.columnCount; column++)
                  Positioned(
                    left:
                        _handleSize +
                        handleGap +
                        boardInset +
                        column * (cellWidth + _cellGap),
                    top:
                        _handleSize +
                        handleGap +
                        boardInset +
                        row * (cellHeight + _cellGap),
                    width: cellWidth,
                    height: cellHeight,
                    child: _SwapMotion(
                      offset: swapOffsetFor(row, column),
                      animationId: swapAnimationId,
                      disableAnimations: disableAnimations,
                      borderRadius: _cellBorderRadius(
                        CellPosition(row, column),
                      ),
                      firstKeyframeBorderRadius: _swapBorderRadius(
                        cellWidth,
                        cellHeight,
                        const <double>[38, 62, 55, 45],
                        const <double>[48, 43, 57, 52],
                      ),
                      secondKeyframeBorderRadius: _swapBorderRadius(
                        cellWidth,
                        cellHeight,
                        const <double>[58, 42, 48, 52],
                        const <double>[43, 58, 42, 57],
                      ),
                      child: _LineDropTarget(
                        row: row,
                        column: column,
                        onHover: onHover,
                        onLeave: onLeave,
                        onAccept: onAccept,
                        child: GameCell(
                          position: CellPosition(row, column),
                          value: board.valueAt(CellPosition(row, column)),
                          selected: selectedCell == CellPosition(row, column),
                          undoing: false,
                          resolving: resolvingCell == CellPosition(row, column),
                          dragSource: sourceLineHighlight != null
                              ? inLine(sourceLineHighlight!, row, column)
                              : fromSwapSource(row, column),
                          dragTarget: targetLineHighlight != null
                              ? inLine(targetLineHighlight!, row, column)
                              : fromSwapTarget(row, column),
                          dimmed:
                              resolvingCell != null &&
                                  resolvingCell != CellPosition(row, column) ||
                              dimmingSource != null &&
                                  !(dimmingSource.kind == BoardLineKind.row &&
                                          dimmingSource.index == row ||
                                      dimmingSource.kind ==
                                              BoardLineKind.column &&
                                          dimmingSource.index == column ||
                                      dimmingTarget?.kind ==
                                              BoardLineKind.row &&
                                          dimmingTarget?.index == row ||
                                      dimmingTarget?.kind ==
                                              BoardLineKind.column &&
                                          dimmingTarget?.index == column),
                          visualConfig: visualConfig,
                          tutorialGuided:
                              isTutorialCellHighlighted?.call(
                                CellPosition(row, column),
                              ) ??
                              false,
                          disableAnimations: disableAnimations,
                          onPressed: onCellPressed,
                        ),
                      ),
                    ),
                  ),
              if (historicalGame case final game?)
                DateFrameDecoration(
                  game: game,
                  cellWidth: cellWidth,
                  cellHeight: cellHeight,
                  visualConfig: visualConfig,
                ),
              for (final afterimage in swapAfterimages)
                Positioned(
                  left:
                      _handleSize +
                      handleGap +
                      boardInset +
                      afterimage.position.column * (cellWidth + _cellGap),
                  top:
                      _handleSize +
                      handleGap +
                      boardInset +
                      afterimage.position.row * (cellHeight + _cellGap),
                  width: cellWidth,
                  height: cellHeight,
                  child: _SwapAfterimage(
                    key: Key(
                      'swap-afterimage-${afterimage.id}-${afterimage.position.row}-${afterimage.position.column}',
                    ),
                    disableAnimations: disableAnimations,
                    child: ExcludeSemantics(
                      child: IgnorePointer(
                        child: GameCell(
                          position: afterimage.position,
                          value: afterimage.value,
                          selected: false,
                          undoing: false,
                          dragSource: afterimage.dragSource,
                          dragTarget: afterimage.dragTarget,
                          disableAnimations: disableAnimations,
                          visualConfig: visualConfig,
                          onPressed: (_) {},
                        ),
                      ),
                    ),
                  ),
                ),
              if (resolvingCell case final cell?)
                if (resolvingEquation case final formula?)
                  Positioned(
                    left:
                        _handleSize +
                        handleGap +
                        boardInset +
                        cell.column * (cellWidth + _cellGap),
                    top:
                        _handleSize +
                        handleGap +
                        boardInset +
                        cell.row * (cellHeight + _cellGap),
                    width: cellWidth,
                    height: cellHeight,
                    child: IgnorePointer(
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(formula),
                        tween: Tween(begin: 1, end: 2.2),
                        duration: disableAnimations
                            ? Duration.zero
                            : const Duration(milliseconds: 2200),
                        builder: (context, scale, child) {
                          final progress = ((scale - 1) / 1.2).clamp(0.0, 1.0);
                          final opacity = progress < .42
                              ? .7 + progress / .42 * .3
                              : progress < .62
                              ? 1.0
                              : progress < .88
                              ? 1 - (progress - .62) / .26 * .85
                              : .15 * (1 - (progress - .88) / .12);
                          return Opacity(
                            opacity: opacity,
                            child: Transform.scale(scale: scale, child: child),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.fromRGBO(18, 66, 76, .99),
                                Color.fromRGBO(38, 113, 111, .98),
                              ],
                            ),
                            border: Border.all(color: const Color(0xffb9fff1)),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(116, 215, 196, .55),
                                blurRadius: 28,
                              ),
                            ],
                          ),
                          child: Text(
                            formula,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontFamily: 'monospace',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              if (targetLineHighlight != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Text(
                        targetLineHighlight!.kind == BoardLineKind.row
                            ? '⇅'
                            : '⇄',
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
      isActive:
          (sourceLineHighlight ?? (isAnimatingSwap ? swapSource : null)) ==
              target ||
          (targetLineHighlight ?? (isAnimatingSwap ? swapTarget : null)) ==
              target,
      isSource:
          (sourceLineHighlight ?? (isAnimatingSwap ? swapSource : null)) ==
          target,
      isTarget:
          (targetLineHighlight ?? (isAnimatingSwap ? swapTarget : null)) ==
          target,
      dimmed:
          (sourceLineHighlight ?? (isAnimatingSwap ? swapSource : null)) !=
              null &&
          (sourceLineHighlight ?? (isAnimatingSwap ? swapSource : null)) !=
              target &&
          (targetLineHighlight ?? (isAnimatingSwap ? swapTarget : null)) !=
              target,
      tutorialGuided:
          isTutorialLineHighlighted?.call(target.kind, target.index) ?? false,
      enabled: true,
      disableAnimations: disableAnimations,
      visualConfig: visualConfig,
      onDragStarted: onDragStarted,
      onHover: onHover,
      onLeave: onLeave,
      onAccept: onAccept,
      onDragCancelled: onDragCancelled,
    ),
  );
}

class _LineDropTarget extends StatelessWidget {
  const _LineDropTarget({
    required this.row,
    required this.column,
    required this.onHover,
    required this.onLeave,
    required this.onAccept,
    required this.child,
  });

  final int row;
  final int column;
  final ValueChanged<BoardLineTarget> onHover;
  final ValueChanged<BoardLineTarget> onLeave;
  final void Function(BoardLineTarget, BoardLineTarget) onAccept;
  final Widget child;

  BoardLineTarget _targetFor(BoardLineTarget source) => BoardLineTarget(
    source.kind,
    source.kind == BoardLineKind.row ? row : column,
  );

  @override
  Widget build(BuildContext context) => DragTarget<BoardLineTarget>(
    onWillAcceptWithDetails: (details) {
      final target = _targetFor(details.data);
      if (!details.data.accepts(target)) return false;
      onHover(target);
      return true;
    },
    onLeave: (source) {
      if (source != null) onLeave(_targetFor(source));
    },
    onAcceptWithDetails: (details) =>
        onAccept(details.data, _targetFor(details.data)),
    builder: (context, _, _) => child,
  );
}

class GameCell extends StatelessWidget {
  const GameCell({
    super.key,
    required this.position,
    required this.value,
    required this.selected,
    required this.undoing,
    required this.disableAnimations,
    this.resolving = false,
    this.dimmed = false,
    this.dragSource = false,
    this.dragTarget = false,
    this.tutorialGuided = false,
    this.equation,
    this.visualConfig = BoardVisualConfig.standard,
    required this.onPressed,
  });

  final CellPosition position;
  final int value;
  final bool selected;
  final bool undoing;
  final bool disableAnimations;
  final bool resolving;
  final bool dimmed;
  final bool dragSource;
  final bool dragTarget;
  final bool tutorialGuided;
  final String? equation;
  final BoardVisualConfig visualConfig;
  final ValueChanged<CellPosition> onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Cell ${position.row + 1}, ${position.column + 1}: $value',
      child: _DimmingFilter(
        enabled: dimmed && visualConfig.decorated,
        disableAnimations: disableAnimations,
        child: AnimatedScale(
          scale: undoing ? 1.08 : 1,
          duration: disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 200),
            curve: Curves.ease,
            decoration: visualConfig.decorated && !undoing
                ? BoxDecoration(
                    gradient: dragTarget
                        ? visualConfig.targetCellGradient
                        : dragSource || selected
                        ? visualConfig.sourceCellGradient
                        : visualConfig.idleCellGradient,
                    boxShadow: selected || dragSource
                        ? [
                            BoxShadow(
                              color: visualConfig.sourceCellBorder!.withValues(
                                alpha: .28,
                              ),
                              blurRadius: 20,
                            ),
                          ]
                        : null,
                    border: Border.all(
                      color: dragSource || selected
                          ? visualConfig.sourceCellBorder!
                          : dragTarget
                          ? visualConfig.targetCellBorder!
                          : visualConfig.idleCellBorder!,
                    ),
                    borderRadius: _cellBorderRadius(position),
                  )
                : const BoxDecoration(),
            child: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                if (visualConfig.decorated && !undoing)
                  const IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(-.32, -.52),
                          radius: .72,
                          colors: [
                            Color.fromRGBO(190, 255, 243, .13),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                if (tutorialGuided)
                  _TutorialGuidedGlow(
                    key: Key(
                      'tutorial-guided-cell-${position.row}-${position.column}',
                    ),
                    borderRadius: _cellBorderRadius(position),
                    disableAnimations: disableAnimations,
                  ),
                OutlinedButton(
                  key: Key('cell-${position.row}-${position.column}'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: selected || undoing
                        ? (visualConfig.decorated
                              ? Colors.transparent
                              : (selected
                                    ? colorScheme.primaryContainer
                                    : colorScheme.tertiaryContainer))
                        : visualConfig.decorated
                        ? Colors.transparent
                        : colorScheme.surfaceContainerHighest,
                    foregroundColor: colorScheme.onSurface,
                    side: visualConfig.decorated ? BorderSide.none : null,
                    padding: const EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                      borderRadius: _cellBorderRadius(position),
                    ),
                  ),
                  onPressed: () => onPressed(position),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final fontSize = (constraints.biggest.shortestSide * 0.55)
                          .clamp(12.0, visualConfig.decorated ? 36.0 : 32.0)
                          .toDouble();
                      return FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$value',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontSize: fontSize,
                                color: colorScheme.onSurface,
                                fontFamily: visualConfig.decorated
                                    ? 'monospace'
                                    : null,
                              ),
                        ),
                      );
                    },
                  ),
                ),
                if (equation case final formula?)
                  IgnorePointer(
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey(formula),
                      tween: Tween(begin: 1, end: 2.2),
                      duration: disableAnimations
                          ? Duration.zero
                          : const Duration(milliseconds: 2200),
                      curve: Curves.easeOutCubic,
                      builder: (context, scale, child) => Opacity(
                        opacity: disableAnimations
                            ? 0
                            : (1 - ((scale - 1) / 1.2)).clamp(0.0, 1.0),
                        child: Transform.scale(scale: scale, child: child),
                      ),
                      child: Center(
                        child: Text(
                          formula,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontFamily: 'monospace',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
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
    );
  }
}

class _SwapMotion extends StatelessWidget {
  const _SwapMotion({
    required this.offset,
    required this.animationId,
    required this.disableAnimations,
    required this.borderRadius,
    required this.firstKeyframeBorderRadius,
    required this.secondKeyframeBorderRadius,
    required this.child,
  });
  final Offset offset;
  final int animationId;
  final bool disableAnimations;
  final BorderRadius borderRadius;
  final BorderRadius firstKeyframeBorderRadius;
  final BorderRadius secondKeyframeBorderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (offset == Offset.zero) return child;
    return TweenAnimationBuilder<double>(
      key: ValueKey('swap-$animationId-$offset'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: disableAnimations
          ? Duration.zero
          : const Duration(milliseconds: 1180),
      curve: Curves.linear,
      child: child,
      builder: (context, progress, child) {
        double value(List<(double, double)> frames) {
          for (var i = 1; i < frames.length; i++) {
            if (progress <= frames[i].$1) {
              final t =
                  (progress - frames[i - 1].$1) /
                  (frames[i].$1 - frames[i - 1].$1);
              return frames[i - 1].$2 + (frames[i].$2 - frames[i - 1].$2) * t;
            }
          }
          return frames.last.$2;
        }

        final radius = BorderRadius.lerp(
          borderRadius,
          firstKeyframeBorderRadius,
          (progress / .34).clamp(0.0, 1.0),
        )!;
        final lateRadius = BorderRadius.lerp(
          firstKeyframeBorderRadius,
          secondKeyframeBorderRadius,
          ((progress - .34) / .40).clamp(0.0, 1.0),
        )!;
        final currentRadius = progress <= .34
            ? radius
            : progress <= .74
            ? lateRadius
            : BorderRadius.lerp(
                lateRadius,
                borderRadius,
                (progress - .74) / .26,
              )!;
        return Opacity(
          opacity: value(const [(0, 1), (.34, .88), (.74, .94), (1, 1)]),
          child: Transform.translate(
            offset:
                offset * value(const [(0, 1), (.34, .7), (.74, .16), (1, 0)]),
            child: Transform.scale(
              scale: value(const [(0, 1), (.34, 1.07), (.74, .98), (1, 1)]),
              child: ClipRRect(borderRadius: currentRadius, child: child),
            ),
          ),
        );
      },
    );
  }
}

BorderRadius _swapBorderRadius(
  double width,
  double height,
  List<double> horizontal,
  List<double> vertical,
) => BorderRadius.only(
  topLeft: Radius.elliptical(
    width * horizontal[0] / 100,
    height * vertical[0] / 100,
  ),
  topRight: Radius.elliptical(
    width * horizontal[1] / 100,
    height * vertical[1] / 100,
  ),
  bottomRight: Radius.elliptical(
    width * horizontal[2] / 100,
    height * vertical[2] / 100,
  ),
  bottomLeft: Radius.elliptical(
    width * horizontal[3] / 100,
    height * vertical[3] / 100,
  ),
);

class _SwapAfterimage extends StatelessWidget {
  const _SwapAfterimage({
    super.key,
    required this.disableAnimations,
    required this.child,
  });

  final bool disableAnimations;
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 1000),
    curve: Curves.easeOut,
    child: child,
    builder: (context, progress, child) => Opacity(
      opacity: .3 * (1 - progress),
      child: Transform.scale(scale: 1 + .16 * progress, child: child),
    ),
  );
}

class _TutorialGuidedGlow extends StatefulWidget {
  const _TutorialGuidedGlow({
    super.key,
    required this.borderRadius,
    required this.disableAnimations,
  });

  final BorderRadius borderRadius;
  final bool disableAnimations;

  @override
  State<_TutorialGuidedGlow> createState() => _TutorialGuidedGlowState();
}

class _TutorialGuidedGlowState extends State<_TutorialGuidedGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    if (!widget.disableAnimations) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = .5;
    }
  }

  @override
  void didUpdateWidget(covariant _TutorialGuidedGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.disableAnimations && !oldWidget.disableAnimations) {
      _controller.stop();
      _controller.value = .5;
    } else if (!widget.disableAnimations && oldWidget.disableAnimations) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = Curves.easeInOut.transform(_controller.value);
        return CustomPaint(
          painter: _TutorialWavePainter(
            progress: progress,
            borderRadius: widget.borderRadius,
          ),
        );
      },
    ),
  );
}

class _TutorialWavePainter extends CustomPainter {
  const _TutorialWavePainter({
    required this.progress,
    required this.borderRadius,
  });

  final double progress;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);
    final glow = Paint()
      ..color = const Color.fromRGBO(
        205,
        215,
        239,
        1,
      ).withValues(alpha: .22 + .38 * progress)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 + 16 * progress);
    canvas.drawRRect(rrect, glow);

    // Mirrors the sketch's 220% gradient background travelling from 0%/30%
    // to 100%/70% across the clipped cell.
    final waveRect = Rect.fromLTWH(
      -size.width * 1.2 + size.width * 1.2 * progress,
      -size.height * .35 + size.height * .35 * progress,
      size.width * 2.2,
      size.height * 2.2,
    );
    final wave = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(93, 108, 145, .96),
          Color.fromRGBO(174, 191, 226, .88),
          Color.fromRGBO(62, 76, 105, .98),
        ],
      ).createShader(waveRect);
    canvas.drawRRect(rrect, wave);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color.fromRGBO(238, 243, 255, .8)
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _TutorialWavePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.borderRadius != borderRadius;
}

class _DimmingFilter extends StatefulWidget {
  const _DimmingFilter({
    required this.enabled,
    required this.disableAnimations,
    required this.child,
  });
  final bool enabled;
  final bool disableAnimations;
  final Widget child;

  @override
  State<_DimmingFilter> createState() => _DimmingFilterState();
}

class _DimmingFilterState extends State<_DimmingFilter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      value: widget.enabled ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant _DimmingFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.disableAnimations) {
      _controller.value = widget.enabled ? 1 : 0;
    } else if (oldWidget.enabled != widget.enabled) {
      _controller.animateTo(
        widget.enabled ? 1 : 0,
        duration: const Duration(milliseconds: 700),
        curve: Curves.ease,
      );
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
      final progress = _controller.value;
      const dim = [
        .348,
        .283,
        .029,
        0,
        0,
        .084,
        .547,
        .029,
        0,
        0,
        .084,
        .283,
        .293,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ];
      final matrix = <double>[
        for (var index = 0; index < 20; index++)
          index == 18
              ? 1
              : (index == 3 ||
                    index == 4 ||
                    index == 8 ||
                    index == 9 ||
                    index == 13 ||
                    index == 14 ||
                    index == 15 ||
                    index == 16 ||
                    index == 17 ||
                    index == 19)
              ? 0
              : (index == 0 || index == 6 || index == 12)
              ? 1 + (dim[index] - 1) * progress
              : dim[index] * progress,
      ];
      return Opacity(
        opacity: 1 - .66 * progress,
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix(matrix),
          child: child,
        ),
      );
    },
  );
}

class EdgeSwapHandle extends StatefulWidget {
  const EdgeSwapHandle({
    super.key,
    required this.target,
    required this.side,
    required this.isActive,
    this.isSource = false,
    this.isTarget = false,
    this.dimmed = false,
    this.tutorialGuided = false,
    required this.enabled,
    required this.disableAnimations,
    this.visualConfig = BoardVisualConfig.standard,
    required this.onDragStarted,
    required this.onHover,
    required this.onLeave,
    required this.onAccept,
    required this.onDragCancelled,
  });

  final BoardLineTarget target;
  final BoardHandleSide side;
  final bool isActive;
  final bool isSource;
  final bool isTarget;
  final bool dimmed;
  final bool tutorialGuided;
  final bool enabled;
  final bool disableAnimations;
  final BoardVisualConfig visualConfig;
  final ValueChanged<BoardLineTarget> onDragStarted;
  final ValueChanged<BoardLineTarget> onHover;
  final ValueChanged<BoardLineTarget> onLeave;
  final void Function(BoardLineTarget, BoardLineTarget) onAccept;
  final VoidCallback onDragCancelled;

  @override
  State<EdgeSwapHandle> createState() => _EdgeSwapHandleState();
}

class _EdgeSwapHandleState extends State<EdgeSwapHandle>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _dimmingController;

  @override
  void initState() {
    super.initState();
    _dimmingController = AnimationController(
      vsync: this,
      value: widget.dimmed ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant EdgeSwapHandle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.disableAnimations) {
      _dimmingController.value = widget.dimmed ? 1 : 0;
    } else if (oldWidget.dimmed != widget.dimmed) {
      _dimmingController.animateTo(
        widget.dimmed ? 1 : 0,
        duration: const Duration(milliseconds: 700),
        curve: Curves.ease,
      );
    }
  }

  @override
  void dispose() {
    _dimmingController.dispose();
    super.dispose();
  }

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
    onAcceptWithDetails: (details) =>
        widget.onAccept(details.data, widget.target),
    builder: (context, candidateData, rejectedData) => MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.grab : MouseCursor.defer,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Draggable<BoardLineTarget>(
        data: widget.target,
        maxSimultaneousDrags: widget.enabled ? 1 : 0,
        onDragStarted: () => widget.onDragStarted(widget.target),
        onDragEnd: (_) => widget.onDragCancelled(),
        feedback: const SizedBox.shrink(),
        childWhenDragging: _icon(context, active: true),
        child: _icon(
          context,
          active: widget.isActive || candidateData.isNotEmpty,
        ),
      ),
    ),
  );

  Widget _icon(BuildContext context, {required bool active}) {
    final colorScheme = Theme.of(context).colorScheme;
    final highlighted = active || _isHovered;
    final backgroundColor = widget.isTarget
        ? const Color.fromRGBO(244, 185, 76, .38)
        : widget.isSource
        ? const Color.fromRGBO(116, 215, 196, .48)
        : active
        ? colorScheme.secondaryContainer
        : _isHovered
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.55)
        : widget.visualConfig.decorated
        ? widget.visualConfig.handleBackground!
        : Colors.transparent;
    return AnimatedBuilder(
      animation: _dimmingController,
      builder: (context, child) =>
          Opacity(opacity: 1 - .72 * _dimmingController.value, child: child),
      child: AnimatedScale(
        scale: widget.isSource ? 1.06 : 1,
        duration: widget.disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 180),
        curve: Curves.ease,
        child: Semantics(
          label:
              '${widget.side.label} handle for ${widget.target.kind.label} ${widget.target.index + 1}',
          child: AnimatedContainer(
            key: Key(
              '${widget.target.kind.name}-handle-${widget.side.name}-${widget.target.index}',
            ),
            duration: widget.disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 180),
            curve: Curves.ease,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: widget.visualConfig.decorated
                  ? Border.fromBorderSide(
                      BorderSide(
                        color: widget.isSource
                            ? widget.visualConfig.sourceCellBorder!
                            : widget.isTarget
                            ? widget.visualConfig.targetCellBorder!
                            : widget.visualConfig.handleBorder!,
                      ),
                    )
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (widget.tutorialGuided)
                  _TutorialGuidedGlow(
                    key: Key(
                      'tutorial-guided-handle-${widget.side.name}-${widget.target.kind.name}-${widget.target.index}',
                    ),
                    borderRadius: BorderRadius.circular(8),
                    disableAnimations: widget.disableAnimations,
                  ),
                Center(
                  child: TweenAnimationBuilder<Color?>(
                    tween: ColorTween(
                      end: widget.isSource
                          ? widget.visualConfig.sourceHandleColor ??
                                const Color(0xff102f38)
                          : widget.isTarget
                          ? widget.visualConfig.targetHandleColor ??
                                const Color(0xfffff2d6)
                          : highlighted
                          ? colorScheme.onSurfaceVariant
                          : widget.visualConfig.handleColor ??
                                colorScheme.outline,
                    ),
                    duration: widget.disableAnimations
                        ? Duration.zero
                        : const Duration(milliseconds: 180),
                    curve: Curves.ease,
                    builder: (context, color, _) => Icon(
                      widget.target.kind == BoardLineKind.row
                          ? Icons.more_horiz
                          : Icons.more_vert,
                      size: 16,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    required this.visualConfig,
  });

  final HistoricalDateGame game;
  final double cellWidth;
  final double cellHeight;
  final BoardVisualConfig visualConfig;

  @override
  Widget build(BuildContext context) {
    final width = cellWidth * 3 + _cellGap * 3;
    return Positioned(
      key: const Key('historical-date-frame'),
      left:
          _handleSize +
          visualConfig.handleGap +
          visualConfig.boardInset +
          game.frame.column * (cellWidth + _cellGap) -
          _cellGap / 2,
      top:
          _handleSize +
          visualConfig.handleGap +
          visualConfig.boardInset +
          game.frame.row * (cellHeight + _cellGap) -
          _cellGap / 2,
      width: width,
      height: cellHeight + _cellGap,
      child: IgnorePointer(
        child: CustomPaint(
          painter: const _DateFramePainter(),
          child: Stack(
            children: [
              for (var index = 1; index < 3; index++)
                Positioned(
                  left: index * (cellWidth + _cellGap) - 12,
                  width: 24,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Text(
                      game.format.separator,
                      key: Key('historical-date-separator-$index'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xffffd782),
                        fontFamily: 'serif',
                        shadows: const [
                          Shadow(
                            color: Color.fromRGBO(244, 185, 76, .28),
                            blurRadius: 5,
                          ),
                        ],
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

class _DateFramePainter extends CustomPainter {
  const _DateFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(8)),
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color.fromRGBO(244, 185, 76, .18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color.fromRGBO(244, 185, 76, .85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _DateFramePainter oldDelegate) => false;
}
