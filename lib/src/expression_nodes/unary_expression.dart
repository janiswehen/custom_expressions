import 'expression.dart';

class UnaryExpression extends Expression {
  final Expression operand;
  final String operator;

  UnaryExpression({
    required this.operand,
    required this.operator,
    required super.token,
  });

  @override
  UnaryExpression copyWithToken({String? token}) {
    return UnaryExpression(
      operand: operand,
      operator: operator,
      token: token ?? this.token,
    );
  }
}
