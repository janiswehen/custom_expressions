import 'expression.dart';

class ThisExpression extends Expression {
  ThisExpression({required super.token});

  @override
  ThisExpression copyWithToken({String? token}) {
    return ThisExpression(token: token ?? this.token);
  }
}
