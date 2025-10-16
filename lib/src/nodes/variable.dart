part of 'expression.dart';

/// A variable node.
class Variable extends Expression {
  /// The identifier of the variable.
  final Identifier identifier;

  Variable({required this.identifier, required super.token});

  /// Creates a new variable node with a default token.
  factory Variable.defaultToken({required Identifier identifier}) {
    return Variable(identifier: identifier, token: '#i');
  }

  @override
  Variable copyWithToken({String? token}) {
    return Variable(identifier: identifier, token: token ?? this.token);
  }
}
