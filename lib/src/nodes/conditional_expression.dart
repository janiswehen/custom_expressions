part of 'expression.dart';

/// A conditional expression node.
class ConditionalExpression extends Expression {
  /// The condition of the conditional expression.
  final Expression condition;

  /// The then branch of the conditional expression.
  final Expression then;

  /// The otherwise branch of the conditional expression.
  final Expression otherwise;

  ConditionalExpression({
    required this.condition,
    required this.then,
    required this.otherwise,
    required super.token,
  });

  /// Creates a new conditional expression node with a default token.
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
