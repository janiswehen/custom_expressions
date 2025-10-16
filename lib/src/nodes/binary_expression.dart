part of 'expression.dart';

/// A binary expression node.
class BinaryExpression extends Expression {
  /// The left operand of the binary expression.
  final Expression left;

  /// The right operand of the binary expression.
  final Expression right;

  /// The operator of the binary expression.
  final String operator;

  BinaryExpression({
    required this.left,
    required this.right,
    required this.operator,
    required super.token,
  });

  /// Creates a new binary expression node with a default token.
  factory BinaryExpression.defaultToken({
    required Expression left,
    required Expression right,
    required String operator,
  }) {
    return BinaryExpression(
      left: left,
      right: right,
      operator: operator,
      token: '#l #o #r',
    );
  }

  @override
  BinaryExpression copyWithToken({String? token}) {
    return BinaryExpression(
      left: left,
      right: right,
      operator: operator,
      token: token ?? this.token,
    );
  }
}
