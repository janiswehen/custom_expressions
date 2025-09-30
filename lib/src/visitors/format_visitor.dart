import 'package:petitparser/petitparser.dart';
import 'package:uni_expressions/src/nodes/expression.dart';
import '../parser/join_parser.dart';

import 'visitor.dart';

extension _KeepOptionalParentheses on String {
  String keepOptionalParentheses(String Function(String) innerFormatter) {
    final hasParentheses = startsWith('(') && endsWith(')');
    if (hasParentheses) {
      return '(${innerFormatter(substring(1, length - 1))})';
    }
    return innerFormatter(this);
  }
}

class FormatVisitor with Visitor<void, Null> {
  static FormatVisitor instance = FormatVisitor();

  static void format(Expression node) {
    instance.visitNode(node, null);
  }

  @override
  void visitBinaryExpression(BinaryExpression node, Null extra) {
    node.token = node.token.keepOptionalParentheses((i) => '#l #o #r');

    visitNode(node.left, extra);
    visitNode(node.right, extra);
  }

  @override
  void visitCallExpression(CallExpression node, Null extra) {
    node.token = node.token.keepOptionalParentheses(
      (i) => _callFormatter.parse(i).value,
    );

    visitNode(node.callee, extra);
    for (final argument in node.arguments) {
      visitNode(argument, extra);
    }
  }

  Parser<String> get _callFormatter =>
      (string('#c').trim() &
              string('(').trim() &
              (string('#a') & digit())
                  .join()
                  .plusSeparated(string(',').trim().map((l) => ', '))
                  .map((l) => l.sequential.toList().join())
                  .optionalWith('') &
              string(',').trim().optional().map((l) => '') &
              string(')').trim())
          .join();

  @override
  void visitConditionalExpression(ConditionalExpression node, Null extra) {
    node.token = node.token.keepOptionalParentheses((i) => '#c ? #t : #o');

    visitNode(node.condition, extra);
    visitNode(node.then, extra);
    visitNode(node.otherwise, extra);
  }

  @override
  void visitIdentifier(Identifier node, Null extra) {
    node.token = node.token.trim();
  }

  @override
  void visitIndexExpression(IndexExpression node, Null extra) {
    node.token = node.token.keepOptionalParentheses((i) => '#o[#i]');

    visitNode(node.object, extra);
    visitNode(node.index, extra);
  }

  @override
  void visitLambdaExpression(LambdaExpression node, Null extra) {
    node.token = node.token.keepOptionalParentheses(
      (i) => _lambdaFormatter.parse(i).value,
    );

    for (final argument in node.arguments) {
      visitNode(argument, extra);
    }
    visitNode(node.body, extra);
  }

  Parser<String> get _lambdaFormatter =>
      (string('(').trim() &
              (string('#a') & digit())
                  .join()
                  .plusSeparated(string(',').trim().map((l) => ', '))
                  .map((l) => l.sequential.toList().join())
                  .optionalWith('') &
              string(',').trim().optional().map((l) => '') &
              string(')').trim() &
              string('=>').trim().map((l) => ' => ') &
              string('#b').trim())
          .join();

  @override
  void visitLiteral(Literal node, Null extra) {
    final value = node.value;
    if (value is List) {
      node.token = node.token.keepOptionalParentheses(
        (i) => _arrayFormatter.parse(i).value,
      );
      return;
    }
    if (value is Map) {
      node.token = node.token.keepOptionalParentheses(
        (i) => _mapFormatter.parse(i).value,
      );
      return;
    }
    node.token = node.token.trim();
  }

  Parser<String> get _arrayFormatter =>
      (string('[').trim() &
              (string('#a') & digit())
                  .join()
                  .plusSeparated(string(',').trim().map((l) => ', '))
                  .map((l) => l.sequential.toList().join())
                  .optionalWith('') &
              string(',').trim().optional().map((l) => '') &
              string(']').trim())
          .join();

  Parser<String> get _mapFormatter =>
      (string('{').trim() &
              (digit() &
                      string('{') &
                      string('#k').trim() &
                      string(':').trim().map((l) => ': ') &
                      string('#v').trim() &
                      string('}'))
                  .join()
                  .plusSeparated(string(',').trim().map((l) => ', '))
                  .map((l) => l.sequential.toList().join())
                  .optionalWith('') &
              string(',').trim().optional().map((l) => '') &
              string('}').trim())
          .join();

  @override
  void visitMemberExpression(MemberExpression node, Null extra) {
    node.token = node.token.keepOptionalParentheses((i) => '#o.#p');

    visitNode(node.object, extra);
    visitNode(node.property, extra);
  }

  @override
  void visitThisExpression(ThisExpression node, Null extra) {
    node.token = node.token.trim();
  }

  @override
  void visitUnaryExpression(UnaryExpression node, Null extra) {
    node.token = node.token.keepOptionalParentheses((i) => '#o#t');

    visitNode(node.operand, extra);
  }

  @override
  void visitVariable(Variable node, Null extra) {
    node.token = node.token.trim();
  }
}
