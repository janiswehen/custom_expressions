import 'expression.dart';

class Literal extends Expression {
  final dynamic value;

  Literal({required this.value, required super.token});

  @override
  Literal copyWithToken({String? token}) {
    return Literal(value: value, token: token ?? this.token);
  }
}
