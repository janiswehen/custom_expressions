import '../expressions.dart';

/// A mixin that defines a visitor pattern for the expression tree.
///
/// The [Visitor] mixin provides a generic implementation of the visitor pattern
/// for the expression tree. It defines a method for visiting each type of expression
/// and a method for visiting the entire expression tree.
///
/// The [T] type parameter represents the type of the result of the visit.
/// The [E] type parameter represents the extra context of the visit that is passed up the visitor recursion.
mixin Visitor<T, E> {
  /// Visits a expression node by delegating to the appropriate visit method.
  ///
  /// The [node] parameter is the expression node to visit.
  /// The [extra] parameter is the extra context of the visit that is passed up the visitor recursion.
  ///
  /// The method returns the result of the visit.
  T visitNode(Expression node, E extra) {
    switch (node) {
      case BinaryExpression():
        return visitBinaryExpression(node, extra);
      case CallExpression():
        return visitCallExpression(node, extra);
      case ConditionalExpression():
        return visitConditionalExpression(node, extra);
      case Identifier():
        return visitIdentifier(node, extra);
      case IndexExpression():
        return visitIndexExpression(node, extra);
      case LambdaExpression():
        return visitLambdaExpression(node, extra);
      case Literal():
        return visitLiteral(node, extra);
      case MemberExpression():
        return visitMemberExpression(node, extra);
      case ThisExpression():
        return visitThisExpression(node, extra);
      case UnaryExpression():
        return visitUnaryExpression(node, extra);
      case Variable():
        return visitVariable(node, extra);
    }
  }

  T visitLiteral(Literal node, E extra);
  T visitIdentifier(Identifier node, E extra);
  T visitVariable(Variable node, E extra);
  T visitThisExpression(ThisExpression node, E extra);
  T visitIndexExpression(IndexExpression node, E extra);
  T visitMemberExpression(MemberExpression node, E extra);
  T visitConditionalExpression(ConditionalExpression node, E extra);
  T visitCallExpression(CallExpression node, E extra);
  T visitLambdaExpression(LambdaExpression node, E extra);
  T visitUnaryExpression(UnaryExpression node, E extra);
  T visitBinaryExpression(BinaryExpression node, E extra);
}
