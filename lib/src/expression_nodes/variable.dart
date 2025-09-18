import 'expression.dart';
import 'identifier.dart';

class Variable extends Expression {
  final Identifier identifier;

  Variable({required this.identifier, required super.token});

  @override
  Variable copyWithToken({String? token}) {
    return Variable(identifier: identifier, token: token ?? this.token);
  }
}
