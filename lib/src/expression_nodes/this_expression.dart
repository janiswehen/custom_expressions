import 'expression.dart';

class ThisExpression extends Expression {
  ThisExpression({required super.token});

  @override
  Expression copyWithToken({String? token}) {
    return ThisExpression(token: token ?? this.token);
  }
}
