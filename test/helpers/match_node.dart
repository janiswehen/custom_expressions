import 'package:test/test.dart';
import 'package:uni_expressions/uni_expressions.dart';

typedef _Extra = ({Expression? expression});

class MatchNode extends Matcher with Visitor<bool, _Extra> {
  final Expression expected;
  final bool ignoreToken;

  MatchNode({required this.expected, this.ignoreToken = false});

  @override
  bool matches(Object? item, Map matchState) {
    if (item is! Expression) {
      return false;
    }
    return visitNode(item, (expression: expected));
  }

  @override
  Description describe(Description description) {
    return description.add('Does match expected node.');
  }

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! Expression) {
      return mismatchDescription.add('Isn\'t and expression node.');
    }
    return mismatchDescription.add('Doesn\'t match expected node.');
  }

  bool matchToken(Expression node, Expression expected) {
    return ignoreToken || node.token == expected.token;
  }

  @override
  bool visitBinaryExpression(BinaryExpression node, extra) {
    final expected = extra.expression;

    if (expected is! BinaryExpression) {
      return false;
    }
    return matchToken(node, expected) &&
        node.operator == expected.operator &&
        visitNode(node.left, (expression: expected.left)) &&
        visitNode(node.right, (expression: expected.right));
  }

  @override
  bool visitCallExpression(CallExpression node, extra) {
    final expected = extra.expression;

    if (expected is! CallExpression) {
      return false;
    }
    return matchToken(node, expected) &&
        visitNode(node.callee, (expression: expected.callee)) &&
        node.arguments.length == expected.arguments.length &&
        node.arguments.indexed.every(
          (arg) => visitNode(arg.$2, (expression: expected.arguments[arg.$1])),
        );
  }

  @override
  bool visitConditionalExpression(ConditionalExpression node, extra) {
    final expected = extra.expression;

    if (expected is! ConditionalExpression) {
      return false;
    }
    return matchToken(node, expected) &&
        visitNode(node.condition, (expression: expected.condition)) &&
        visitNode(node.then, (expression: expected.then)) &&
        visitNode(node.otherwise, (expression: expected.otherwise));
  }

  @override
  bool visitIdentifier(Identifier node, extra) {
    final expected = extra.expression;

    if (expected is! Identifier) {
      return false;
    }
    return matchToken(node, expected) && node.name == expected.name;
  }

  @override
  bool visitIndexExpression(IndexExpression node, extra) {
    final expected = extra.expression;

    if (expected is! IndexExpression) {
      return false;
    }
    return matchToken(node, expected) &&
        visitNode(node.object, (expression: expected.object)) &&
        visitNode(node.index, (expression: expected.index));
  }

  @override
  bool visitLambdaExpression(LambdaExpression node, extra) {
    final expected = extra.expression;

    if (expected is! LambdaExpression) {
      return false;
    }
    return matchToken(node, expected) &&
        visitNode(node.body, (expression: expected.body)) &&
        node.arguments.length == expected.arguments.length &&
        node.arguments.indexed.every(
          (arg) => visitNode(arg.$2, (expression: expected.arguments[arg.$1])),
        );
  }

  @override
  bool visitLiteral(Literal node, extra) {
    final expected = extra.expression;
    final nodeValue = node.value;

    if (expected is! Literal) {
      return false;
    }
    final expectedValue = expected.value;
    if (!matchToken(node, expected)) {
      return false;
    }

    if (nodeValue is List) {
      return expectedValue is List &&
          nodeValue.length == expectedValue.length &&
          nodeValue.indexed.every(
            (e) => visitNode(e.$2, (expression: expectedValue[e.$1])),
          );
    }
    if (nodeValue is Map) {
      return expectedValue is Map &&
          nodeValue.entries.length == expectedValue.entries.length &&
          nodeValue.entries.indexed.every(
            (e) =>
                visitNode(e.$2.key, (
                  expression: expectedValue.entries.toList()[e.$1].key,
                )) &&
                visitNode(e.$2.value, (
                  expression: expectedValue.entries.toList()[e.$1].value,
                )),
          );
    }
    return node.value == expected.value;
  }

  @override
  bool visitMemberExpression(MemberExpression node, extra) {
    final expected = extra.expression;

    if (expected is! MemberExpression) {
      return false;
    }
    return matchToken(node, expected) &&
        visitNode(node.object, (expression: expected.object)) &&
        visitNode(node.property, (expression: expected.property));
  }

  @override
  bool visitThisExpression(ThisExpression node, extra) {
    final expected = extra.expression;

    if (expected is! ThisExpression) {
      return false;
    }
    return matchToken(node, expected);
  }

  @override
  bool visitUnaryExpression(UnaryExpression node, extra) {
    final expected = extra.expression;

    if (expected is! UnaryExpression) {
      return false;
    }
    return matchToken(node, expected) &&
        node.operator == expected.operator &&
        visitNode(node.operand, (expression: expected.operand));
  }

  @override
  bool visitVariable(Variable node, extra) {
    final expected = extra.expression;

    if (expected is! Variable) {
      return false;
    }
    return matchToken(node, expected) &&
        visitNode(node.identifier, (expression: expected.identifier));
  }
}
