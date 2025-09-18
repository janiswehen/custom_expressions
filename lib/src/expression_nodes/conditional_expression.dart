import 'expression.dart';

class ConditionalExpression extends Expression {
  final Expression condition;
  final Expression then;
  final Expression otherwise;

  ConditionalExpression({
    required this.condition,
    required this.then,
    required this.otherwise,
    required super.token,
  });

  @override
  Expression copyWithToken({String? token}) {
    return ConditionalExpression(
      condition: condition,
      then: then,
      otherwise: otherwise,
      token: token ?? this.token,
    );
  }
}
