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

sealed class Expression {
  String token;

  Expression({required this.token});

  Expression copyWithToken({String? token});
}
