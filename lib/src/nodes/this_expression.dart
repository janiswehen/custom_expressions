part of 'expression.dart';

class ThisExpression extends Expression {
  ThisExpression({required super.token});

  factory ThisExpression.defaultToken() {
    return ThisExpression(token: 'this');
  }

  @override
  ThisExpression copyWithToken({String? token}) {
    return ThisExpression(token: token ?? this.token);
  }
}
