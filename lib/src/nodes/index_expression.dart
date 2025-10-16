part of 'expression.dart';

/// An index expression node.
class IndexExpression extends Expression {
  /// The object of the index expression.
  final Expression object;

  /// The index of the index expression.
  final Expression index;

  IndexExpression({
    required this.object,
    required this.index,
    required super.token,
  });

  /// Creates a new index expression node with a default token.
  factory IndexExpression.defaultToken({
    required Expression object,
    required Expression index,
  }) {
    return IndexExpression(object: object, index: index, token: '#o[#i]');
  }

  @override
  IndexExpression copyWithToken({String? token}) {
    return IndexExpression(
      object: object,
      index: index,
      token: token ?? this.token,
    );
  }
}
