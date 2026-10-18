import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:numbers_game/game_ui/ambient_formula.dart';

void main() {
  test(
    'generates single-digit atmospheric formulas with approved operators',
    () {
      final random = Random(1);

      for (var index = 0; index < 100; index++) {
        final pair = AmbientFormulaPair.random(random);
        for (final formula in [pair.top, pair.bottom]) {
          expect(formula.left, inInclusiveRange(0, 9));
          expect(formula.right, inInclusiveRange(0, 9));
          expect(formula.operator, anyOf('+', '−', '×'));
          expect(formula.display, matches(RegExp(r'^\d [+−×] \d$')));
        }
      }
    },
  );
}
