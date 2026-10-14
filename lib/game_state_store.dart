import 'dart:convert';
import 'dart:math';

import 'package:numbers_game/game_core/board.dart';
import 'package:numbers_game/game_core/game_session.dart';
import 'package:numbers_game/game_core/one_non_zero_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameMode { oneNonZero }

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

/// Preferences for the application and each supported game mode.
class AppSettings {
  const AppSettings({
    this.selectedMode = GameMode.oneNonZero,
    this.oneNonZeroSettings = const OneNonZeroSettings(),
  });

  final GameMode selectedMode;
  final OneNonZeroSettings oneNonZeroSettings;

  Map<String, Object> toJson() => {
        'selectedMode': selectedMode.name,
        'modes': {
          GameMode.oneNonZero.name: oneNonZeroSettings.toJson(),
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
          mode != GameMode.oneNonZero || settings is OneNonZeroSettings,
        );

  static const formatVersion = 2;

  final GameMode mode;
  final ModeSettings settings;
  final OneNonZeroGame game;

  Map<String, Object> toJson() => {
        'version': formatVersion,
        'mode': mode.name,
        'settings': _modeSettingsToJson(mode, settings),
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
    return SavedGame(
      mode: mode,
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

Map<String, Object> _modeSettingsToJson(GameMode mode, ModeSettings settings) {
  switch ((mode, settings)) {
    case (GameMode.oneNonZero, OneNonZeroSettings settings):
      return settings.toJson();
    case (GameMode.oneNonZero, _):
      throw ArgumentError.value(settings, 'settings', 'Invalid settings for mode');
  }
}

ModeSettings _modeSettingsFromJson(GameMode mode, Map<String, Object?> json) {
  switch (mode) {
    case GameMode.oneNonZero:
      return OneNonZeroSettings.fromJson(json);
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
