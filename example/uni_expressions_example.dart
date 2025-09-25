import 'package:uni_expressions/uni_expressions.dart';

void main() {
  final context = Context.defaultContext();
  final parser = ExpressionParser(config: context.buildParserConfig());

  final expressionText = '[1, 2, 3].map((x) => x ^ 2)';

  final expression = parser.parse(expressionText);

  print(StringVisitor.visit(expression));

  print(EvaluationVisitor().visitNode(expression, context));
}
