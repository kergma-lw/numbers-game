import 'dart:convert';

import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/game_session.dart';
import 'package:numbers_game/game_core/one_non_zero_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameMode { oneNonZero }

/// User preferences used when a new game is created.
class GameSettings {
  const GameSettings({
    this.mode = GameMode.oneNonZero,
    this.boardSize = 2,
  });

  final GameMode mode;
  final int boardSize;

  Map<String, Object> toJson() => {
        'mode': mode.name,
        'boardSize': boardSize,
      };

  factory GameSettings.fromJson(Map<String, Object?> json) {
    final mode = GameMode.values.where((mode) => mode.name == json['mode']).firstOrNull;
    final boardSize = json['boardSize'];
    if (mode == null || boardSize is! int || boardSize < 1) {
      throw const FormatException('Invalid game settings');
    }
    return GameSettings(mode: mode, boardSize: boardSize);
  }
}

/// The complete state of one resumable game.
class SavedGame {
  const SavedGame({
    required this.settings,
    required this.game,
  });

  static const formatVersion = 1;

  final GameSettings settings;
  final OneNonZeroGame game;

  Map<String, Object> toJson() => {
        'version': formatVersion,
        'settings': settings.toJson(),
        'game': {
          'initialBoard': _boardToJson(game.session.initialBoard),
          'currentBoard': _boardToJson(game.currentBoard),
          'history': game.session.history.map(_boardToJson).toList(),
          'moveCount': game.moveCount,
        },
      };

  factory SavedGame.fromJson(Map<String, Object?> json) {
    if (json['version'] != formatVersion) {
      throw const FormatException('Unsupported saved game version');
    }
    final settings = GameSettings.fromJson(_jsonMap(json['settings']));
    final game = _jsonMap(json['game']);
    final history = _jsonList(game['history']).map(_boardFromJson).toList();
    final moveCount = game['moveCount'];
    if (moveCount is! int || moveCount < 0) {
      throw const FormatException('Invalid move count');
    }
    return SavedGame(
      settings: settings,
      game: OneNonZeroGame.restore(
        session: GameSession.restore(
          initialBoard: _boardFromJson(_jsonMap(game['initialBoard'])),
          currentBoard: _boardFromJson(_jsonMap(game['currentBoard'])),
          history: history,
        ),
        moveCount: moveCount,
      ),
    );
  }
}

abstract interface class GameStateStore {
  Future<GameSettings> loadSettings();
  Future<void> saveSettings(GameSettings settings);
  Future<SavedGame?> loadCurrentGame();
  Future<void> saveCurrentGame(SavedGame game);
  Future<void> clearCurrentGame();
}

class SharedPreferencesGameStateStore implements GameStateStore {
  static const _settingsKey = 'game_settings';
  static const _currentGameKey = 'current_game';

  @override
  Future<GameSettings> loadSettings() async {
    final value = (await SharedPreferences.getInstance()).getString(_settingsKey);
    if (value == null) {
      return const GameSettings();
    }
    try {
      return GameSettings.fromJson(_jsonMap(jsonDecode(value)));
    } on FormatException {
      await (await SharedPreferences.getInstance()).remove(_settingsKey);
      return const GameSettings();
    }
  }

  @override
  Future<void> saveSettings(GameSettings settings) async {
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

OneNonZeroGame newGame(GameSettings settings) {
  switch (settings.mode) {
    case GameMode.oneNonZero:
      final cells = List<List<int>>.generate(
        settings.boardSize,
        (row) => List<int>.generate(
          settings.boardSize,
          (column) => row * settings.boardSize + column + 1,
        ),
      );
      return OneNonZeroGame(Board(cells));
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
