import '../expressions.dart';

abstract class Visitor<T> {
  T visitNode(Expression node) {
    switch (node) {
      case Literal():
        return visitLiteral(node);
      case Identifier():
        return visitIdentifier(node);
      case Variable():
        return visitVariable(node);
      case ThisExpression():
        return visitThisExpression(node);
      case IndexExpression():
        return visitIndexExpression(node);
      case MemberExpression():
        return visitMemberExpression(node);
      case ConditionalExpression():
        return visitConditionalExpression(node);
      case CallExpression():
        return visitCallExpression(node);
      case LambdaExpression():
        return visitLambdaExpression(node);
      case UnaryExpression():
        return visitUnaryExpression(node);
      case BinaryExpression():
        return visitBinaryExpression(node);
      default:
        throw UnimplementedError();
    }
  }

  T visitLiteral(Literal node);
  T visitIdentifier(Identifier node);
  T visitVariable(Variable node);
  T visitThisExpression(ThisExpression node);
  T visitIndexExpression(IndexExpression node);
  T visitMemberExpression(MemberExpression node);
  T visitConditionalExpression(ConditionalExpression node);
  T visitCallExpression(CallExpression node);
  T visitLambdaExpression(LambdaExpression node);
  T visitUnaryExpression(UnaryExpression node);
  T visitBinaryExpression(BinaryExpression node);
}
