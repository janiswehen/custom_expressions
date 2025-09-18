import 'expression.dart';
import 'identifier.dart';

class MemberExpression extends Expression {
  final Expression object;
  final Identifier property;

  MemberExpression({
    required this.object,
    required this.property,
    required super.token,
  });

  @override
  Expression copyWithToken({String? token}) {
    return MemberExpression(
      object: object,
      property: property,
      token: token ?? this.token,
    );
  }
}
