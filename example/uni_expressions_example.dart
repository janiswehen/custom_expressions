import 'package:uni_expressions/uni_expressions.dart';

void main() {
  final context = Context.defaultContext().copyWith(
    memberAccessors: [
      ClassMemberAccessor<List>(
        members: {
          'reduce': (list) =>
              (reduceFn) => list.reduce(reduceFn),
        },
      ),
    ],
  );

  final parser = ExpressionParser(config: context.buildParserConfig());

  final expressionText = '[1,2,3].reduce(\n(a, b) => a *b)';

  final expression = parser.parse(expressionText);

  print('Before:');
  print(StringVisitor.visit(expression));

  FormatVisitor.format(expression);
  print('\nAfter formatting:');
  print(StringVisitor.visit(expression));

  print('\nEvaluation:');
  print(EvaluationVisitor().visitNode(expression, context));
}
