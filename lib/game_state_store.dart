import 'dart:convert';
import 'dart:math';
import 'dart:ui' show PlatformDispatcher;

import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/game_session.dart';
import 'package:numbers_game/game_core/historical_date_game.dart';
import 'package:numbers_game/game_core/one_non_zero_game.dart';
import 'package:numbers_game/game_core/playable_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameMode { oneNonZero, historicalDate }

sealed class ModeSettings {
  const ModeSettings();
}

class OneNonZeroSettings extends ModeSettings {
  const OneNonZeroSettings({
    this.boardSize = 4,
    this.maxInitialValue = 10,
  })  : assert(boardSize >= 2),
        assert(maxInitialValue >= 1);

  final int boardSize;
  final int maxInitialValue;

  Map<String, Object> toJson() => {
        'boardSize': boardSize,
        'maxInitialValue': maxInitialValue,
      };

  factory OneNonZeroSettings.fromJson(Map<String, Object?> json) {
    final boardSize = json['boardSize'];
    final maxInitialValue = json['maxInitialValue'];
    if (boardSize is! int ||
        boardSize < 2 ||
        maxInitialValue is! int ||
        maxInitialValue < 1) {
      throw const FormatException('Invalid One Non-Zero settings');
    }
    return OneNonZeroSettings(
      boardSize: boardSize,
      maxInitialValue: maxInitialValue,
    );
  }
}

class HistoricalDateSettings extends ModeSettings {
  const HistoricalDateSettings();

  Map<String, Object> toJson() => const {};

  factory HistoricalDateSettings.fromJson(Map<String, Object?> json) =>
      const HistoricalDateSettings();
}

/// Preferences for the application and each supported game mode.
class AppSettings {
  const AppSettings({
    this.selectedMode = GameMode.oneNonZero,
    this.oneNonZeroSettings = const OneNonZeroSettings(),
    this.historicalDateSettings = const HistoricalDateSettings(),
  });

  final GameMode selectedMode;
  final OneNonZeroSettings oneNonZeroSettings;
  final HistoricalDateSettings historicalDateSettings;

  Map<String, Object> toJson() => {
        'selectedMode': selectedMode.name,
        'modes': {
          GameMode.oneNonZero.name: oneNonZeroSettings.toJson(),
          GameMode.historicalDate.name: historicalDateSettings.toJson(),
        },
      };

  factory AppSettings.fromJson(Map<String, Object?> json) {
    final selectedMode =
        GameMode.values.where((mode) => mode.name == json['selectedMode']).firstOrNull;
    final modes = _jsonMap(json['modes']);
    if (selectedMode == null) {
      throw const FormatException('Invalid application settings');
    }
    return AppSettings(
      selectedMode: selectedMode,
      oneNonZeroSettings: OneNonZeroSettings.fromJson(
        _jsonMap(modes[GameMode.oneNonZero.name]),
      ),
      historicalDateSettings: HistoricalDateSettings.fromJson(
        modes.containsKey(GameMode.historicalDate.name)
            ? _jsonMap(modes[GameMode.historicalDate.name])
            : const {},
      ),
    );
  }
}

/// The complete state of one resumable game.
class SavedGame {
  const SavedGame({
    this.mode = GameMode.oneNonZero,
    required this.settings,
    required this.game,
  }) : assert(
          (mode == GameMode.oneNonZero && settings is OneNonZeroSettings) ||
              (mode == GameMode.historicalDate && settings is HistoricalDateSettings),
        );

  static const formatVersion = 3;

  final GameMode mode;
  final ModeSettings settings;
  final PlayableGame game;

  Map<String, Object> toJson() => {
        'version': formatVersion,
        'mode': mode.name,
        'settings': _modeSettingsToJson(mode, settings),
        'game': {
          'initialBoard': _boardToJson(game.session.initialBoard),
          'currentBoard': _boardToJson(game.currentBoard),
          'history': game.session.history.map(_boardToJson).toList(),
          'moveCount': game.moveCount,
          if (game case HistoricalDateGame historical) ...{
            'targetBoard': _boardToJson(historical.targetBoard),
            'event': historical.event.toJson(),
            'frame': historical.frame.toJson(),
            'format': historical.format.toJson(),
          },
        },
      };

