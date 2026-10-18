import 'dart:math';

class AmbientFormula {
  const AmbientFormula({
    required this.left,
    required this.operator,
    required this.right,
  });

  factory AmbientFormula.random(Random random) => AmbientFormula(
    left: random.nextInt(10),
    operator: const ['+', '−', '×'][random.nextInt(3)],
    right: random.nextInt(10),
  );

  final int left;
  final String operator;
  final int right;

  String get display => '$left $operator $right';
}

class AmbientFormulaPair {
  const AmbientFormulaPair({required this.top, required this.bottom});

  factory AmbientFormulaPair.random([Random? random]) {
    final generator = random ?? Random();
    return AmbientFormulaPair(
      top: AmbientFormula.random(generator),
      bottom: AmbientFormula.random(generator),
    );
  }

  final AmbientFormula top;
  final AmbientFormula bottom;
}
