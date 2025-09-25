import 'dart:math';
import 'package:test/test.dart';
import 'package:uni_expressions/uni_expressions.dart';

// Custom matcher for evaluation testing
Matcher toEvaluateTo(dynamic expectedValue, {Context? context}) {
  return _EvaluationMatcher(expectedValue, context);
}

class _EvaluationMatcher extends Matcher {
  final dynamic expectedValue;
  final Context context;

  _EvaluationMatcher(this.expectedValue, Context? context)
    : context = context ?? Context.defaultContext();

  @override
  bool matches(Object? item, Map matchState) {
    if (item is! String && item is! Expression) {
      return false;
    }

    late Expression expression;
    try {
      expression = item is String
          ? ExpressionParser(config: context.buildParserConfig()).parse(item)
          : item as Expression;
    } catch (e) {
      return false;
    }

    try {
      final result = EvaluationVisitor.evaluate(expression, context);
      return _deepEquals(result, expectedValue);
    } catch (e) {
      return false;
    }
  }

  bool _deepEquals(dynamic a, dynamic b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) return false;
      }
      return true;
    }

    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final key in a.keys) {
        if (!b.containsKey(key)) return false;
        if (!_deepEquals(a[key], b[key])) return false;
      }
      return true;
    }

    return false;
  }

  @override
  Description describe(Description description) {
    return description.add('should evaluate to $expectedValue');
  }

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! String && item is! Expression) {
      return mismatchDescription.add('is not a string or expression');
    }

    late Expression expression;
    try {
      expression = item is String
          ? ExpressionParser(config: context.buildParserConfig()).parse(item)
          : item as Expression;
    } catch (e) {
      return mismatchDescription.add('fails to parse: $e');
    }

    try {
      final result = EvaluationVisitor.evaluate(expression, context);
      return mismatchDescription.add(
        'evaluates to $result instead of $expectedValue',
      );
    } catch (e) {
      return mismatchDescription.add('fails to evaluate: $e');
    }
  }
}