  factory SavedGame.fromJson(Map<String, Object?> json) {
    final version = json['version'];
    if (version != 2 && version != formatVersion) {
      throw const FormatException('Unsupported saved game version');
    }
    final mode = GameMode.values.where((mode) => mode.name == json['mode']).firstOrNull;
    if (mode == null) {
      throw const FormatException('Invalid saved game mode');
    }
    final settings = _modeSettingsFromJson(mode, _jsonMap(json['settings']));
    final game = _jsonMap(json['game']);
    final history = _jsonList(game['history']).map(_boardFromJson).toList();
    final moveCount = game['moveCount'];
    if (moveCount is! int || moveCount < 0) {
      throw const FormatException('Invalid move count');
    }
    final session = GameSession.restore(
      initialBoard: _boardFromJson(_jsonMap(game['initialBoard'])),
      currentBoard: _boardFromJson(_jsonMap(game['currentBoard'])),
      history: history,
    );
    return SavedGame(
      mode: mode,
      settings: settings,
      game: switch (mode) {
        GameMode.oneNonZero => OneNonZeroGame.restore(
            session: session,
            moveCount: moveCount,
          ),
        GameMode.historicalDate => HistoricalDateGame(
            session: session,
            targetBoard: _boardFromJson(_jsonMap(game['targetBoard'])),
            event: HistoricalEvent.fromJson(_jsonMap(game['event'])),
            frame: DateFrame.fromJson(_jsonMap(game['frame'])),
            format: DateFrameFormat.fromJson(_jsonMap(game['format'])),
            moveCount: moveCount,
          ),
      },
    );
  }
}

final _historicalEvents = [
  HistoricalEvent(
    title: 'Apollo 11 Moon landing',
    description: 'Apollo 11 astronauts first landed on the Moon.',
    date: DateTime.utc(1969, 7, 20),
  ),
  HistoricalEvent(
    title: 'Fall of the Berlin Wall',
    description: 'Berlin Wall border crossings opened.',
    date: DateTime.utc(1989, 11, 9),
  ),
  HistoricalEvent(
    title: 'First web page published',
    description: 'The World Wide Web became publicly available.',
    date: DateTime.utc(1991, 8, 6),
  ),
];

const _historicalInitialValueLimit = 999;

abstract interface class GameStateStore {
  Future<AppSettings> loadSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<SavedGame?> loadCurrentGame();
  Future<void> saveCurrentGame(SavedGame game);
  Future<void> clearCurrentGame();
}

class SharedPreferencesGameStateStore implements GameStateStore {
  static const _settingsKey = 'game_settings';
  static const _currentGameKey = 'current_game';

  @override
  Future<AppSettings> loadSettings() async {
    final value = (await SharedPreferences.getInstance()).getString(_settingsKey);
    if (value == null) {
      return const AppSettings();
    }
    try {
      return AppSettings.fromJson(_jsonMap(jsonDecode(value)));
    } on FormatException {
      await (await SharedPreferences.getInstance()).remove(_settingsKey);
      return const AppSettings();
    }
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await (await SharedPreferences.getInstance()).setString(
      _settingsKey,
      jsonEncode(settings.toJson()),
    );
  }

  @override
  Future<SavedGame?> loadCurrentGame() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_currentGameKey);
    if (value == null) {
      return null;
    }
    try {
      return SavedGame.fromJson(_jsonMap(jsonDecode(value)));
    } on FormatException {
      await preferences.remove(_currentGameKey);
      return null;
    }
  }

  @override
  Future<void> saveCurrentGame(SavedGame game) async {
    await (await SharedPreferences.getInstance()).setString(
      _currentGameKey,
      jsonEncode(game.toJson()),
    );
  }

  @override
  Future<void> clearCurrentGame() async {
    await (await SharedPreferences.getInstance()).remove(_currentGameKey);
  }
}

OneNonZeroGame newOneNonZeroGame(
  OneNonZeroSettings settings, {
  Random? random,
}) {
  final generator = random ?? Random();
  final cells = List<List<int>>.generate(
    settings.boardSize,
    (_) => List<int>.generate(
      settings.boardSize,
      (_) => generator.nextInt(settings.maxInitialValue) + 1,
    ),
  );
  return OneNonZeroGame(Board(cells));
}

