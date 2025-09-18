import '../expressions.dart';
import 'visitor.dart';

class StringVisitor with Visitor<String, Null> {
  static StringVisitor instance = StringVisitor();

  static String visit(Expression node) {
    return instance.visitNode(node, null);
  }

  @override
  String visitBinaryExpression(BinaryExpression node, [extra]) {
    return node.token
        .replaceFirst('#l', visitNode(node.left, null))
        .replaceFirst('#o', node.operator)
        .replaceFirst('#r', visitNode(node.right, null));
  }

  @override
  String visitCallExpression(CallExpression node, [extra]) {
    return node.token
        .replaceFirst('#c', visitNode(node.callee, null))
        .replaceAllMapped(
          RegExp(r'(#a)(\d+)'),
          (match) =>
              visitNode(node.arguments[int.parse(match.group(2)!)], null),
        );
  }

  @override
  String visitConditionalExpression(ConditionalExpression node, [extra]) {
    return node.token
        .replaceFirst('#c', visitNode(node.condition, null))
        .replaceFirst('#t', visitNode(node.then, null))
        .replaceFirst('#o', visitNode(node.otherwise, null));
  }

  @override
  String visitIdentifier(Identifier node, [extra]) {
    return node.token;
  }

  @override
  String visitIndexExpression(IndexExpression node, [extra]) {
    return node.token
        .replaceFirst('#o', visitNode(node.object, null))
        .replaceFirst('#i', visitNode(node.index, null));
  }

  @override
  String visitLambdaExpression(LambdaExpression node, [extra]) {
    return node.token
        .replaceAllMapped(
          RegExp(r'(#a)(\d+)'),
          (match) =>
              visitNode(node.arguments[int.parse(match.group(2)!)], null),
        )
        .replaceFirst('#b', visitNode(node.body, null));
  }

  @override
  String visitLiteral(Literal node, [extra]) {
    if (node.value is List) {
      return node.token.replaceAllMapped(
        RegExp(r'(#a)(\d+)'),
        (match) => visitNode(node.value[int.parse(match.group(2)!)], null),
      );
    } else if (node.value is Map) {
      return node.token.replaceAllMapped(RegExp(r'(\d+){([^{}]+)}'), (match) {
        final index = int.parse(match.group(1)!);
        final token = match.group(2)!;
        return token
            .replaceFirst(
              '#k',
              visitNode(node.value.keys.toList()[index], null),
            )
            .replaceFirst(
              '#v',
              visitNode(node.value.values.toList()[index], null),
            );
      });
    } else {
      return node.token;
    }
  }

  @override
  String visitMemberExpression(MemberExpression node, [extra]) {
    return node.token
        .replaceFirst('#o', visitNode(node.object, null))
        .replaceFirst('#p', visitNode(node.property, null));
  }

  @override
  String visitThisExpression(ThisExpression node, [extra]) {
    return node.token;
  }

  @override
  String visitUnaryExpression(UnaryExpression node, [extra]) {
    return node.token
        .replaceFirst('#o', node.operator)
        .replaceFirst('#t', visitNode(node.operand, null));
  }

  @override
  String visitVariable(Variable node, [extra]) {
    return node.token.replaceFirst('#i', visitNode(node.identifier, null));
  }
}