void main() {
  group('EvaluationVisitor', () {
    group('BinaryExpression Evaluation', () {
      test('should evaluate arithmetic operations', () {
        // Addition
        expect('1 + 2', toEvaluateTo(3));
        expect('3.5 + 2.5', toEvaluateTo(6.0));
        expect('0 + 0', toEvaluateTo(0));

        // Subtraction
        expect('5 - 3', toEvaluateTo(2));
        expect('10.5 - 2.5', toEvaluateTo(8.0));
        expect('0 - 5', toEvaluateTo(-5));

        // Multiplication
        expect('3 * 4', toEvaluateTo(12));
        expect('2.5 * 4', toEvaluateTo(10.0));
        expect('0 * 100', toEvaluateTo(0));

        // Division
        expect('8 / 2', toEvaluateTo(4.0));
        expect('7 / 2', toEvaluateTo(3.5));
        expect('10.0 / 2.5', toEvaluateTo(4.0));

        // Modulo
        expect('7 % 3', toEvaluateTo(1));
        expect('10 % 2', toEvaluateTo(0));
        expect('15 % 4', toEvaluateTo(3));

        // Integer division
        expect('7 ~/ 3', toEvaluateTo(2));
        expect('10 ~/ 2', toEvaluateTo(5));
        expect('15 ~/ 4', toEvaluateTo(3));
      });

      test('should evaluate comparison operations', () {
        // Equality
        expect('5 == 5', toEvaluateTo(true));
        expect('5 == 3', toEvaluateTo(false));
        expect('"hello" == "hello"', toEvaluateTo(true));
        expect('"hello" == "world"', toEvaluateTo(false));
        expect('true == true', toEvaluateTo(true));
        expect('true == false', toEvaluateTo(false));
        expect('null == null', toEvaluateTo(true));

        // Inequality
        expect('5 != 3', toEvaluateTo(true));
        expect('5 != 5', toEvaluateTo(false));
        expect('"hello" != "world"', toEvaluateTo(true));
        expect('"hello" != "hello"', toEvaluateTo(false));

        // Less than
        expect('3 < 5', toEvaluateTo(true));
        expect('5 < 3', toEvaluateTo(false));
        expect('3 < 3', toEvaluateTo(false));
        expect('3.5 < 3.7', toEvaluateTo(true));

        // Greater than
        expect('5 > 3', toEvaluateTo(true));
        expect('3 > 5', toEvaluateTo(false));
        expect('3 > 3', toEvaluateTo(false));
        expect('3.7 > 3.5', toEvaluateTo(true));

        // Less than or equal
        expect('3 <= 5', toEvaluateTo(true));
        expect('3 <= 3', toEvaluateTo(true));
        expect('5 <= 3', toEvaluateTo(false));

        // Greater than or equal
        expect('5 >= 3', toEvaluateTo(true));
        expect('3 >= 3', toEvaluateTo(true));
        expect('3 >= 5', toEvaluateTo(false));
      });

      test('should evaluate logical operations', () {
        // AND
        expect('true && true', toEvaluateTo(true));
        expect('true && false', toEvaluateTo(false));
        expect('false && true', toEvaluateTo(false));
        expect('false && false', toEvaluateTo(false));

        // OR
        expect('true || true', toEvaluateTo(true));
        expect('true || false', toEvaluateTo(true));
        expect('false || true', toEvaluateTo(true));
        expect('false || false', toEvaluateTo(false));
      });

      test('should evaluate bitwise operations', () {
        // AND
        expect('5 & 3', toEvaluateTo(1));
        expect('7 & 3', toEvaluateTo(3));
        expect('0 & 5', toEvaluateTo(0));

        // OR
        expect('5 | 3', toEvaluateTo(7));
        expect('7 | 3', toEvaluateTo(7));
        expect('0 | 5', toEvaluateTo(5));

        // Left shift
        expect('1 << 2', toEvaluateTo(4));
        expect('3 << 1', toEvaluateTo(6));
        expect('0 << 5', toEvaluateTo(0));

        // Right shift
        expect('8 >> 2', toEvaluateTo(2));
        expect('6 >> 1', toEvaluateTo(3));
        expect('0 >> 5', toEvaluateTo(0));
      });

      test('should evaluate null coalescing', () {
        expect('null ?? 5', toEvaluateTo(5));
        expect('3 ?? 5', toEvaluateTo(3));
        expect('"hello" ?? "world"', toEvaluateTo('hello'));
        expect('null ?? "default"', toEvaluateTo('default'));
      });

      test('should handle operator precedence', () {
        // Multiplication before addition
        expect('2 + 3 * 4', toEvaluateTo(14));
        expect('3 * 4 + 2', toEvaluateTo(14));

        // Division before addition
        expect('10 + 8 / 2', toEvaluateTo(14.0));
        expect('8 / 2 + 10', toEvaluateTo(14.0));

        // Parentheses override precedence
        expect('(2 + 3) * 4', toEvaluateTo(20));
        expect('(10 + 8) / 2', toEvaluateTo(9.0));

        // Complex precedence
        expect('2 + 3 * 4 - 1', toEvaluateTo(13));
        expect('(2 + 3) * (4 - 1)', toEvaluateTo(15));
      });

      test('should handle complex nested expressions', () {
        expect('(1 + 2) * (3 + 4)', toEvaluateTo(21));
        expect('(10 - 2) / (2 + 2)', toEvaluateTo(2.0));
        expect('((1 + 2) * 3) + ((4 + 5) * 6)', toEvaluateTo(63));
        expect('(true && false) || (true && true)', toEvaluateTo(true));
        expect('(5 > 3) && (2 < 4)', toEvaluateTo(true));
      });

      test('should handle mixed type operations', () {
        // Numeric operations with mixed int/double
        expect('5 + 2.5', toEvaluateTo(7.5));
        expect('3.5 * 2', toEvaluateTo(7.0));
        expect('10 / 3', toEvaluateTo(3.3333333333333335));

        // Comparison with mixed types
        expect('5 == 5.0', toEvaluateTo(true));
        expect('3 < 3.5', toEvaluateTo(true));
        expect('4.0 > 3', toEvaluateTo(true));
      });

      test('should support custom binary operators', () {
        // Create a context with custom operators
        final customOperators = {
          '**': BinaryOperator(
            name: '**',
            precedence: 11, // Higher than multiplication
            implementation: (left, right) =>
                pow(left as num, (right as num).toInt()),
          ),
          'max': BinaryOperator(
            name: 'max',
            precedence: 12, // Highest precedence
            implementation: (left, right) =>
                (left as num) > (right as num) ? left : right,
          ),
        };

        final context = Context(binaryOperators: customOperators);

        // Test custom power operator
        expect('2 ** 3', toEvaluateTo(8, context: context));
        expect('3 ** 2', toEvaluateTo(9, context: context));

        // Test custom max operator
        expect('5 max 3', toEvaluateTo(5, context: context));
        expect('3 max 7', toEvaluateTo(7, context: context));
      });

      test('should respect custom operator precedence', () {
        // Create operators with custom precedence
        final customOperators = {
          '+': BinaryOperator(
            name: '+',
            precedence: 20, // Very high precedence
            implementation: (left, right) => (left as num) + (right as num),
          ),
          '*': BinaryOperator(
            name: '*',
            precedence: 10, // Lower than +
            implementation: (left, right) => (left as num) * (right as num),
          ),
        };

        final context = Context(binaryOperators: customOperators);

        // With custom precedence, + should be evaluated before *
        expect(
          '2 + 3 * 4',
          toEvaluateTo(20, context: context),
        ); // (2 + 3) * 4 = 20
        expect(
          '3 * 4 + 2',
          toEvaluateTo(18, context: context),
        ); // 3 * (4 + 2) = 18
      });

      test('should build ParserConfig from Context', () {
        final customOperators = {
          '**': BinaryOperator(
            name: '**',
            precedence: 11,
            implementation: (left, right) =>
                pow(left as num, (right as num).toInt()),
          ),
          '+': BinaryOperator(
            name: '+',
            precedence: 9,
            implementation: (left, right) => (left as num) + (right as num),
          ),
          '*': BinaryOperator(
            name: '*',
            precedence: 10,
            implementation: (left, right) => (left as num) * (right as num),
          ),
        };

        final context = Context(
          binaryOperators: customOperators,
          thisValue: ThisValue(value: 42),
        );

        final parserConfig = context.buildParserConfig();

        // Check that operators are sorted by precedence (highest first)
        expect(
          parserConfig.binaryOperators,
          equals({'**': 11, '*': 10, '+': 9}),
        );
        expect(parserConfig.allowThis, isTrue);
      });
    });

    group('CallExpression Evaluation', () {
      test('should call functions with no arguments', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'getValue': FunctionDefinition<int>(
              name: 'getValue',
              arguments: [],
              closure: () => 42,
            ),
            'getString': FunctionDefinition<String>(
              name: 'getString',
              arguments: [],
              closure: () => 'hello',
            ),
          },
        );

        expect('getValue()', toEvaluateTo(42, context: context));
        expect('getString()', toEvaluateTo('hello', context: context));
      });

      test('should call functions with single arguments', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'double': FunctionDefinition<num>(
              name: 'double',
              arguments: [FunctionArgument<num>()],
              closure: (num n) => n * 2,
            ),
            'greet': FunctionDefinition<String>(
              name: 'greet',
              arguments: [FunctionArgument<String>()],
              closure: (String s) => 'Hello, $s!',
            ),
          },
        );

        expect('double(5)', toEvaluateTo(10, context: context));
        expect('double(3.5)', toEvaluateTo(7.0, context: context));
        expect(
          'greet("World")',
          toEvaluateTo('Hello, World!', context: context),
        );
      });

      test('should call functions with multiple arguments', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'add': FunctionDefinition<num>(
              name: 'add',
              arguments: [FunctionArgument<num>(), FunctionArgument<num>()],
              closure: (num n1, num n2) => n1 + n2,
            ),
            'max': FunctionDefinition<num>(
              name: 'max',
              arguments: [FunctionArgument<num>(), FunctionArgument<num>()],
              closure: (num n1, num n2) => n1 > n2 ? n1 : n2,
            ),
            'format': FunctionDefinition<String>(
              name: 'format',
              arguments: [
                FunctionArgument<num>(),
                FunctionArgument<num>(),
                FunctionArgument<num>(),
              ],
              closure: (num n1, num n2, num n3) => '$n1 + $n2 = $n3',
            ),
          },
        );

        expect('add(3, 4)', toEvaluateTo(7, context: context));
        expect('max(10, 5)', toEvaluateTo(10, context: context));
        expect('max(3.5, 7.2)', toEvaluateTo(7.2, context: context));
        expect('format(2, 3, 5)', toEvaluateTo('2 + 3 = 5', context: context));
      });

      test('should call functions with complex argument expressions', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'calculate': FunctionDefinition<num>(
              name: 'calculate',
              arguments: [
                FunctionArgument<num>(),
                FunctionArgument<num>(),
                FunctionArgument<num>(),
              ],
              closure: (num n1, num n2, num n3) => n1 * n2 + n3,
            ),
            'compare': FunctionDefinition<bool>(
              name: 'compare',
              arguments: [FunctionArgument<num>(), FunctionArgument<num>()],
              closure: (num n1, num n2) => n1 > n2,
            ),
          },
        );

        expect('calculate(2 + 3, 4, 1)', toEvaluateTo(21, context: context));
        expect('compare(5 * 2, 3 + 4)', toEvaluateTo(true, context: context));
        expect(
          'calculate((1 + 2) * 3, 2, 1)',
          toEvaluateTo(19, context: context),
        );
      });

      test('should call functions with variables as arguments', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'x': VariableDefinition(name: 'x', value: 5),
            'y': VariableDefinition(name: 'y', value: 3),
            'multiply': FunctionDefinition<num>(
              name: 'multiply',
              arguments: [FunctionArgument<num>(), FunctionArgument<num>()],
              closure: (num n1, num n2) => n1 * n2,
            ),
            'square': FunctionDefinition<num>(
              name: 'square',
              arguments: [FunctionArgument<num>()],
              closure: (num n) => n * n,
            ),
          },
        );

        expect('multiply(x, y)', toEvaluateTo(15, context: context));
        expect('square(x)', toEvaluateTo(25, context: context));
        expect('multiply(x + y, x - y)', toEvaluateTo(16, context: context));
      });

      test('should call functions with nested function calls', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'add': FunctionDefinition<num>(
              name: 'add',
              arguments: [FunctionArgument<num>(), FunctionArgument<num>()],
              closure: (num n1, num n2) => n1 + n2,
            ),
            'multiply': FunctionDefinition<num>(
              name: 'multiply',
              arguments: [FunctionArgument<num>(), FunctionArgument<num>()],
              closure: (num n1, num n2) => n1 * n2,
            ),
            'square': FunctionDefinition<num>(
              name: 'square',
              arguments: [FunctionArgument<num>()],
              closure: (num n) => n * n,
            ),
          },
        );

        expect('add(multiply(2, 3), 4)', toEvaluateTo(10, context: context));
        expect(
          'multiply(add(1, 2), square(3))',
          toEvaluateTo(27, context: context),
        );
        expect('add(add(1, 2), add(3, 4))', toEvaluateTo(10, context: context));
      });

      test('should call functions with different return types', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'getNumber': FunctionDefinition<int>(
              name: 'getNumber',
              arguments: [],
              closure: () => 42,
            ),
            'getString': FunctionDefinition<String>(
              name: 'getString',
              arguments: [],
              closure: () => 'result',
            ),
            'getBoolean': FunctionDefinition<bool>(
              name: 'getBoolean',
              arguments: [],
              closure: () => true,
            ),
            'getList': FunctionDefinition<List<dynamic>>(
              name: 'getList',
              arguments: [],
              closure: () => [1, 2, 3],
            ),
            'getMap': FunctionDefinition<Map<String, String>>(
              name: 'getMap',
              arguments: [],
              closure: () => {'key': 'value'},
            ),
          },
        );

        expect('getNumber()', toEvaluateTo(42, context: context));
        expect('getString()', toEvaluateTo('result', context: context));
        expect('getBoolean()', toEvaluateTo(true, context: context));
        expect('getList()', toEvaluateTo([1, 2, 3], context: context));
        expect('getMap()', toEvaluateTo({'key': 'value'}, context: context));
      });

      test('should throw error when calling non-function', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'notAFunction': VariableDefinition(name: 'notAFunction', value: 42),
          },
        );

        expect(
          () => EvaluationVisitor.evaluate(
            ExpressionParser(
              config: context.buildParserConfig(),
            ).parse('notAFunction()'),
            context,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Cannot call non-function'),
            ),
          ),
        );
      });

      test('should throw error when calling undefined function', () {
        final context = Context.defaultContext();

        expect(
          () => EvaluationVisitor.evaluate(
            ExpressionParser(
              config: context.buildParserConfig(),
            ).parse('undefinedFunction()'),
            context,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Undefined identifier: undefinedFunction'),
            ),
          ),
        );
      });

      test('should handle functions with complex argument evaluation', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'a': VariableDefinition(name: 'a', value: 2),
            'b': VariableDefinition(name: 'b', value: 3),
            'process': FunctionDefinition<num>(
              name: 'process',
              arguments: [
                FunctionArgument<num>(),
                FunctionArgument<num>(),
                FunctionArgument<num>(),
              ],
              closure: (num x, num y, num z) {
                return x * y + z;
              },
            ),
          },
        );

        expect(
          'process(a * 2, b + 1, a + b)',
          toEvaluateTo(21, context: context),
        );
        expect(
          'process((a + b) * 2, a - b, b * a)',
          toEvaluateTo(-4, context: context),
        );
      });

      test('should handle functions returning functions', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'getAdder': FunctionDefinition(
              name: 'getAdder',
              arguments: [],
              closure: (num x) {
                return (num y) => x + y;
              },
            ),
          },
        );
        expect('getAdder(2)(3)', toEvaluateTo(5, context: context));
      });
    });

    group('ConditionalExpression Evaluation', () {
      test('should evaluate simple boolean conditions', () {
        expect('true ? "yes" : "no"', toEvaluateTo('yes'));
        expect('false ? "yes" : "no"', toEvaluateTo('no'));
        expect('true ? 1 : 2', toEvaluateTo(1));
        expect('false ? 1 : 2', toEvaluateTo(2));
      });

      test('should evaluate numeric conditions', () {
        expect('5 ? "positive" : "zero"', toEvaluateTo('positive'));
        expect('0 ? "positive" : "zero"', toEvaluateTo('zero'));
        expect('3.14 ? "pi" : "zero"', toEvaluateTo('pi'));
        expect('0.0 ? "pi" : "zero"', toEvaluateTo('zero'));
      });

      test('should evaluate string conditions', () {
        expect('"hello" ? "non-empty" : "empty"', toEvaluateTo('non-empty'));
        expect('"" ? "non-empty" : "empty"', toEvaluateTo('empty'));
        expect('"world" ? "exists" : "missing"', toEvaluateTo('exists'));
      });

      test('should evaluate null conditions', () {
        expect('null ? "not-null" : "null"', toEvaluateTo('null'));
        expect('null ? 1 : 0', toEvaluateTo(0));
      });

      test('should evaluate array conditions', () {
        expect('[1, 2, 3] ? "non-empty" : "empty"', toEvaluateTo('non-empty'));
        expect('[] ? "non-empty" : "empty"', toEvaluateTo('empty'));
        expect('[1] ? "has-items" : "no-items"', toEvaluateTo('has-items'));
      });

      test('should evaluate map conditions', () {
        expect(
          '{"key": "value"} ? "non-empty" : "empty"',
          toEvaluateTo('non-empty'),
        );
        expect('{} ? "non-empty" : "empty"', toEvaluateTo('empty'));
        expect('{"a": 1} ? "has-keys" : "no-keys"', toEvaluateTo('has-keys'));
      });

      test('should evaluate complex conditions', () {
        expect('5 > 3 ? "greater" : "lesser"', toEvaluateTo('greater'));
        expect('2 + 2 == 4 ? "correct" : "wrong"', toEvaluateTo('correct'));
        expect('10 < 5 ? "true" : "false"', toEvaluateTo('false'));
        expect('(1 + 1) * 2 == 4 ? "math" : "error"', toEvaluateTo('math'));
      });

      test('should evaluate with variables in conditions', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'x': VariableDefinition(name: 'x', value: 10),
            'y': VariableDefinition(name: 'y', value: 5),
            'flag': VariableDefinition(name: 'flag', value: true),
            'name': VariableDefinition(name: 'name', value: 'John'),
          },
        );

        expect(
          'x > y ? "x is greater" : "y is greater"',
          toEvaluateTo('x is greater', context: context),
        );
        expect(
          'flag ? "enabled" : "disabled"',
          toEvaluateTo('enabled', context: context),
        );
        expect(
          'name ? "Hello, " + name : "No name"',
          toEvaluateTo('Hello, John', context: context),
        );
      });

      test('should evaluate with function calls in conditions', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'isEven': FunctionDefinition<bool>(
              name: 'isEven',
              arguments: [FunctionArgument<num>()],
              closure: (num n) => n.toInt() % 2 == 0,
            ),
            'getLength': FunctionDefinition<int>(
              name: 'getLength',
              arguments: [FunctionArgument<String>()],
              closure: (String s) => s.length,
            ),
          },
        );

        expect(
          'isEven(4) ? "even" : "odd"',
          toEvaluateTo('even', context: context),
        );
        expect(
          'isEven(3) ? "even" : "odd"',
          toEvaluateTo('odd', context: context),
        );
        expect(
          'getLength("hello") > 3 ? "long" : "short"',
          toEvaluateTo('long', context: context),
        );
      });

      test('should evaluate nested conditional expressions', () {
        expect('true ? (false ? "a" : "b") : "c"', toEvaluateTo('b'));
        expect('false ? "a" : (true ? "b" : "c")', toEvaluateTo('b'));
        expect(
          '5 > 3 ? (2 > 1 ? "nested-true" : "nested-false") : "outer-false"',
          toEvaluateTo('nested-true'),
        );
      });

      test('should evaluate with different return types', () {
        expect('true ? 42 : "text"', toEvaluateTo(42));
        expect('false ? 42 : "text"', toEvaluateTo('text'));
        expect('1 ? [1, 2, 3] : {"key": "value"}', toEvaluateTo([1, 2, 3]));
        expect(
          '0 ? [1, 2, 3] : {"key": "value"}',
          toEvaluateTo({'key': 'value'}),
        );
      });

      test('should evaluate with complex expressions in branches', () {
        expect('true ? 2 + 3 : 4 * 5', toEvaluateTo(5));
        expect('false ? 2 + 3 : 4 * 5', toEvaluateTo(20));
        expect('5 > 3 ? (10 - 2) * 3 : 2 + 4', toEvaluateTo(24));
        expect('2 > 5 ? (10 - 2) * 3 : 2 + 4', toEvaluateTo(6));
      });

      test('should evaluate with variables in all parts', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'a': VariableDefinition(name: 'a', value: 5),
            'b': VariableDefinition(name: 'b', value: 3),
            'x': VariableDefinition(name: 'x', value: 10),
            'y': VariableDefinition(name: 'y', value: 7),
          },
        );

        expect('a > b ? x : y', toEvaluateTo(10, context: context));
        expect('a < b ? x : y', toEvaluateTo(7, context: context));
        expect(
          '(a + b) > x ? "sum-greater" : "sum-lesser"',
          toEvaluateTo('sum-lesser', context: context),
        );
      });
    });

    group('Identifier Evaluation', () {
      test('should evaluate simple identifier references', () {
        final context = Context(
          variablesAndFunctions: {
            'x': VariableDefinition(name: 'x', value: 42),
            'y': VariableDefinition(name: 'y', value: 'hello'),
            'flag': VariableDefinition(name: 'flag', value: true),
          },
        );

        expect(
          Identifier.defaultToken(name: 'x'),
          toEvaluateTo(42, context: context),
        );
        expect(
          Identifier.defaultToken(name: 'y'),
          toEvaluateTo('hello', context: context),
        );
        expect(
          Identifier.defaultToken(name: 'flag'),
          toEvaluateTo(true, context: context),
        );
      });

      test('should throw error for undefined identifiers', () {
        final context = Context();

        expect(
          () => EvaluationVisitor.evaluate(
            Identifier.defaultToken(name: 'undefinedId'),
            context,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Undefined identifier: undefinedId'),
            ),
          ),
        );
      });

      test('should evaluate function identifiers', () {
        final context = Context(
          variablesAndFunctions: {
            'myFunc': FunctionDefinition(
              name: 'myFunc',
              arguments: [],
              closure: (List<dynamic> args) => 'function result',
            ),
          },
        );

        final result = EvaluationVisitor.evaluate(
          Identifier.defaultToken(name: 'myFunc'),
          context,
        );
        expect(result, isA<Function>());
      });

      test('should handle identifiers with special characters', () {
        final context = Context(
          variablesAndFunctions: {
            '_private': VariableDefinition(name: '_private', value: 'private'),
            'var1': VariableDefinition(name: 'var1', value: 1),
            '\$temp': VariableDefinition(name: '\$temp', value: 'temp'),
          },
        );

        expect(
          Identifier.defaultToken(name: '_private'),
          toEvaluateTo('private', context: context),
        );
        expect(
          Identifier.defaultToken(name: 'var1'),
          toEvaluateTo(1, context: context),
        );
        expect(
          Identifier.defaultToken(name: '\$temp'),
          toEvaluateTo('temp', context: context),
        );
      });
    });

    group('IndexExpression Evaluation', () {
      test('should evaluate array indexing with literal indices', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'arr': VariableDefinition(name: 'arr', value: [10, 20, 30, 40]),
            'emptyArr': VariableDefinition(name: 'emptyArr', value: []),
          },
        );

        expect('arr[0]', toEvaluateTo(10, context: context));
        expect('arr[1]', toEvaluateTo(20, context: context));
        expect('arr[2]', toEvaluateTo(30, context: context));
        expect('arr[3]', toEvaluateTo(40, context: context));
      });

      test('should evaluate array indexing with variable indices', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'arr': VariableDefinition(name: 'arr', value: ['a', 'b', 'c', 'd']),
            'i': VariableDefinition(name: 'i', value: 2),
            'j': VariableDefinition(name: 'j', value: 0),
          },
        );

        expect('arr[i]', toEvaluateTo('c', context: context));
        expect('arr[j]', toEvaluateTo('a', context: context));
        expect('arr[i - 1]', toEvaluateTo('b', context: context));
      });

      test('should evaluate array indexing with complex expressions', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'arr': VariableDefinition(name: 'arr', value: [0, 1, 4, 9, 16, 25]),
            'x': VariableDefinition(name: 'x', value: 2),
            'y': VariableDefinition(name: 'y', value: 1),
          },
        );

        expect('arr[x * 2]', toEvaluateTo(16, context: context));
        expect('arr[x + y]', toEvaluateTo(9, context: context));
        expect('arr[2 * x + y]', toEvaluateTo(25, context: context));
      });

      test('should evaluate map indexing with string keys', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'map': VariableDefinition(
              name: 'map',
              value: {'name': 'John', 'age': 30, 'city': 'NYC'},
            ),
            'key': VariableDefinition(name: 'key', value: 'age'),
          },
        );

        expect('map["name"]', toEvaluateTo('John', context: context));
        expect('map["age"]', toEvaluateTo(30, context: context));
        expect('map["city"]', toEvaluateTo('NYC', context: context));
        expect('map[key]', toEvaluateTo(30, context: context));
      });

      test('should evaluate map indexing with numeric keys', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'map': VariableDefinition(
              name: 'map',
              value: {1: 'one', 2: 'two', 3: 'three'},
            ),
            'num': VariableDefinition(name: 'num', value: 2),
          },
        );

        expect('map[1]', toEvaluateTo('one', context: context));
        expect('map[2]', toEvaluateTo('two', context: context));
        expect('map[num]', toEvaluateTo('two', context: context));
        expect('map[num + 1]', toEvaluateTo('three', context: context));
      });

      test('should evaluate nested indexing', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'matrix': VariableDefinition(
              name: 'matrix',
              value: [
                [1, 2, 3],
                [4, 5, 6],
                [7, 8, 9],
              ],
            ),
            'data': VariableDefinition(
              name: 'data',
              value: {
                'users': ['alice', 'bob', 'charlie'],
                'scores': [95, 87, 92],
              },
            ),
            'row': VariableDefinition(name: 'row', value: 1),
            'col': VariableDefinition(name: 'col', value: 2),
          },
        );

        expect('matrix[0][1]', toEvaluateTo(2, context: context));
        expect('matrix[row][col]', toEvaluateTo(6, context: context));
        expect('data["users"][0]', toEvaluateTo('alice', context: context));
        expect('data["scores"][row]', toEvaluateTo(87, context: context));
      });

      test('should evaluate chained indexing', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'arr': VariableDefinition(
              name: 'arr',
              value: [
                {'x': 1, 'y': 2},
                {'x': 3, 'y': 4},
                {'x': 5, 'y': 6},
              ],
            ),
            'i': VariableDefinition(name: 'i', value: 1),
          },
        );

        expect('arr[0]["x"]', toEvaluateTo(1, context: context));
        expect('arr[i]["y"]', toEvaluateTo(4, context: context));
        expect('arr[2]["x"]', toEvaluateTo(5, context: context));
      });

      test('should evaluate with function calls as indices', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'arr': VariableDefinition(name: 'arr', value: [10, 20, 30, 40, 50]),
            'getIndex': FunctionDefinition<int>(
              name: 'getIndex',
              arguments: [FunctionArgument<num>()],
              closure: (num n) => n.toInt(),
            ),
            'findIndex': FunctionDefinition<int>(
              name: 'findIndex',
              arguments: [FunctionArgument<num>()],
              closure: (num n) => (n * 2).toInt(),
            ),
          },
        );

        expect('arr[getIndex(2)]', toEvaluateTo(30, context: context));
        expect('arr[findIndex(1)]', toEvaluateTo(30, context: context));
      });

      test('should evaluate with conditional expressions as indices', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'arr': VariableDefinition(
              name: 'arr',
              value: ['first', 'second', 'third'],
            ),
            'flag': VariableDefinition(name: 'flag', value: true),
            'x': VariableDefinition(name: 'x', value: 1),
          },
        );

        expect('arr[flag ? 0 : 1]', toEvaluateTo('first', context: context));
        expect('arr[x > 0 ? 1 : 0]', toEvaluateTo('second', context: context));
        expect(
          'arr[flag && x > 0 ? 2 : 0]',
          toEvaluateTo('third', context: context),
        );
      });

      test('should throw error for out of range array index', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'arr': VariableDefinition(name: 'arr', value: [1, 2, 3]),
          },
        );

        expect(
          () => EvaluationVisitor.evaluate(
            ExpressionParser(
              config: context.buildParserConfig(),
            ).parse('arr[5]'),
            context,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('List index 5 out of range'),
            ),
          ),
        );
      });

      test('should throw error for negative array index', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'arr': VariableDefinition(name: 'arr', value: [1, 2, 3]),
            'index': VariableDefinition(name: 'index', value: -1),
          },
        );

        expect(
          () => EvaluationVisitor.evaluate(
            ExpressionParser(
              config: context.buildParserConfig(),
            ).parse('arr[index]'),
            context,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw error for non-integer array index', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'arr': VariableDefinition(name: 'arr', value: [1, 2, 3]),
          },
        );

        expect(
          () => EvaluationVisitor.evaluate(
            ExpressionParser(
              config: context.buildParserConfig(),
            ).parse('arr["0"]'),
            context,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('List index must be an integer'),
            ),
          ),
        );
      });

      test('should return null for missing map key', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'map': VariableDefinition(name: 'map', value: {'a': 1, 'b': 2}),
          },
        );

        expect('map["c"]', toEvaluateTo(null, context: context));
      });

      test('should throw error for indexing non-indexable object', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'str': VariableDefinition(name: 'str', value: 'hello'),
          },
        );

        expect(
          () => EvaluationVisitor.evaluate(
            ExpressionParser(
              config: context.buildParserConfig(),
            ).parse('str[0]'),
            context,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Cannot index into String'),
            ),
          ),
        );
      });
    });

    group('LambdaExpression Evaluation', () {
      test(
        'should evaluate lambda with no arguments and return a function',
        () {
          final context = Context.defaultContext();

          // Evaluate lambda expression - should return a function
          final lambda = EvaluationVisitor.evaluate(
            ExpressionParser(
              config: context.buildParserConfig(),
            ).parse('() => 42'),
            context,
          );
          expect(lambda, isA<Function>());

          // Call the function immediately
          final result = (lambda as Function)();
          expect(result, equals(42));
        },
      );

      test(
        'should evaluate lambda with single argument and return a function',
        () {
          final context = Context.defaultContext();

          // Evaluate lambda expression - should return a function
          final lambda = EvaluationVisitor.evaluate(
            ExpressionParser(
              config: context.buildParserConfig(),
            ).parse('(x) => x * 2'),
            context,
          );
          expect(lambda, isA<Function>());

          // Call the function with arguments
          final result = Function.apply(lambda, [5]);
          expect(result, equals(10));
        },
      );

      test(
        'should evaluate lambda with multiple arguments and return a function',
        () {
          final context = Context.defaultContext();

          // Evaluate lambda expression - should return a function
          final lambda = EvaluationVisitor.evaluate(
            ExpressionParser(
              config: context.buildParserConfig(),
            ).parse('(x, y) => x + y'),
            context,
          );
          expect(lambda, isA<Function>());

          // Call the function with multiple arguments
          final result = Function.apply(lambda, [3, 4]);
          expect(result, equals(7));
        },
      );

      test('should evaluate lambda with variables from parent scope', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'multiplier': VariableDefinition(name: 'multiplier', value: 3),
            'offset': VariableDefinition(name: 'offset', value: 10),
          },
        );

        // Evaluate lambda expression that uses parent scope variables
        final lambda = EvaluationVisitor.evaluate(
          ExpressionParser(
            config: context.buildParserConfig(),
          ).parse('(x) => x * multiplier + offset'),
          context,
        );
        expect(lambda, isA<Function>());

        // Call the function
        final result = Function.apply(lambda, [5]);
        expect(result, equals(25)); // 5 * 3 + 10 = 25
      });

      test('should evaluate lambda with function calls in body', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'square': FunctionDefinition<num>(
              name: 'square',
              arguments: [FunctionArgument<num>()],
              closure: (num x) => x * x,
            ),
          },
        );

        // Evaluate lambda expression that calls a function
        final lambda = EvaluationVisitor.evaluate(
          ExpressionParser(
            config: context.buildParserConfig(),
          ).parse('(x) => square(x) + 1'),
          context,
        );
        expect(lambda, isA<Function>());

        // Call the function
        final result = Function.apply(lambda, [4]);
        expect(result, equals(17)); // 4*4 + 1 = 17
      });

      test('should evaluate lambda with array operations', () {
        final context = Context.defaultContext();

        // Evaluate lambda expression that works with arrays
        final lambda = EvaluationVisitor.evaluate(
          ExpressionParser(
            config: context.buildParserConfig(),
          ).parse('(arr) => arr[0] + arr[1]'),
          context,
        );
        expect(lambda, isA<Function>());

        // Call the function with an array
        final result = Function.apply(lambda, [
          [3, 4],
        ]);
        expect(result, equals(7));
      });

      test('should evaluate lambda with map operations', () {
        final context = Context.defaultContext();

        // Evaluate lambda expression that works with maps
        final lambda = EvaluationVisitor.evaluate(
          ExpressionParser(
            config: context.buildParserConfig(),
          ).parse('(map) => map["x"] + map["y"]'),
          context,
        );
        expect(lambda, isA<Function>());

        // Call the function with a map
        final result = Function.apply(lambda, [
          {'x': 5, 'y': 3},
        ]);
        expect(result, equals(8));
      });

      test('should evaluate nested lambda expressions', () {
        final context = Context.defaultContext();

        // Evaluate outer lambda that returns another lambda
        final outerLambda = EvaluationVisitor.evaluate(
          ExpressionParser(
            config: context.buildParserConfig(),
          ).parse('(x) => (y) => x + y'),
          context,
        );
        expect(outerLambda, isA<Function>());

        // Call outer lambda to get inner lambda
        final innerLambda = Function.apply(outerLambda, [5]);
        expect(innerLambda, isA<Function>());

        // Call inner lambda
        final result = Function.apply(innerLambda, [3]);
        expect(result, equals(8));
      });

      test('should evaluate lambda with different return types', () {
        final context = Context.defaultContext();

        // String return type
        final stringLambda = EvaluationVisitor.evaluate(
          ExpressionParser(
            config: context.buildParserConfig(),
          ).parse('(x) => "Hello " + x'),
          context,
        );
        final stringResult = Function.apply(stringLambda, ["John"]);
        expect(stringResult, equals('Hello John'));

        // Boolean return type
        final boolLambda = EvaluationVisitor.evaluate(
          ExpressionParser(
            config: context.buildParserConfig(),
          ).parse('(x) => x > 0'),
          context,
        );
        final boolResult = Function.apply(boolLambda, [5]);
        expect(boolResult, equals(true));

        // Array return type
        final arrayLambda = EvaluationVisitor.evaluate(
          ExpressionParser(
            config: context.buildParserConfig(),
          ).parse('(x) => [x, x * 2, x * 3]'),
          context,
        );
        final arrayResult = Function.apply(arrayLambda, [3]);
        expect(arrayResult, equals([3, 6, 9]));
      });

      test('should evaluate lambda with many arguments', () {
        final context = Context.defaultContext();

        // Evaluate lambda with 10 arguments
        final lambda = EvaluationVisitor.evaluate(
          ExpressionParser(config: context.buildParserConfig()).parse(
            '(a, b, c, d, e, f, g, h, i, j) => a + b + c + d + e + f + g + h + i + j',
          ),
          context,
        );
        expect(lambda, isA<Function>());

        // Call with 10 arguments
        final result = Function.apply(lambda, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
        expect(result, equals(55));
      });

      test('should throw error for lambda with too many arguments', () {
        // This test would require creating a lambda with more than 10 arguments
        // which would be caught during parsing, but we can test the error handling
        expect(
          () {
            // Create a lambda with 11 arguments programmatically
            final lambda = LambdaExpression(
              arguments: List.generate(
                11,
                (i) => Identifier.defaultToken(name: 'arg$i'),
              ),
              body: Identifier.defaultToken(name: 'arg0'),
              token: 'lambda',
            );
            EvaluationVisitor.evaluate(lambda, Context());
          },
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('more than 10 arguments'),
            ),
          ),
        );
      });

      test('should evaluate lambda with null arguments', () {
        final context = Context.defaultContext();

        // Lambda that handles null arguments
        final lambda = EvaluationVisitor.evaluate(
          ExpressionParser(
            config: context.buildParserConfig(),
          ).parse('(x) => x ?? "default"'),
          context,
        );
        expect(lambda, isA<Function>());

        // Test with null
        final result1 = Function.apply(lambda, [null]);
        expect(result1, equals('default'));

        // Test with value
        final result2 = Function.apply(lambda, ['value']);
        expect(result2, equals('value'));
      });

      test('should evaluate lambda with mixed argument types', () {
        final context = Context.defaultContext();

        // Lambda with mixed argument types
        final lambda = EvaluationVisitor.evaluate(
          ExpressionParser(config: context.buildParserConfig()).parse(
            '(name, age, active) => name + " is " + age + " and " + (active ? "active" : "inactive")',
          ),
          context,
        );
        expect(lambda, isA<Function>());

        // Call with mixed types
        final result = Function.apply(lambda, ['John', "30", true]);
        expect(result, equals('John is 30 and active'));
      });

      test('should evaluate lambda that can be passed to other functions', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'map': FunctionDefinition<List>(
              name: 'map',
              arguments: [
                FunctionArgument<List>(),
                FunctionArgument<Function>(),
              ],
              closure: (List list, Function func) {
                return list.map((item) => func(item)).toList();
              },
            ),
          },
        );

        // Create a lambda that doubles numbers
        expect(
          'map([1, 2, 3, 4, 5], (x) => x * 2)',
          toEvaluateTo([2, 4, 6, 8, 10], context: context),
        );
      });

      test('should evaluate lambda by calling it', () {
        final context = Context.defaultContext();

        final lambdaText = '(a, b) => a > b ? a : b';

        expect('($lambdaText)(10, 5)', toEvaluateTo(10, context: context));
        expect('($lambdaText)(3, 8)', toEvaluateTo(8, context: context));
      });
    });

    group('Literal Evaluation', () {
      test('should evaluate simple primitive literals', () {
        // Test integer literals
        expect('42', toEvaluateTo(42));
        expect('0', toEvaluateTo(0));
        expect('42', toEvaluateTo(42));

        // Test double literals
        expect('3.14', toEvaluateTo(3.14));
        expect('0.0', toEvaluateTo(0.0));
        expect('3.14', toEvaluateTo(3.14));

        // Test boolean literals
        expect('true', toEvaluateTo(true));
        expect('false', toEvaluateTo(false));

        // Test null literal
        expect('null', toEvaluateTo(null));

        // Test string literals
        expect('"hello"', toEvaluateTo('hello'));
        expect("'hello'", toEvaluateTo('hello'));
        expect('""', toEvaluateTo(''));
        expect("''", toEvaluateTo(''));
      });

      test('should evaluate array literals', () {
        expect('[]', toEvaluateTo([]));
        expect('[1]', toEvaluateTo([1]));
        expect('[1, 2, 3]', toEvaluateTo([1, 2, 3]));
        expect(
          '[1, "hello", true, null]',
          toEvaluateTo([1, 'hello', true, null]),
        );
        expect(
          '[[1, 2], [3, 4]]',
          toEvaluateTo([
            [1, 2],
            [3, 4],
          ]),
        );
      });

      test('should evaluate map literals', () {
        expect('{}', toEvaluateTo({}));
        expect('{"a": 1}', toEvaluateTo({'a': 1}));
        expect(
          '{"a": 1, "b": 2, "c": 3}',
          toEvaluateTo({'a': 1, 'b': 2, 'c': 3}),
        );
        expect(
          '{"string": "hello", "number": 42, "boolean": true, "null": null}',
          toEvaluateTo({
            'string': 'hello',
            'number': 42,
            'boolean': true,
            'null': null,
          }),
        );
        expect(
          '{"outer": 1, "inner": {"a": 2, "b": 3}, "end": 4}',
          toEvaluateTo({
            'outer': 1,
            'inner': {'a': 2, 'b': 3},
            'end': 4,
          }),
        );
      });

      test('should handle complex nested structures', () {
        expect(
          '[{"a": 1, "b": 2}, {"c": 3, "d": 4}]',
          toEvaluateTo([
            {'a': 1, 'b': 2},
            {'c': 3, 'd': 4},
          ]),
        );
        expect(
          '{"numbers": [1, 2, 3], "strings": ["a", "b", "c"]}',
          toEvaluateTo({
            'numbers': [1, 2, 3],
            'strings': ['a', 'b', 'c'],
          }),
        );
      });
    });

    group('MemberExpression Evaluation', () {
      test('should access class members', () {
        final obj = _SimpleTestClass(value: 1);
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'obj': VariableDefinition(name: 'obj', value: obj),
          },
          memberAccessors: [
            ClassMemberAccessor<_SimpleTestClass>(
              members: {
                'value': (obj) => obj.value,
                'doubleValue': (obj) => obj.doubleValue,
              },
            ),
          ],
        );

        expect('obj', toEvaluateTo(obj, context: context));
        expect('obj.value', toEvaluateTo(1, context: context));
        expect('obj.doubleValue()', toEvaluateTo(2, context: context));

        expect(
          () => EvaluationVisitor.evaluate(
            ExpressionParser(
              config: context.buildParserConfig(),
            ).parse('obj.foo'),
            context,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should access map members', () {
        final map = {'a': 1, 'b': 2, 'c': 3};
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'map': VariableDefinition(name: 'map', value: map),
          },
          memberAccessors: [MapMemberAccessor(throwOnMissing: false)],
        );

        expect('map', toEvaluateTo(map, context: context));
        expect('map.a', toEvaluateTo(1, context: context));
        expect('map.b', toEvaluateTo(2, context: context));
        expect('map.c', toEvaluateTo(3, context: context));
        expect('map.d', toEvaluateTo(null, context: context));

        final contextWithThrowOnMissing = context.copyWith(
          memberAccessors: [MapMemberAccessor(throwOnMissing: true)],
        );

        expect(
          () => EvaluationVisitor.evaluate(
            ExpressionParser(
              config: contextWithThrowOnMissing.buildParserConfig(),
            ).parse('map.d'),
            contextWithThrowOnMissing,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('ThisExpression Evaluation', () {
      test('should evaluate this expression with simple value', () {
        final context = Context.defaultContext().copyWith(
          thisValue: ThisValue(value: 42),
        );

        expect('this', toEvaluateTo(42, context: context));
      });

      test('should throw error if this is not allowed', () {
        expect(
          () => ExpressionParser(
            config: ParserConfig.defaultConfig().copyWith(allowThis: false),
          ).parse('this'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('UnaryExpression Evaluation', () {
      test('should evaluate unary minus operator', () {
        final context = Context.defaultContext();

        expect('-5', toEvaluateTo(-5, context: context));
        expect('-0', toEvaluateTo(0, context: context));
        expect('-(-5)', toEvaluateTo(5, context: context));
        expect('-3.14', toEvaluateTo(-3.14, context: context));
      });

      test('should evaluate unary plus operator', () {
        final context = Context.defaultContext();

        expect('+5', toEvaluateTo(5, context: context));
        expect('+0', toEvaluateTo(0, context: context));
        expect('+(-5)', toEvaluateTo(-5, context: context));
        expect('+3.14', toEvaluateTo(3.14, context: context));
      });

      test('should evaluate unary not operator', () {
        final context = Context.defaultContext();

        expect('!true', toEvaluateTo(false, context: context));
        expect('!false', toEvaluateTo(true, context: context));
        expect('!!true', toEvaluateTo(true, context: context));
        expect('!!false', toEvaluateTo(false, context: context));
      });

      test('should evaluate unary bitwise not operator', () {
        final context = Context.defaultContext();

        expect('~0', toEvaluateTo(-1, context: context));
        expect('~1', toEvaluateTo(-2, context: context));
        expect('~5', toEvaluateTo(-6, context: context));
        expect('~(-1)', toEvaluateTo(0, context: context));
      });

      test('should evaluate unary operators with variables', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'x': VariableDefinition(name: 'x', value: 10),
            'y': VariableDefinition(name: 'y', value: -3),
            'flag': VariableDefinition(name: 'flag', value: true),
          },
        );

        expect('-x', toEvaluateTo(-10, context: context));
        expect('+y', toEvaluateTo(-3, context: context));
        expect('!flag', toEvaluateTo(false, context: context));
        expect('~x', toEvaluateTo(-11, context: context));
      });

      test('should evaluate unary operators with function calls', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'getValue': FunctionDefinition<num>(
              name: 'getValue',
              arguments: [],
              closure: () => 7,
            ),
            'isTrue': FunctionDefinition<bool>(
              name: 'isTrue',
              arguments: [],
              closure: () => false,
            ),
          },
        );

        expect('-getValue()', toEvaluateTo(-7, context: context));
        expect('+getValue()', toEvaluateTo(7, context: context));
        expect('!isTrue()', toEvaluateTo(true, context: context));
        expect('~getValue()', toEvaluateTo(-8, context: context));
      });

      test('should evaluate unary operators with complex expressions', () {
        final context = Context.defaultContext();

        expect('-(2 + 3)', toEvaluateTo(-5, context: context));
        expect('+(5 * 2)', toEvaluateTo(10, context: context));
        expect('!(5 > 3)', toEvaluateTo(false, context: context));
        expect('~(1 + 2)', toEvaluateTo(-4, context: context));
      });

      test('should evaluate unary operators with conditional expressions', () {
        final context = Context.defaultContext();

        expect('-(true ? 5 : 3)', toEvaluateTo(-5, context: context));
        expect('+(false ? 5 : 3)', toEvaluateTo(3, context: context));
        expect(
          '!(5 > 3 ? true : false)',
          toEvaluateTo(false, context: context),
        );
        expect('~(true ? 1 : 0)', toEvaluateTo(-2, context: context));
      });

      test('should evaluate unary operators with index expressions', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'arr': VariableDefinition(name: 'arr', value: [1, 2, 3, 4, 5]),
            'map': VariableDefinition(name: 'map', value: {'x': 10, 'y': -5}),
          },
        );

        expect('-arr[0]', toEvaluateTo(-1, context: context));
        expect('+arr[2]', toEvaluateTo(3, context: context));
        expect('~arr[1]', toEvaluateTo(-3, context: context));
        expect('-map["x"]', toEvaluateTo(-10, context: context));
        expect('+map["y"]', toEvaluateTo(-5, context: context));
      });

      test('should evaluate unary operators with this expressions', () {
        final context = Context.defaultContext().copyWith(
          thisValue: ThisValue(value: 8),
        );

        expect('-this', toEvaluateTo(-8, context: context));
        expect('+this', toEvaluateTo(8, context: context));
        expect('~this', toEvaluateTo(-9, context: context));
      });

      test('should evaluate unary operators with lambda expressions', () {
        final context = Context.defaultContext();

        // Test unary operations on lambda results
        expect('-(() => 6)()', toEvaluateTo(-6, context: context));
        expect('+(() => 6)()', toEvaluateTo(6, context: context));
        expect('~(() => 6)()', toEvaluateTo(-7, context: context));
      });

      test('should evaluate chained unary operators', () {
        final context = Context.defaultContext();

        expect('--5', toEvaluateTo(5, context: context));
        expect('++5', toEvaluateTo(5, context: context));
        expect('!!true', toEvaluateTo(true, context: context));
        expect('~~5', toEvaluateTo(5, context: context));
        expect('---5', toEvaluateTo(-5, context: context));
        expect('!!!true', toEvaluateTo(false, context: context));
      });

      test('should evaluate unary operators with different data types', () {
        final context = Context.defaultContext();

        // String (should work with + operator)
        expect('+"hello"', toEvaluateTo('hello', context: context));

        // Boolean
        expect('!true', toEvaluateTo(false, context: context));
        expect('!false', toEvaluateTo(true, context: context));
      });

      test('should evaluate unary operators in complex nested expressions', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'x': VariableDefinition(name: 'x', value: 4),
            'y': VariableDefinition(name: 'y', value: 2),
            'isEven': FunctionDefinition<bool>(
              name: 'isEven',
              arguments: [FunctionArgument<num>()],
              closure: (num n) => n % 2 == 0,
            ),
          },
        );

        expect('-(x + y)', toEvaluateTo(-6, context: context));
        expect('+(x * y)', toEvaluateTo(8, context: context));
        expect('!isEven(x)', toEvaluateTo(false, context: context));
        expect('~(x - y)', toEvaluateTo(-3, context: context));
        expect('-(x > y ? x : y)', toEvaluateTo(-4, context: context));
      });

      test('should throw error for unsupported unary operator', () {
        final context = Context.defaultContext().copyWith(
          unaryOperators: {
            '-': UnaryOperator(
              name: '-',
              implementation: (operand) => -operand,
            ),
            // Missing other operators
          },
        );

        expect(
          () => EvaluationVisitor.evaluate(
            ExpressionParser(
              config: context.buildParserConfig(),
            ).parse('!true'),
            context,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Unsupported unary operator: !'),
            ),
          ),
        );
      });

      test('should evaluate unary operators with custom implementations', () {
        final context = Context.defaultContext().copyWith(
          unaryOperators: {
            '-': UnaryOperator(
              name: '-',
              implementation: (operand) => -(operand as num) * 2,
            ),
            '!': UnaryOperator(
              name: '!',
              implementation: (operand) => operand == null,
            ),
            '~': UnaryOperator(
              name: '~',
              implementation: (operand) => (operand as num) + 1,
            ),
            '+': UnaryOperator(
              name: '+',
              implementation: (operand) => (operand as num) * 3,
            ),
          },
        );

        expect('-5', toEvaluateTo(-10, context: context)); // -5 * 2 = -10
        expect(
          '!null',
          toEvaluateTo(true, context: context),
        ); // null == null = true
        expect('~5', toEvaluateTo(6, context: context)); // 5 + 1 = 6
        expect('+5', toEvaluateTo(15, context: context)); // 5 * 3 = 15
      });

      test('should evaluate unary operators with edge cases', () {
        final context = Context.defaultContext();

        // Zero
        expect('-0', toEvaluateTo(0, context: context));
        expect('+0', toEvaluateTo(0, context: context));
        expect('~0', toEvaluateTo(-1, context: context));

        // Large numbers
        expect('-1000000', toEvaluateTo(-1000000, context: context));
        expect('+1000000', toEvaluateTo(1000000, context: context));
        expect('~1000000', toEvaluateTo(-1000001, context: context));

        // Decimal numbers
        expect('-3.14159', toEvaluateTo(-3.14159, context: context));
        expect('+3.14159', toEvaluateTo(3.14159, context: context));
      });
    });

    group('Variable Evaluation', () {
      test('should evaluate simple variable references', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'x': VariableDefinition(name: 'x', value: 42),
            'y': VariableDefinition(name: 'y', value: 'hello'),
            'flag': VariableDefinition(name: 'flag', value: true),
          },
        );

        expect('x', toEvaluateTo(42, context: context));
        expect('y', toEvaluateTo('hello', context: context));
        expect('flag', toEvaluateTo(true, context: context));
      });

      test('should evaluate variables with different types', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'number': VariableDefinition(name: 'number', value: 3.14),
            'string': VariableDefinition(name: 'string', value: 'world'),
            'boolean': VariableDefinition(name: 'boolean', value: false),
            'nullValue': VariableDefinition(name: 'nullValue', value: null),
            'array': VariableDefinition(name: 'array', value: [1, 2, 3]),
            'map': VariableDefinition(name: 'map', value: {'key': 'value'}),
          },
        );

        expect('number', toEvaluateTo(3.14, context: context));
        expect('string', toEvaluateTo('world', context: context));
        expect('boolean', toEvaluateTo(false, context: context));
        expect('nullValue', toEvaluateTo(null, context: context));
        expect('array', toEvaluateTo([1, 2, 3], context: context));
        expect('map', toEvaluateTo({'key': 'value'}, context: context));
      });

      test('should evaluate variables in expressions', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'a': VariableDefinition(name: 'a', value: 5),
            'b': VariableDefinition(name: 'b', value: 3),
            'x': VariableDefinition(name: 'x', value: 10),
            'y': VariableDefinition(name: 'y', value: 2),
          },
        );

        expect('a + b', toEvaluateTo(8, context: context));
        expect('x * y', toEvaluateTo(20, context: context));
        expect('a > b', toEvaluateTo(true, context: context));
        expect('x == y * 5', toEvaluateTo(true, context: context));
      });

      test('should evaluate complex expressions with variables', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'a': VariableDefinition(name: 'a', value: 2),
            'b': VariableDefinition(name: 'b', value: 3),
            'c': VariableDefinition(name: 'c', value: 4),
            'flag': VariableDefinition(name: 'flag', value: true),
          },
        );

        expect('(a + b) * c', toEvaluateTo(20, context: context));
        expect('a * b + c', toEvaluateTo(10, context: context));
        expect('flag && (a < b)', toEvaluateTo(true, context: context));
      });

      test('should throw error for undefined variables', () {
        final context = Context.defaultContext();

        expect(
          () => EvaluationVisitor.evaluate(
            ExpressionParser(
              config: context.buildParserConfig(),
            ).parse('undefinedVar'),
            context,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Undefined identifier: undefinedVar'),
            ),
          ),
        );
      });

      test('should throw error for declared but undefined variables', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'declaredVar': VariableDeclaration(name: 'declaredVar'),
          },
        );

        expect(
          () => EvaluationVisitor.evaluate(
            ExpressionParser(
              config: context.buildParserConfig(),
            ).parse('declaredVar'),
            context,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('declared but not defined'),
            ),
          ),
        );
      });

      test('should evaluate function references', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'myFunction': FunctionDefinition(
              name: 'myFunction',
              arguments: [],
              closure: (List<dynamic> args) => 'function result',
            ),
          },
        );

        // Function references should return the function itself
        final result = EvaluationVisitor.evaluate(
          ExpressionParser(
            config: context.buildParserConfig(),
          ).parse('myFunction'),
          context,
        );
        expect(result, isA<Function>());
      });

      test('should handle variable names with special characters', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            '_private': VariableDefinition(name: '_private', value: 'private'),
            'var1': VariableDefinition(name: 'var1', value: 1),
            'user_name': VariableDefinition(name: 'user_name', value: 'john'),
            '\$temp': VariableDefinition(name: '\$temp', value: 'temporary'),
          },
        );

        expect('_private', toEvaluateTo('private', context: context));
        expect('var1', toEvaluateTo(1, context: context));
        expect('user_name', toEvaluateTo('john', context: context));
        expect('\$temp', toEvaluateTo('temporary', context: context));
      });

      test('should handle case-sensitive variable names', () {
        final context = Context.defaultContext().copyWith(
          variablesAndFunctions: {
            'Name': VariableDefinition(name: 'Name', value: 'John'),
            'name': VariableDefinition(name: 'name', value: 'jane'),
            'NAME': VariableDefinition(name: 'NAME', value: 'DOE'),
          },
        );

        expect('Name', toEvaluateTo('John', context: context));
        expect('name', toEvaluateTo('jane', context: context));
        expect('NAME', toEvaluateTo('DOE', context: context));
      });
    });
  });
}

class _SimpleTestClass {
  final int value;
  _SimpleTestClass({required this.value});

  int doubleValue() {
    return value * 2;
  }
}
