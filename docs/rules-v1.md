# Rules for Version 1

## Board

The board is a rectangular grid of integers. Zero and negative values are
valid, and values have no game-level upper or lower bound.

## Moves

Every move costs one turn. There are two kinds of move.

### Arithmetic move

Choose a source cell and a different target cell. The source value does not
change.

- If the target is below the source, replace the target with `source + target`.
- If the target is above the source, replace the target with `source - target`.
- If both cells are in the same row and the target is to the right, replace the
  target with `source + target`.
- If both cells are in the same row and the target is to the left, replace the
  target with `source - target`.

For cells in different rows, the vertical relation decides the operation.

### Swap move

Swap any two rows, or swap any two columns.

## First game mode

The initial mode is **one non-zero cell**. The player wins when exactly one
cell on the board is non-zero. The move counter records the number of turns
taken.

## Interactive tutorial

The application includes an optional tutorial using a fixed small board. It
guides the player through addition, subtraction, and a column swap before a
short winning sequence. The tutorial may be skipped and can be launched again
from normal play.

## Out of scope for Version 1

Version 1 does not include predefined target boards outside the tutorial,
level generation, or shortest-path hints.
