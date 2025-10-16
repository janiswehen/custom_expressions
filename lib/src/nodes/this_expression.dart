part of 'expression.dart';

/// A this expression node.
class ThisExpression extends Expression {
  ThisExpression({required super.token});

  /// Creates a new this expression node with a default token.
  factory ThisExpression.defaultToken() {
    return ThisExpression(token: 'this');
  }

  @override
  ThisExpression copyWithToken({String? token}) {
    return ThisExpression(token: token ?? this.token);
  }
}
