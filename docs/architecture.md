# Architecture

The application has two layers.

## Game core

The game core is pure Dart and has no dependency on Flutter or platform APIs.
It owns:

- board state and integer values;
- arithmetic and swap moves;
- move history, undo, and restart;
- win detection for each game mode;
- deterministic random generation when generation is added.

The core must be directly testable without rendering a widget.

## Flutter application

The Flutter layer renders the board, collects touch, mouse, and keyboard input,
and presents feedback such as selection, invalid moves, the move counter, and
the win state. It asks the game core to apply moves and renders the resulting
state.

The same core is used by the web, Android, and iOS targets. Platform-specific
code is introduced only when a platform capability requires it.
