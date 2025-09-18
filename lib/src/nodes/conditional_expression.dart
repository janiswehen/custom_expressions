part of 'expression.dart';

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

  factory ConditionalExpression.defaultToken({
    required Expression condition,
    required Expression then,
    required Expression otherwise,
  }) {
    return ConditionalExpression(
      condition: condition,
      then: then,
      otherwise: otherwise,
      token: '#c ? #t : #o',
    );
  }

  @override
  ConditionalExpression copyWithToken({String? token}) {
    return ConditionalExpression(
      condition: condition,
      then: then,
      otherwise: otherwise,
      token: token ?? this.token,
    );
  }
}
