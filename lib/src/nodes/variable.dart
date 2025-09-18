part of 'expression.dart';

class Variable extends Expression {
  final Identifier identifier;

  Variable({required this.identifier, required super.token});

  factory Variable.defaultToken({required Identifier identifier}) {
    return Variable(identifier: identifier, token: '#i');
  }

  @override
  Variable copyWithToken({String? token}) {
    return Variable(identifier: identifier, token: token ?? this.token);
  }
}
