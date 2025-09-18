part of 'expression.dart';

class LambdaExpression extends Expression {
  final Expression body;
  final List<Identifier> arguments;

  LambdaExpression({
    required this.body,
    required this.arguments,
    required super.token,
  });

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
