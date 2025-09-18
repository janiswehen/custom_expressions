class ParserConfig {
  final bool allowNull;
  final bool allowThis;
  final List<String> unaryOperators;
  final List<String> binaryOperators;

  const ParserConfig({
    this.allowNull = true,
    this.allowThis = true,
    this.unaryOperators = const [],
    this.binaryOperators = const [],
  });

  const ParserConfig.defaultConfig()
    : this(
        allowNull: true,
        allowThis: true,
        unaryOperators: const ['-', '!', '~', '+'],
        binaryOperators: const [
          '??',
          '||',
          '&&',
          '|',
          '^',
          '&',
          '==',
          '!=',
          '<=',
          '>=',
          '<',
          '>',
          '<<',
          '>>',
          '+',
          '-',
          '*',
          '/',
          '%',
          '~/',
        ],
      );

  int precedenceForBinaryOperator(String operator) {
    if (!binaryOperators.contains(operator)) {
      throw ArgumentError('Invalid binary operator: $operator');
    }
    return binaryOperators.indexOf(operator);
  }
}