HistoricalDateGame newHistoricalDateGame({
  Random? random,
  String? locale,
}) {
  final generator = random ?? Random();
  final event = _historicalEvents[generator.nextInt(_historicalEvents.length)];
  final format = DateFrameFormat.forLocale(
    locale ?? PlatformDispatcher.instance.locale.toLanguageTag(),
  );
  const rows = 3;
  const columns = 5;
  final frame = DateFrame(generator.nextInt(rows), generator.nextInt(columns - 2));
  final targetCells = List.generate(rows, (_) => List.filled(columns, 0));
  for (var offset = 0; offset < format.order.length; offset++) {
    final component = format.order[offset];
    targetCells[frame.row][frame.column + offset] = switch (component) {
      DateComponent.day => event.date.day,
      DateComponent.month => event.date.month,
      DateComponent.year => event.date.year,
    };
  }
  final target = Board(targetCells);
  final targetValues = {
    event.date.day.abs(),
    event.date.month.abs(),
    event.date.year.abs(),
  };
  final initial = _scrambleHistoricalTarget(target, targetValues, generator);
  return HistoricalDateGame(
    session: GameSession(initial),
    targetBoard: target,
    event: event,
    frame: frame,
    format: format,
    moveCount: 0,
  );
}

Board _scrambleHistoricalTarget(Board target, Set<int> targetValues, Random _) {
  final nonZeroPositions = <CellPosition>[];
  final zeroPositions = <CellPosition>[];
  for (var row = 0; row < target.rowCount; row++) {
    for (var column = 0; column < target.columnCount; column++) {
      final position = CellPosition(row, column);
      (target.valueAt(position) == 0 ? zeroPositions : nonZeroPositions)
          .add(position);
    }
  }
  nonZeroPositions.sort(
    (first, second) => target.valueAt(first).abs().compareTo(target.valueAt(second).abs()),
  );

  final builder = _HistoricalScrambleBuilder(target, {
    'seed': nonZeroPositions.first,
    'large': nonZeroPositions.last,
    'other': nonZeroPositions[1],
    for (var index = 0; index < zeroPositions.length; index++)
      'zero$index': zeroPositions[index],
  });
  var seedValue = target.valueAt(nonZeroPositions.first).abs();
  var power = 'seed';
  var usedZeroes = 0;
  while (seedValue * 2 <= _historicalInitialValueLimit) {
    final nextPower = 'zero${usedZeroes++}';
    builder.subtract(source: power, target: nextPower);
    builder.add(source: power, target: nextPower);
    power = nextPower;
    seedValue *= 2;
  }

  var large = 'large';
  var seed = power;
  final zero = 'zero$usedZeroes';
  while (builder.valueAt(large).abs() > _historicalInitialValueLimit) {
    builder.subtract(source: large, target: seed);
    builder.subtract(source: seed, target: large);
    final previousLarge = large;
    large = seed;
    seed = previousLarge;
    if (builder.valueAt(large).abs() > _historicalInitialValueLimit) {
      builder.subtract(source: zero, target: seed);
    }
  }

  final sourceNames = [
    'seed',
    'large',
    'other',
    for (var index = 0; index < usedZeroes; index++) 'zero$index',
  ];
  for (var index = usedZeroes; index < zeroPositions.length; index++) {
    final target = 'zero$index';
    final counts = _valueCounts(builder.board);
    final source = sourceNames.firstWhere((name) {
      final value = builder.valueAt(name);
      return builder.positionOf(name) != builder.positionOf(target) &&
          value != 0 &&
          (counts[value] ?? 0) < 2;
    });
    builder.subtract(source: source, target: target);
  }

  final candidate = builder.board;
  if (_isInterestingHistoricalStart(candidate, targetValues) &&
      _historicalValuesFitInitialRange(candidate)) {
    return candidate;
  }
  throw StateError('Could not generate an interesting Historical Date start board');
}

class _HistoricalScrambleBuilder {
  _HistoricalScrambleBuilder(this.board, this._positions);

  Board board;
  final Map<String, CellPosition> _positions;

  int valueAt(String name) => board.valueAt(_positions[name]!);

  CellPosition positionOf(String name) => _positions[name]!;

  void add({required String source, required String target}) =>
      _apply(source: source, target: target, sourceBeforeTarget: true);

  void subtract({required String source, required String target}) =>
      _apply(source: source, target: target, sourceBeforeTarget: false);

