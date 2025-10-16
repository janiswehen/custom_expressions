import '../configs.dart';
import '../expressions.dart';
import 'visitor.dart';

/// The [EvaluationVisitor] class is a visitor that evaluates the expression tree.
class EvaluationVisitor with Visitor<dynamic, Context> {
  /// Evaluates the expression tree.
  ///
  /// [node] The expression tree to evaluate.
  /// [extra] The context used for evaluation.
  ///
  /// Returns the result of the evaluation.
  static dynamic evaluate(Expression node, Context extra) {
    return EvaluationVisitor().visitNode(node, extra);
  }

  @override
  visitBinaryExpression(BinaryExpression node, Context extra) {
    final leftValue = visitNode(node.left, extra);
    final rightValue = visitNode(node.right, extra);

    final operator = extra.binaryOperators[node.operator];
    if (operator == null) {
      throw Exception('Unsupported binary operator: ${node.operator}');
    }

    return operator.implementation(leftValue, rightValue);
  }

  @override
  visitCallExpression(CallExpression node, Context extra) {
    final callee = visitNode(node.callee, extra);

    if (callee is! Function) {
      throw Exception('Cannot call non-function: ${node.callee}');
    }

    final arguments = node.arguments
        .map((arg) => visitNode(arg, extra))
        .toList();

    return Function.apply(callee, arguments);
  }

  @override
  visitConditionalExpression(ConditionalExpression node, Context extra) {
    final condition = visitNode(node.condition, extra);

    if (_isTruthy(condition)) {
      return visitNode(node.then, extra);
    } else {
      return visitNode(node.otherwise, extra);
    }
  }

  bool _isTruthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true; // All other objects are truthy
  }

  @override
  visitIdentifier(Identifier node, Context extra) {
    final identifiable = extra.variablesAndFunctions[node.name];
    if (identifiable == null) {
      throw Exception('Undefined identifier: ${node.name}');
    }

    if (identifiable is VariableDefinition) {
      return identifiable.value;
    } else if (identifiable is FunctionDefinition) {
      return identifiable.closure;
    } else {
      throw Exception('Identifier ${node.name} is declared but not defined');
    }
  }

  @override
  visitIndexExpression(IndexExpression node, Context extra) {
    final object = visitNode(node.object, extra);
    final index = visitNode(node.index, extra);

    if (object is List) {
      if (index is! int) {
        throw Exception(
          'List index must be an integer, got ${index.runtimeType}',
        );
      }
      if (index < 0 || index >= object.length) {
        throw Exception(
          'List index $index out of range (0-${object.length - 1})',
        );
      }
      return object[index];
    } else if (object is Map) {
      return object[index];
    } else {
      throw Exception(
        'Cannot index into ${object.runtimeType}, only List and Map are supported',
      );
    }
  }

  @override
  visitLambdaExpression(LambdaExpression node, Context extra) {
    return _createLambdaFunction(node, extra);
  }

  Function _createLambdaFunction(LambdaExpression node, Context extra) {
    if (node.arguments.length > 10) {
      throw Exception(
        'Lambda expressions with more than 10 arguments are not supported.',
      );
    }

    return ([
      dynamic arg0,
      dynamic arg1,
      dynamic arg2,
      dynamic arg3,
      dynamic arg4,
      dynamic arg5,
      dynamic arg6,
      dynamic arg7,
      dynamic arg8,
      dynamic arg9,
    ]) {
      final args = <dynamic>[];
      if (arg0 != null) args.add(arg0);
      if (arg1 != null) args.add(arg1);
      if (arg2 != null) args.add(arg2);
      if (arg3 != null) args.add(arg3);
      if (arg4 != null) args.add(arg4);
      if (arg5 != null) args.add(arg5);
      if (arg6 != null) args.add(arg6);
      if (arg7 != null) args.add(arg7);
      if (arg8 != null) args.add(arg8);
      if (arg9 != null) args.add(arg9);

      final lambdaContext = Context(
        variablesAndFunctions: {
          ...extra.variablesAndFunctions,
          for (int i = 0; i < node.arguments.length; i++)
            node.arguments[i].name: VariableDefinition(
              name: node.arguments[i].name,
              value: i < args.length ? args[i] : null,
            ),
        },
        binaryOperators: extra.binaryOperators,
      );

      return visitNode(node.body, lambdaContext);
    };
  }

  @override
  visitLiteral(Literal node, Context extra) {
    final value = node.value;
    if (value is List) {
      return value.map((e) => visitNode(e, extra)).toList().cast();
    }
    if (value is Map) {
      return value.map(
        (key, value) =>
            MapEntry(visitNode(key, extra), visitNode(value, extra)),
      );
    }
    return value;
  }

  @override
  visitMemberExpression(MemberExpression node, Context extra) {
    final object = visitNode(node.object, extra);
    final member = node.property.name;
    for (final accessor in extra.memberAccessors) {
      if (accessor.canHandle(object, member)) {
        return accessor.access(object, member);
      }
    }
    throw Exception('Unsupported member access: .${node.property.name}');
  }

  @override
  visitThisExpression(ThisExpression node, Context extra) {
    return extra.thisValue?.value;
  }

  @override
  visitUnaryExpression(UnaryExpression node, Context extra) {
    final operand = visitNode(node.operand, extra);
    final operator = extra.unaryOperators[node.operator];
    if (operator == null) {
      throw Exception('Unsupported unary operator: ${node.operator}');
    }
    return operator.implementation(operand);
  }

  @override
  visitVariable(Variable node, Context extra) {
    return visitNode(node.identifier, extra);
  }
}
