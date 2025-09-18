import 'expression.dart';

class CallExpression extends Expression {
  final Expression callee;
  final List<Expression> arguments;

  CallExpression({
    required this.callee,
    required this.arguments,
    required super.token,
  });

  @override
  Expression copyWithToken({String? token}) {
    return CallExpression(
      callee: callee,
      arguments: arguments,
      token: token ?? this.token,
    );
  }
}