  void _apply({
    required String source,
    required String target,
    required bool sourceBeforeTarget,
  }) {
    var sourcePosition = _positions[source]!;
    var targetPosition = _positions[target]!;
    final sourceIsBeforeTarget = sourcePosition.row < targetPosition.row ||
        (sourcePosition.row == targetPosition.row &&
            sourcePosition.column < targetPosition.column);
    if (sourceIsBeforeTarget != sourceBeforeTarget) {
      if (sourcePosition.row != targetPosition.row) {
        _swapRows(sourcePosition.row, targetPosition.row);
      } else {
        _swapColumns(sourcePosition.column, targetPosition.column);
      }
      sourcePosition = _positions[source]!;
      targetPosition = _positions[target]!;
    }
    board = board.applyArithmeticMove(source: sourcePosition, target: targetPosition);
  }

  void _swapRows(int first, int second) {
    board = board.swapRows(first, second);
    for (final name in _positions.keys.toList()) {
      final position = _positions[name]!;
      if (position.row == first) {
        _positions[name] = CellPosition(second, position.column);
      } else if (position.row == second) {
        _positions[name] = CellPosition(first, position.column);
      }
    }
  }

  void _swapColumns(int first, int second) {
    board = board.swapColumns(first, second);
    for (final name in _positions.keys.toList()) {
      final position = _positions[name]!;
      if (position.column == first) {
        _positions[name] = CellPosition(position.row, second);
      } else if (position.column == second) {
        _positions[name] = CellPosition(position.row, first);
      }
    }
  }
}

Map<int, int> _valueCounts(Board board) {
  final counts = <int, int>{};
  for (var row = 0; row < board.rowCount; row++) {
    for (var column = 0; column < board.columnCount; column++) {
      final value = board.valueAt(CellPosition(row, column));
      counts[value] = (counts[value] ?? 0) + 1;
    }
  }
  return counts;
}

bool _historicalValuesFitInitialRange(Board board) {
  for (var row = 0; row < board.rowCount; row++) {
    for (var column = 0; column < board.columnCount; column++) {
      if (board.valueAt(CellPosition(row, column)).abs() >
          _historicalInitialValueLimit) {
        return false;
      }
    }
  }
  return true;
}

bool _isInterestingHistoricalStart(Board board, Set<int> targetValues) {
  final counts = <int, int>{};
  final visibleTargetValues = <int>{};
  for (var row = 0; row < board.rowCount; row++) {
    for (var column = 0; column < board.columnCount; column++) {
      final value = board.valueAt(CellPosition(row, column));
      if (targetValues.contains(value.abs())) {
        visibleTargetValues.add(value.abs());
      }
      final count = (counts[value] ?? 0) + 1;
      if (count > 2) {
        return false;
      }
      counts[value] = count;
    }
  }
  return visibleTargetValues.length < targetValues.length;
}

Map<String, Object> _modeSettingsToJson(GameMode mode, ModeSettings settings) {
  switch ((mode, settings)) {
    case (GameMode.oneNonZero, OneNonZeroSettings settings):
      return settings.toJson();
    case (GameMode.historicalDate, HistoricalDateSettings settings):
      return settings.toJson();
    default:
      throw ArgumentError('Settings do not match game mode');
  }
}

ModeSettings _modeSettingsFromJson(GameMode mode, Map<String, Object?> json) {
  switch (mode) {
    case GameMode.oneNonZero:
      return OneNonZeroSettings.fromJson(json);
    case GameMode.historicalDate:
      return HistoricalDateSettings.fromJson(json);
  }
}

Map<String, Object> _boardToJson(Board board) => {
      'cells': [
        for (var row = 0; row < board.rowCount; row++)
          [
            for (var column = 0; column < board.columnCount; column++)
              board.valueAt(CellPosition(row, column)),
          ],
      ],
    };

Board _boardFromJson(Object? value) {
  final cells = _jsonList(_jsonMap(value)['cells'])
      .map((row) => _jsonList(row).map((cell) {
            if (cell is! int) {
              throw const FormatException('Invalid board cell');
            }
            return cell;
          }).toList())
      .toList();
  try {
    return Board(cells);
  } on ArgumentError {
    throw const FormatException('Invalid board');
  }
}

Map<String, Object?> _jsonMap(Object? value) {
  if (value is! Map) {
    throw const FormatException('Expected JSON object');
  }
  return value.map((key, value) {
    if (key is! String) {
      throw const FormatException('Expected string key');
    }
    return MapEntry(key, value);
  });
}

List<Object?> _jsonList(Object? value) {
  if (value is! List) {
    throw const FormatException('Expected JSON array');
  }
  return List<Object?>.from(value);
}
