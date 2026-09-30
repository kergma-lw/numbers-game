# 0001: Use Flutter UI and a Pure Dart Game Core

- Status: accepted
- Date: 2026-09-30

## Context

The first release is a browser prototype, with Android and iOS applications
planned later. The game rules are independent of rendering and input method.

## Decision

Use Flutter for the application interface and keep game rules in a pure Dart
core with no Flutter dependency.

## Consequences

The browser prototype and mobile applications share game logic and its tests.
The interface can provide both drag-and-drop and tap-to-select input without
changing the rules. The core remains suitable for future level generation and
solver experiments.
