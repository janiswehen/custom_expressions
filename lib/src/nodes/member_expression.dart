part of 'expression.dart';

/// A member expression node.
class MemberExpression extends Expression {
  /// The object of the member expression.
  final Expression object;

  /// The property of the member expression.
  final Identifier property;

  MemberExpression({
    required this.object,
    required this.property,
    required super.token,
  });

  /// Creates a new member expression node with a default token.
  factory MemberExpression.defaultToken({
    required Expression object,
    required Identifier property,
  }) {
    return MemberExpression(object: object, property: property, token: '#o.#p');
  }

  @override
  MemberExpression copyWithToken({String? token}) {
    return MemberExpression(
      object: object,
      property: property,
      token: token ?? this.token,
    );
  }
}
