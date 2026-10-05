# Numbers Game

Numbers Game is a number-grid puzzle. A move copies one cell's value into a
different cell through addition or subtraction, while leaving the source cell
unchanged. Rows and columns can also be swapped.

The first playable mode asks the player to leave exactly one non-zero cell on
the board. See [the rules for version 1](docs/rules-v1.md).

## Status

The repository contains a playable Flutter application for web, Android, and
iOS. It supports arithmetic moves, row and column swaps, undo, restart, and a
short interactive tutorial.

## Run the web scaffold

Install Flutter, then run:

```sh
flutter run -d chrome
```

## Documentation

- [Rules for version 1](docs/rules-v1.md)
- [Architecture](docs/architecture.md)
- [Decision 0001: Flutter UI and a pure Dart game core](docs/decisions/0001-flutter-and-pure-dart-core.md)
