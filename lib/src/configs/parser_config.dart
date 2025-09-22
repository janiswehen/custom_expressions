class ParserConfig {
  final bool allowThis;
  final List<String> unaryOperators;
  final Map<String, int> binaryOperators;

  const ParserConfig({
    this.allowThis = true,
    this.unaryOperators = const [],
    this.binaryOperators = const {},
  });

  const ParserConfig.defaultConfig()
    : this(
        allowThis: true,
        unaryOperators: const ['-', '!', '~', '+'],
        binaryOperators: const {
          '??': 0,
          '||': 1,
          '&&': 2,
          '|': 3,
          '^': 4,
          '&': 5,
          '==': 6,
          '!=': 7,
          '<=': 8,
          '>=': 9,
          '<': 10,
          '>': 11,
          '<<': 12,
          '>>': 13,
          '+': 14,
          '-': 15,
          '*': 16,
          '/': 17,
          '%': 18,
          '~/': 19,
        },
      );

  ParserConfig copyWith({
    bool? allowThis,
    List<String>? unaryOperators,
    Map<String, int>? binaryOperators,
  }) {
    return ParserConfig(
      allowThis: allowThis ?? this.allowThis,
      unaryOperators: unaryOperators ?? this.unaryOperators,
      binaryOperators: binaryOperators ?? this.binaryOperators,
    );
  }

  int precedenceForBinaryOperator(String operator) {
    if (!binaryOperators.containsKey(operator)) {
      throw ArgumentError('Invalid binary operator: $operator');
    }
    return binaryOperators[operator]!;
  }
}
