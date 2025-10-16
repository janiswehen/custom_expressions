part 'binary_expression.dart';
part 'call_expression.dart';
part 'conditional_expression.dart';
part 'identifier.dart';
part 'index_expression.dart';
part 'lambda_expression.dart';
part 'literal.dart';
part 'member_expression.dart';
part 'this_expression.dart';
part 'unary_expression.dart';
part 'variable.dart';

/// A base class for all expression nodes.
sealed class Expression {
  /// The token that represents the expression.
  /// Used to retrieve the original string expression and to format the expression.
  String token;

  Expression({required this.token});

  /// Creates a shallow copy of the expression with the token changed.
  Expression copyWithToken({String? token});
}
