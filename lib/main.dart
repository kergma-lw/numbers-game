import 'package:flutter/material.dart';
import 'package:numbers_game/game_core/board.dart';

void main() {
  runApp(const NumbersGameApp());
}

class NumbersGameApp extends StatelessWidget {
  const NumbersGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Numbers Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const BoardScreen(),
    );
  }
}

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  Board _board = Board([
    [1, 2],
    [3, 4],
  ]);
  CellPosition? _source;
  String _feedback = 'Select a source cell.';

  void _selectCell(CellPosition position) {
    final source = _source;
    if (source == null) {
      setState(() {
        _source = position;
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
      _board = _board.applyArithmeticMove(source: source, target: position);
      _source = null;
      _feedback = 'Move applied.';
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(height: 24),
                    GridView.count(
                      crossAxisCount: _board.columnCount,
                      shrinkWrap: true,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: [
                        for (var row = 0; row < _board.rowCount; row++)
                          for (var column = 0;
                              column < _board.columnCount;
                              column++)
                            _BoardCell(
                              position: CellPosition(row, column),
                              value:
                                  _board.valueAt(CellPosition(row, column)),
                              selected: _source == CellPosition(row, column),
                              onPressed: _selectCell,
                            ),
                      ],
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
}

class _BoardCell extends StatelessWidget {
  const _BoardCell({
    required this.position,
    required this.value,
    required this.selected,
    required this.onPressed,
  });

  final CellPosition position;
  final int value;
  final bool selected;
  final ValueChanged<CellPosition> onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Cell ${position.row + 1}, ${position.column + 1}: $value',
      child: OutlinedButton(
        key: Key('cell-${position.row}-${position.column}'),
        style: OutlinedButton.styleFrom(
          backgroundColor: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          padding: const EdgeInsets.all(8),
        ),
        onPressed: () => onPressed(position),
        child: Text('$value', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
