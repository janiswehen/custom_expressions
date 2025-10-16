part of 'expression.dart';

/// An identifier node.
class Identifier extends Expression {
  /// The name of the identifier.
  final String name;

  Identifier({required this.name, required super.token});

  /// Creates a new identifier node with a default token.
  factory Identifier.defaultToken({required String name}) {
    return Identifier(name: name, token: name);
  }

  @override
  Identifier copyWithToken({String? token}) {
    return Identifier(name: name, token: token ?? this.token);
  }
}
