import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:numbers_game/game_state_store.dart';

const _minimumBoardSize = 2;
const _minimumCellTouchSize = 48.0;
const _cellGap = 4.0;
const _boardHandleSize = 36.0;
const _maximumContentWidth = 420.0;
const _initialValuePresets = [5, 10, 30, 100];

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.settings});

  final AppSettings settings;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late GameMode _selectedMode;
  late int _boardSize;
  late int _maxInitialValue;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.settings.selectedMode;
    _boardSize = widget.settings.oneNonZeroSettings.boardSize;
    _maxInitialValue = widget.settings.oneNonZeroSettings.maxInitialValue;
  }

  void _save() {
    Navigator.of(context).pop(
      AppSettings(
        selectedMode: _selectedMode,
        oneNonZeroSettings: OneNonZeroSettings(
          boardSize: _boardSize,
          maxInitialValue: _maxInitialValue,
        ),
        historicalDateSettings: widget.settings.historicalDateSettings,
      ),
    );
  }

  int _maximumBoardSize(BuildContext context) {
    final availableBoardWidth =
        math.min(MediaQuery.sizeOf(context).width, _maximumContentWidth) -
        2 * _boardHandleSize;
    return math.max(
      _minimumBoardSize,
      ((availableBoardWidth + _cellGap) / (_minimumCellTouchSize + _cellGap))
          .floor(),
    );
  }

  int get _initialValuePresetIndex {
    final index = _initialValuePresets.indexOf(_maxInitialValue);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final maximumBoardSize = _maximumBoardSize(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Game mode', style: Theme.of(context).textTheme.titleMedium),
          RadioGroup<GameMode>(
            groupValue: _selectedMode,
            onChanged: (mode) {
              if (mode != null) {
                setState(() => _selectedMode = mode);
              }
            },
            child: Column(
              children: [
                RadioListTile<GameMode>(
                  key: const Key('game-mode-one-non-zero'),
                  title: const Text('One non-zero'),
                  value: GameMode.oneNonZero,
                ),
                const RadioListTile<GameMode>(
                  key: Key('game-mode-historical-date'),
                  title: Text('Historical date'),
                  subtitle: Text('Restore the date of a known event.'),
                  value: GameMode.historicalDate,
                ),
              ],
            ),
          ),
          if (_selectedMode == GameMode.oneNonZero) ...[
            const SizedBox(height: 24),
            Text('Board size', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  key: const Key('decrease-board-size-button'),
                  tooltip: 'Decrease board size',
                  onPressed: _boardSize > _minimumBoardSize
                      ? () => setState(() => _boardSize--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 96,
                  child: Text(
                    '$_boardSize × $_boardSize',
                    key: const Key('board-size-value'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  key: const Key('increase-board-size-button'),
                  tooltip: 'Increase board size',
                  onPressed: _boardSize < maximumBoardSize
                      ? () => setState(() => _boardSize++)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'The largest size keeps every cell at least 48 dp wide.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Maximum initial value',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  key: const Key('decrease-maximum-initial-value-button'),
                  tooltip: 'Decrease maximum initial value',
                  onPressed: _initialValuePresetIndex > 0
                      ? () => setState(
                          () => _maxInitialValue =
                              _initialValuePresets[_initialValuePresetIndex -
                                  1],
                        )
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 96,
                  child: Text(
                    '$_maxInitialValue',
                    key: const Key('maximum-initial-value-value'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  key: const Key('increase-maximum-initial-value-button'),
                  tooltip: 'Increase maximum initial value',
                  onPressed:
                      _initialValuePresetIndex < _initialValuePresets.length - 1
                      ? () => setState(
                          () => _maxInitialValue =
                              _initialValuePresets[_initialValuePresetIndex +
                                  1],
                        )
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('save-settings-button'),
            onPressed: _save,
            child: const Text('Save settings'),
          ),
        ],
      ),
    );
  }
}
