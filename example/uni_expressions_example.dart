import 'package:uni_expressions/uni_expressions.dart';

List<B> map<A, B>(List<A> list, B Function(A) mapFn) =>
    list.map(mapFn).toList().cast<B>();

void main() {
  final context = Context.defaultContext().copyWith(
    variablesAndFunctions: {
      'map': FunctionDefinition(
        name: 'map',
        arguments: [FunctionArgument<Function>()],
        closure: map,
      ),
    },
    memberAccessors: [
      ClassMemberAccessor<List>(
        members: {
          'map': (list) =>
              (mapFn) => map(list, mapFn),
        },
      ),
    ],
  );

  final parser = ExpressionParser(config: context.buildParserConfig());

  final expressionText = 'map([1,2,3,].map(\n(a) => a*a), (a) => 2*a)';

  final expression = parser.parse(expressionText);

  print('Before:');
  print(StringVisitor.visit(expression));

  FormatVisitor.format(expression);
  print('\nAfter formatting:');
  print(StringVisitor.visit(expression));

  print('\nEvaluation:');
  print(EvaluationVisitor().visitNode(expression, context));
}
