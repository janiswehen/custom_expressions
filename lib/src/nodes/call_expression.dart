part of 'expression.dart';

/// A call expression node.
class CallExpression extends Expression {
  /// The callee of the call expression.
  final Expression callee;

  /// The arguments of the call expression.
  final List<Expression> arguments;

  CallExpression({
    required this.callee,
    required this.arguments,
    required super.token,
  });

  /// Creates a new call expression node with a default token.
  factory CallExpression.defaultToken({
    required Expression callee,
    required List<Expression> arguments,
  }) {
    return CallExpression(
      callee: callee,
      arguments: arguments,
      token: '#c(${arguments.indexed.map((arg) => '#a${arg.$1}').join(', ')})',
    );
  }

  @override
  CallExpression copyWithToken({String? token}) {
    return CallExpression(
      callee: callee,
      arguments: arguments,
      token: token ?? this.token,
    );
  }
}
