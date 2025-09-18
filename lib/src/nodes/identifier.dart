part of 'expression.dart';

class Identifier extends Expression {
  final String name;

  Identifier({required this.name, required super.token}) {
    assert(name != 'null');
    assert(name != 'false');
    assert(name != 'true');
    assert(name != 'this');
  }

  factory Identifier.defaultToken({required String name}) {
    return Identifier(name: name, token: name);
  }

  @override
  Identifier copyWithToken({String? token}) {
    return Identifier(name: name, token: token ?? this.token);
  }
}
