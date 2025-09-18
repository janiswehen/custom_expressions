import 'package:uni_expressions/uni_expressions.dart';

void main() {
  final parser = ExpressionParser();

  final expressionText = '';

  final expression = parser.parse(expressionText);

  print("'${StringVisitor.visit(expression)}'");
}
