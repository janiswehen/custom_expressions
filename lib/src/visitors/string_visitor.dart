import '../expressions.dart';
import 'visitor.dart';

class StringVisitor extends Visitor<String> {
  static StringVisitor instance = StringVisitor();

  static String visit(Expression node) {
    return instance.visitNode(node);
  }

  @override
  String visitLiteral(Literal node) {
    if (node.value is List) {
      return node.token.replaceAllMapped(
        RegExp(r'(#a)(\d+)'),
        (match) => visitNode(node.value[int.parse(match.group(2)!)]),
      );
    } else if (node.value is Map) {
      return node.token.replaceAllMapped(RegExp(r'(\d+){([^{}]+)}'), (match) {
        final index = int.parse(match.group(1)!);
        final token = match.group(2)!;
        return token
            .replaceFirst('#k', visitNode(node.value.keys.toList()[index]))
            .replaceFirst('#v', visitNode(node.value.values.toList()[index]));
      });
    } else {
      return node.token;
    }
  }

  @override
  String visitIdentifier(Identifier node) {
    return node.token;
  }

  @override
  String visitVariable(Variable node) {
    return node.token.replaceFirst('#', visitNode(node.identifier));
  }

  @override
  String visitThisExpression(ThisExpression node) {
    return node.token;
  }

  @override
  String visitIndexExpression(IndexExpression node) {
    return node.token
        .replaceFirst('#o', visitNode(node.object))
        .replaceFirst('#i', visitNode(node.index));
  }

  @override
  String visitMemberExpression(MemberExpression node) {
    return node.token
        .replaceFirst('#o', visitNode(node.object))
        .replaceFirst('#p', visitNode(node.property));
  }

  @override
  String visitConditionalExpression(ConditionalExpression node) {
    return node.token
        .replaceFirst('#c', visitNode(node.condition))
        .replaceFirst('#t', visitNode(node.then))
        .replaceFirst('#o', visitNode(node.otherwise));
  }

  @override
  String visitCallExpression(CallExpression node) {
    return node.token
        .replaceFirst('#c', visitNode(node.callee))
        .replaceAllMapped(
          RegExp(r'(#a)(\d+)'),
          (match) => visitNode(node.arguments[int.parse(match.group(0)!)]),
        );
  }

  @override
  String visitLambdaExpression(LambdaExpression node) {
    return node.token
        .replaceAllMapped(
          RegExp(r'(#a)(\d+)'),
          (match) => visitNode(node.arguments[int.parse(match.group(2)!)]),
        )
        .replaceFirst('#b', visitNode(node.body));
  }

  @override
  String visitUnaryExpression(UnaryExpression node) {
    return node.token
        .replaceFirst('#o', node.operator)
        .replaceFirst('#t', visitNode(node.operand));
  }

  @override
  String visitBinaryExpression(BinaryExpression node) {
    return node.token
        .replaceFirst('#l', visitNode(node.left))
        .replaceFirst('#o', node.operator)
        .replaceFirst('#r', visitNode(node.right));
  }
}
