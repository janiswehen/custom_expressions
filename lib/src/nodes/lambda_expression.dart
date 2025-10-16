part of 'expression.dart';

/// A lambda expression node.
class LambdaExpression extends Expression {
  /// The body of the lambda expression.
  final Expression body;

  /// The arguments of the lambda expression.
  final List<Identifier> arguments;

  LambdaExpression({
    required this.body,
    required this.arguments,
    required super.token,
  });

  /// Creates a new lambda expression node with a default token.
  factory LambdaExpression.defaultToken({
    required Expression body,
    required List<Identifier> arguments,
  }) {
    return LambdaExpression(
      body: body,
      arguments: arguments,
      token:
          '(${arguments.indexed.map((arg) => '#a${arg.$1}').join(', ')}) => #b',
    );
  }

  @override
  LambdaExpression copyWithToken({String? token}) {
    return LambdaExpression(
      body: body,
      arguments: arguments,
      token: token ?? this.token,
    );
  }
}
