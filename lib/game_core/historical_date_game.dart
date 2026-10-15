import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/game_session.dart';
import 'package:numbers_game/game_core/playable_game.dart';

/// A historical event whose date is the target configuration for a level.
class HistoricalEvent {
  const HistoricalEvent({
    required this.title,
    required this.description,
    required this.date,
  });

  final String title;
  final String description;
  final DateTime date;

  Map<String, Object> toJson() => {
        'title': title,
        'description': description,
        'date': {
          'year': date.year,
          'month': date.month,
          'day': date.day,
        },
      };

  factory HistoricalEvent.fromJson(Map<String, Object?> json) {
    final title = json['title'];
    final description = json['description'];
    final date = json['date'];
    if (title is! String || description is! String || date is! Map) {
      throw const FormatException('Invalid historical event');
    }
    final values = date.cast<Object?, Object?>();
    final year = values['year'];
    final month = values['month'];
    final day = values['day'];
    if (year is! int || year < 1 || month is! int || day is! int) {
      throw const FormatException('Invalid historical event date');
    }
    try {
      final parsed = DateTime.utc(year, month, day);
      if (parsed.year != year || parsed.month != month || parsed.day != day) {
        throw const FormatException('Invalid historical event date');
      }
      return HistoricalEvent(title: title, description: description, date: parsed);
    } on ArgumentError {
      throw const FormatException('Invalid historical event date');
    }
  }
}

enum DateComponent { day, month, year }

/// The locale-derived presentation of the date frame, captured at level creation.
class DateFrameFormat {
  const DateFrameFormat({required this.order, required this.separator})
      : assert(separator != '');

  final List<DateComponent> order;
  final String separator;

  Map<String, Object> toJson() => {
        'order': order.map((component) => component.name).toList(),
        'separator': separator,
      };

  factory DateFrameFormat.fromJson(Map<String, Object?> json) {
    final order = json['order'];
    final separator = json['separator'];
    if (order is! List || separator is! String || separator.isEmpty) {
      throw const FormatException('Invalid date frame format');
    }
    final components = order
        .map((value) => DateComponent.values.where((item) => item.name == value).firstOrNull)
        .toList();
    if (components.length != 3 || components.any((item) => item == null) ||
        components.toSet().length != 3) {
      throw const FormatException('Invalid date frame format');
    }
    return DateFrameFormat(
      order: components.cast<DateComponent>(),
      separator: separator,
    );
  }

  factory DateFrameFormat.forLocale(String locale) {
    final normalized = locale.toLowerCase().replaceAll('-', '_');
    if (normalized.startsWith('ja') || normalized.startsWith('zh') ||
        normalized.startsWith('ko')) {
      return const DateFrameFormat(
        order: [DateComponent.year, DateComponent.month, DateComponent.day],
        separator: '.',
      );
    }
    if (normalized.startsWith('en_us') || normalized.startsWith('en_ca')) {
      return const DateFrameFormat(
        order: [DateComponent.month, DateComponent.day, DateComponent.year],
        separator: '/',
      );
    }
    return const DateFrameFormat(
      order: [DateComponent.day, DateComponent.month, DateComponent.year],
      separator: '.',
    );
  }
}

/// The non-interactive decoration identifying the three date cells on a board.
class DateFrame {
  const DateFrame(this.row, this.column)
      : assert(row >= 0),
        assert(column >= 0);

  final int row;
  final int column;

  Map<String, Object> toJson() => {'row': row, 'column': column};

  factory DateFrame.fromJson(Map<String, Object?> json) {
    final row = json['row'];
    final column = json['column'];
    if (row is! int || row < 0 || column is! int || column < 0) {
      throw const FormatException('Invalid date frame');
    }
    return DateFrame(row, column);
  }
}

/// A mode won by restoring a known historical date in its framed target cells.
class HistoricalDateGame implements PlayableGame {
  HistoricalDateGame({
    required this._session,
    required this.targetBoard,
    required this.event,
    required this.frame,
    required this.format,
    required this.moveCount,
  });

  final GameSession _session;
  final Board targetBoard;
  final HistoricalEvent event;
  final DateFrame frame;
  final DateFrameFormat format;
  @override
  final int moveCount;

  @override
  GameSession get session => _session;
  @override
  Board get currentBoard => _session.currentBoard;
  @override
  bool get canUndo => _session.canUndo;
  @override
  bool get isLost => false;
  @override
  bool get isWon => _sameBoard(currentBoard, targetBoard);

  /// The target date as it was presented when this level was created.
  String get formattedDate => format.order
      .map(
        (component) => switch (component) {
          DateComponent.day => event.date.day,
          DateComponent.month => event.date.month,
          DateComponent.year => event.date.year,
        },
      )
      .join(format.separator);

  @override
  HistoricalDateGame applyArithmeticMove({
    required CellPosition source,
    required CellPosition target,
  }) => _withSession(_session.applyArithmeticMove(source: source, target: target), moveCount + 1);

  @override
  HistoricalDateGame swapRows(int first, int second) =>
      _withSession(_session.swapRows(first, second), moveCount + 1);

  @override
  HistoricalDateGame swapColumns(int first, int second) =>
      _withSession(_session.swapColumns(first, second), moveCount + 1);

  @override
  HistoricalDateGame undo() => canUndo ? _withSession(_session.undo(), moveCount - 1) : this;

  @override
  HistoricalDateGame restart() => _withSession(_session.restart(), 0);

  HistoricalDateGame _withSession(GameSession session, int moves) => HistoricalDateGame(
        session: session,
        targetBoard: targetBoard,
        event: event,
        frame: frame,
        format: format,
        moveCount: moves,
      );
}

bool _sameBoard(Board first, Board second) {
  if (first.rowCount != second.rowCount || first.columnCount != second.columnCount) {
    return false;
  }
  for (var row = 0; row < first.rowCount; row++) {
    for (var column = 0; column < first.columnCount; column++) {
      if (first.valueAt(CellPosition(row, column)) !=
          second.valueAt(CellPosition(row, column))) {
        return false;
      }
    }
  }
  return true;
}
