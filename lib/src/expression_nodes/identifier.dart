import 'expression.dart';

class Identifier extends Expression {
  final String name;

  Identifier({required this.name, required super.token}) {
    assert(name != 'null');
    assert(name != 'false');
    assert(name != 'true');
    assert(name != 'this');
  }

  @override
  Expression copyWithToken({String? token}) {
    return Identifier(name: name, token: token ?? this.token);
  }
}
