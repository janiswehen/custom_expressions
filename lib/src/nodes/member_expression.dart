part of 'expression.dart';

class MemberExpression extends Expression {
  final Expression object;
  final Identifier property;

  MemberExpression({
    required this.object,
    required this.property,
    required super.token,
  });

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
