import 'expression.dart';

class IndexExpression extends Expression {
  final Expression object;
  final Expression index;

  IndexExpression({
    required this.object,
    required this.index,
    required super.token,
  });

  @override
  IndexExpression copyWithToken({String? token}) {
    return IndexExpression(
      object: object,
      index: index,
      token: token ?? this.token,
    );
  }
}
