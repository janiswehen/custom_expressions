/// The configuration for the expression parser.
class ParserConfig {
  /// Whether to allow the 'this' keyword.
  final bool allowThis;

  /// Whether to allow lambda expressions.
  final bool allowLambda;

  /// The list of all unary operators.
  final List<String> unaryOperators;

  /// The map of all binary operators. Key is the name of the operator, value is the precedence.
  final Map<String, int> binaryOperators;

  /// Creates a new parser config.
  ///
  /// [allowThis] Whether to allow the 'this' keyword.
  /// [allowLambda] Whether to allow lambda expressions.
  /// [unaryOperators] The list of all unary operators.
  /// [binaryOperators] The map of all binary operators. Key is the name of the operator, value is the precedence.
  const ParserConfig({
    this.allowThis = true,
    this.allowLambda = true,
    this.unaryOperators = const [],
    this.binaryOperators = const {},
  });

  /// Creates a new parser config with some default values.
  const ParserConfig.defaultConfig()
    : this(
        allowThis: true,
        allowLambda: true,
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

  /// Creates a shallow copy of the parser config with some optional values changed.
  ParserConfig copyWith({
    bool? allowThis,
    bool? allowLambda,
    List<String>? unaryOperators,
    Map<String, int>? binaryOperators,
  }) {
    return ParserConfig(
      allowThis: allowThis ?? this.allowThis,
      allowLambda: allowLambda ?? this.allowLambda,
      unaryOperators: unaryOperators ?? this.unaryOperators,
      binaryOperators: binaryOperators ?? this.binaryOperators,
    );
  }

  /// Returns the precedence of the binary operator.
  int precedenceForBinaryOperator(String operator) {
    if (!binaryOperators.containsKey(operator)) {
      throw ArgumentError('Invalid binary operator: $operator');
    }
    return binaryOperators[operator]!;
  }
}
