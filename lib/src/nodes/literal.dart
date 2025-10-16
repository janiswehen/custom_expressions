part of 'expression.dart';

/// A literal node.
class Literal extends Expression {
  /// The value of the literal.
  final dynamic value;

  Literal({required this.value, required super.token});

  /// Creates a new literal node with a default token.
  factory Literal.defaultToken({required dynamic value}) {
    if (value is List) {
      return Literal(
        value: value,
        token: '[${value.indexed.map((e) => '#a${e.$1}').join(', ')}]',
      );
    }
    if (value is Map) {
      return Literal(
        value: value,
        token:
            '{${value.entries.indexed.map((e) => '${e.$1}{#k: #v}').join(', ')}}',
      );
    }
    if (value is String) {
      return Literal(value: value, token: '"$value"');
    }
    return Literal(value: value, token: value.toString());
  }

  @override
  Literal copyWithToken({String? token}) {
    return Literal(value: value, token: token ?? this.token);
  }
}
