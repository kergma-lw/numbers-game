import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:numbers_game/game_state_store.dart';

const _minimumBoardSize = 2;
const _minimumCellTouchSize = 48.0;
const _cellGap = 4.0;
const _boardHandleSize = 36.0;
const _maximumContentWidth = 420.0;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
  });

  final GameSettings settings;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _boardSize;

  @override
  void initState() {
    super.initState();
    _boardSize = widget.settings.boardSize;
  }

  void _save() {
    Navigator.of(context).pop(GameSettings(
      mode: widget.settings.mode,
      boardSize: _boardSize,
    ));
  }

  int _maximumBoardSize(BuildContext context) {
    final availableBoardWidth = math.min(
          MediaQuery.sizeOf(context).width,
          _maximumContentWidth,
        ) -
        2 * _boardHandleSize;
    return math.max(
      _minimumBoardSize,
      ((availableBoardWidth + _cellGap) / (_minimumCellTouchSize + _cellGap)).floor(),
    );
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
            groupValue: widget.settings.mode,
            onChanged: (_) {},
            child: RadioListTile<GameMode>(
              key: const Key('game-mode-one-non-zero'),
              title: const Text('One non-zero'),
              value: GameMode.oneNonZero,
            ),
          ),
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
