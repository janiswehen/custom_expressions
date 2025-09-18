import 'package:uni_expressions/uni_expressions.dart';

void main() {
  final parser = ExpressionParser();

  final expressionText = '1 + 2 * 3';

  final expression = parser.parse(expressionText);

  print("'${StringVisitor.visit(expression)}'");
}
