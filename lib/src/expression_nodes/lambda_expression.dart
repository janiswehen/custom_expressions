import 'expression.dart';
import 'identifier.dart';

class LambdaExpression extends Expression {
  final Expression body;
  final List<Identifier> arguments;

  LambdaExpression({
    required this.body,
    required this.arguments,
    required super.token,
  });

  @override
  LambdaExpression copyWithToken({String? token}) {
    return LambdaExpression(
      body: body,
      arguments: arguments,
      token: token ?? this.token,
    );
  }
}
