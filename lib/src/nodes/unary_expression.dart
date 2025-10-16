part of 'expression.dart';

/// A unary expression node.
class UnaryExpression extends Expression {
  /// The operand of the unary expression.
  final Expression operand;

  /// The operator of the unary expression.
  final String operator;

  UnaryExpression({
    required this.operand,
    required this.operator,
    required super.token,
  });

  /// Creates a new unary expression node with a default token.
  factory UnaryExpression.defaultToken({
    required Expression operand,
    required String operator,
  }) {
    return UnaryExpression(operand: operand, operator: operator, token: '#o#t');
  }

  @override
  UnaryExpression copyWithToken({String? token}) {
    return UnaryExpression(
      operand: operand,
      operator: operator,
      token: token ?? this.token,
    );
  }
}
