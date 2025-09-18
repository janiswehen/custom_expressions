import 'package:test/test.dart';
import 'package:uni_expressions/uni_expressions.dart';

import '../helpers/match_node.dart';

void main() {
  group('ExpressionParser', () {
    late ExpressionParser parser;

    setUp(() {
      parser = ExpressionParser();
    });

    test('can parse Variables', () {
      expect(
        parser.parse('variable'),
        MatchNode(
          expected: Variable.defaultToken(
            identifier: Identifier.defaultToken(name: 'variable'),
          ),
        ),
      );
    });

    group('can parse Literals', () {
      test('can parse number Literals', () {
        expect(
          parser.parse('14'),
          MatchNode(expected: Literal.defaultToken(value: 14)),
        );
        expect(
          parser.parse('3.14'),
          MatchNode(expected: Literal.defaultToken(value: 3.14)),
        );
      });

      test('can parse String Literals', () {
        expect(
          parser.parse("'Hello, World!'"),
          MatchNode(
            expected: Literal(value: 'Hello, World!', token: "'Hello, World!'"),
          ),
        );
        expect(
          parser.parse('"Hello, World!"'),
          MatchNode(
            expected: Literal(value: 'Hello, World!', token: '"Hello, World!"'),
          ),
        );
      });

      test('can parse boolean Literals', () {
        expect(
          parser.parse('true'),
          MatchNode(expected: Literal.defaultToken(value: true)),
        );
        expect(
          parser.parse('false'),
          MatchNode(expected: Literal.defaultToken(value: false)),
        );
      });

      test('can parse null Literals', () {
        expect(
          parser.parse('null'),
          MatchNode(expected: Literal.defaultToken(value: null)),
        );
      });

      test('can parse array Literals', () {
        expect(
          parser.parse('[1, 2, 3]'),
          MatchNode(
            expected: Literal.defaultToken(
              value: [
                Literal.defaultToken(value: 1),
                Literal.defaultToken(value: 2),
                Literal.defaultToken(value: 3),
              ],
            ),
          ),
        );
      });

      test('can parse map Literals', () {
        expect(
          parser.parse('{"a": 1, "b": 2, "c": 3}'),
          MatchNode(
            expected: Literal.defaultToken(
              value: {
                Literal.defaultToken(value: 'a'): Literal.defaultToken(
                  value: 1,
                ),
                Literal.defaultToken(value: 'b'): Literal.defaultToken(
                  value: 2,
                ),
                Literal.defaultToken(value: 'c'): Literal.defaultToken(
                  value: 3,
                ),
              },
            ),
          ),
        );
      });
    });

    group('can parse Binary Expressions', () {
      test('can parse addition', () {
        expect(
          parser.parse('1 + 2'),
          MatchNode(
            expected: BinaryExpression.defaultToken(
              left: Literal.defaultToken(value: 1),
              right: Literal.defaultToken(value: 2),
              operator: '+',
            ),
          ),
        );
      });

      test('can parse multiplication', () {
        expect(
          parser.parse('1 * 2'),
          MatchNode(
            expected: BinaryExpression.defaultToken(
              left: Literal.defaultToken(value: 1),
              right: Literal.defaultToken(value: 2),
              operator: '*',
            ),
          ),
        );
      });

      test('can parse with multiple operators', () {
        expect(
          parser.parse('1 + 2 * 3'),
          MatchNode(
            expected: BinaryExpression.defaultToken(
              left: Literal.defaultToken(value: 1),
              right: BinaryExpression.defaultToken(
                left: Literal.defaultToken(value: 2),
                right: Literal.defaultToken(value: 3),
                operator: '*',
              ),
              operator: '+',
            ),
          ),
        );
      });
    });

    group('can parse Call Expressions', () {
      test('can parse with no argument', () {
        expect(
          parser.parse('foo()'),
          MatchNode(
            expected: CallExpression.defaultToken(
              callee: Variable.defaultToken(
                identifier: Identifier.defaultToken(name: 'foo'),
              ),
              arguments: [],
            ),
          ),
        );
      });

      test('can parse with multiple arguments', () {
        expect(
          parser.parse('foo(1, 2, 3)'),
          MatchNode(
            expected: CallExpression.defaultToken(
              callee: Variable.defaultToken(
                identifier: Identifier.defaultToken(name: 'foo'),
              ),
              arguments: [
                Literal.defaultToken(value: 1),
                Literal.defaultToken(value: 2),
                Literal.defaultToken(value: 3),
              ],
            ),
          ),
        );
      });
    });

    test('can parse Conditional Expressions', () {
      expect(
        parser.parse('1 ? 2 : 3'),
        MatchNode(
          expected: ConditionalExpression.defaultToken(
            condition: Literal.defaultToken(value: 1),
            then: Literal.defaultToken(value: 2),
            otherwise: Literal.defaultToken(value: 3),
          ),
        ),
      );
    });

    test('can parse Index Expressions', () {
      expect(
        parser.parse('foo[1]'),
        MatchNode(
          expected: IndexExpression.defaultToken(
            object: Variable.defaultToken(
              identifier: Identifier.defaultToken(name: 'foo'),
            ),
            index: Literal.defaultToken(value: 1),
          ),
        ),
      );
    });

    test('can parse Lambda Expressions', () {
      expect(
        parser.parse('(a, b) => a + b'),
        MatchNode(
          expected: LambdaExpression.defaultToken(
            body: BinaryExpression.defaultToken(
              left: Variable.defaultToken(
                identifier: Identifier.defaultToken(name: 'a'),
              ),
              right: Variable.defaultToken(
                identifier: Identifier.defaultToken(name: 'b'),
              ),
              operator: '+',
            ),
            arguments: [
              Identifier.defaultToken(name: 'a'),
              Identifier.defaultToken(name: 'b'),
            ],
          ),
        ),
      );
    });

    test('can parse Member Expressions', () {
      expect(
        parser.parse('foo.bar'),
        MatchNode(
          expected: MemberExpression.defaultToken(
            object: Variable.defaultToken(
              identifier: Identifier.defaultToken(name: 'foo'),
            ),
            property: Identifier.defaultToken(name: 'bar'),
          ),
        ),
      );
    });

    test('can parse This Expressions', () {
      expect(
        parser.parse('this'),
        MatchNode(expected: ThisExpression.defaultToken()),
      );
    });

    test('can parse Unary Expressions', () {
      expect(
        parser.parse('!1'),
        MatchNode(
          expected: UnaryExpression.defaultToken(
            operand: Literal.defaultToken(value: 1),
            operator: '!',
          ),
        ),
      );
    });
  });
}
