import 'expression.dart';

class Literal extends Expression {
  final dynamic value;

  Literal({required this.value, required super.token});

  @override
  Expression copyWithToken({String? token}) {
    return Literal(value: value, token: token ?? this.token);
  }
}
