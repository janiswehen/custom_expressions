import 'expression.dart';

class BinaryExpression extends Expression {
  final Expression left;
  final Expression right;
  final String operator;

  BinaryExpression({
    required this.left,
    required this.right,
    required this.operator,
    required super.token,
  });

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
