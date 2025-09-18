part of 'expression.dart';

class UnaryExpression extends Expression {
  final Expression operand;
  final String operator;

  UnaryExpression({
    required this.operand,
    required this.operator,
    required super.token,
  });

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
