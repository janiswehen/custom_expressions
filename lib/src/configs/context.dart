import 'dart:math';

import 'parser_config.dart';

/// The context of the expression. Defines the parsing and evaluation behavior.
class Context {
  /// The value if the 'this' keyword. Does not parse if not present.
  final ThisValue? thisValue;

  /// The map of all variables and functions. Key is the name of the variable or function.
  final Map<String, Identifiable> variablesAndFunctions;

  /// The map of all binary operators. Key is the name of the operator.
  final Map<String, BinaryOperator> binaryOperators;

  /// The map of all unary operators. Key is the name of the operator.
  final Map<String, UnaryOperator> unaryOperators;

  /// The list of all member accessors.
  final List<MemberAccessor> memberAccessors;

  /// Creates a new context.
  ///
  /// [thisValue] The value if the 'this' keyword. Does not parse if not present.
  /// [variablesAndFunctions] The map of all variables and functions. Key is the name of the variable or function.
  /// [binaryOperators] The map of all binary operators. Key is the name of the operator.
  /// [unaryOperators] The map of all unary operators. Key is the name of the operator.
  /// [memberAccessors] The list of all member accessors.
  Context({
    this.thisValue,
    this.variablesAndFunctions = const {},
    this.binaryOperators = const {},
    this.unaryOperators = const {},
    this.memberAccessors = const [],
  });

  /// Creates a new context with some default binary-, unary-operators and member accessors.
  Context.defaultContext()
    : this(
        binaryOperators: defaultBinaryOperators,
        unaryOperators: _defaultUnaryOperators,
        memberAccessors: _defaultMemberAccessors,
      );

  /// The default binary operators.
  static final Map<String, BinaryOperator> defaultBinaryOperators = {
    '??': BinaryOperator(
      name: '??',
      precedence: 0,
      implementation: (left, right) => left ?? right,
    ),
    '||': BinaryOperator(
      name: '||',
      precedence: 1,
      implementation: (left, right) => (left as bool) || (right as bool),
    ),
    '&&': BinaryOperator(
      name: '&&',
      precedence: 2,
      implementation: (left, right) => (left as bool) && (right as bool),
    ),
    '|': BinaryOperator(
      name: '|',
      precedence: 3,
      implementation: (left, right) => (left as int) | (right as int),
    ),
    '^': BinaryOperator(
      name: '^',
      precedence: 4,
      implementation: (left, right) => pow(left, right),
    ),
    '&': BinaryOperator(
      name: '&',
      precedence: 5,
      implementation: (left, right) => (left as int) & (right as int),
    ),
    '==': BinaryOperator(
      name: '==',
      precedence: 6,
      implementation: (left, right) => left == right,
    ),
    '!=': BinaryOperator(
      name: '!=',
      precedence: 6,
      implementation: (left, right) => left != right,
    ),
    '<=': BinaryOperator(
      name: '<=',
      precedence: 7,
      implementation: (left, right) => (left as num) <= (right as num),
    ),
    '>=': BinaryOperator(
      name: '>=',
      precedence: 7,
      implementation: (left, right) => (left as num) >= (right as num),
    ),
    '<': BinaryOperator(
      name: '<',
      precedence: 7,
      implementation: (left, right) => (left as num) < (right as num),
    ),
    '>': BinaryOperator(
      name: '>',
      precedence: 7,
      implementation: (left, right) => (left as num) > (right as num),
    ),
    '<<': BinaryOperator(
      name: '<<',
      precedence: 8,
      implementation: (left, right) => (left as int) << (right as int),
    ),
    '>>': BinaryOperator(
      name: '>>',
      precedence: 8,
      implementation: (left, right) => (left as int) >> (right as int),
    ),
    '+': BinaryOperator(
      name: '+',
      precedence: 9,
      implementation: (left, right) => left + right,
    ),
    '-': BinaryOperator(
      name: '-',
      precedence: 9,
      implementation: (left, right) => (left as num) - (right as num),
    ),
    '*': BinaryOperator(
      name: '*',
      precedence: 10,
      implementation: (left, right) => (left as num) * (right as num),
    ),
    '/': BinaryOperator(
      name: '/',
      precedence: 10,
      implementation: (left, right) => (left as num) / (right as num),
    ),
    '%': BinaryOperator(
      name: '%',
      precedence: 10,
      implementation: (left, right) => (left as num) % (right as num),
    ),
    '~/': BinaryOperator(
      name: '~/',
      precedence: 10,
      implementation: (left, right) => (left as num) ~/ (right as num),
    ),
  };

  /// The default unary operators.
  static final Map<String, UnaryOperator> _defaultUnaryOperators = {
    '-': UnaryOperator(name: '-', implementation: (operand) => -operand),
    '!': UnaryOperator(name: '!', implementation: (operand) => !operand),
    '~': UnaryOperator(name: '~', implementation: (operand) => ~operand),
    '+': UnaryOperator(name: '+', implementation: (operand) => operand),
  };

  /// The default member accessors.
  static final List<MemberAccessor> _defaultMemberAccessors = [
    MapMemberAccessor(),
    ClassMemberAccessor<List>(
      members: {
        'first': (list) => list.first,
        'last': (list) => list.last,
        'length': (list) => list.length,
        'map': (list) =>
            (dynamic Function(dynamic) lambda) => list.map(lambda).toList(),
      },
    ),
    ClassMemberAccessor<Map>(
      members: {
        'containsKey': (map) => map.containsKey,
        'length': (map) => map.length,
      },
    ),
  ];

  /// Creates a shallow copy of the context with some optional values changed.
  Context copyWith({
    ThisValue? thisValue,
    Map<String, Identifiable>? variablesAndFunctions,
    Map<String, BinaryOperator>? binaryOperators,
    Map<String, UnaryOperator>? unaryOperators,
    List<MemberAccessor>? memberAccessors,
  }) {
    return Context(
      thisValue: thisValue ?? this.thisValue,
      variablesAndFunctions:
          variablesAndFunctions ?? this.variablesAndFunctions,
      binaryOperators: binaryOperators ?? this.binaryOperators,
      unaryOperators: unaryOperators ?? this.unaryOperators,
      memberAccessors: memberAccessors ?? this.memberAccessors,
    );
  }

  /// Creates a parser config that fits the context.
  ParserConfig buildParserConfig() {
    return ParserConfig(
      allowThis: thisValue != null,
      allowLambda: true,
      unaryOperators: unaryOperators.keys.toList(),
      binaryOperators: binaryOperators.map(
        (key, value) => MapEntry(key, value.precedence),
      ),
    );
  }
}

/// The value of the 'this' keyword.
class ThisValue<T> {
  /// The value of the 'this' keyword.
  final T value;

  ThisValue({required this.value});
}

/// A binary operator.
class BinaryOperator {
  /// The name of the operator.
  final String name;

  /// The precedence of the operator. If has same precedence, the order of the operators is from left to right.
  final int precedence;

  /// The implementation of the operator.
  final dynamic Function(dynamic left, dynamic right) implementation;

  const BinaryOperator({
    required this.name,
    required this.precedence,
    required this.implementation,
  });
}

/// A unary operator.
class UnaryOperator {
  /// The name of the operator.
  final String name;

  /// The implementation of the operator.
  final dynamic Function(dynamic operand) implementation;

  const UnaryOperator({required this.name, required this.implementation});
}

/// An identifiable.
class Identifiable {
  /// The name of the identifiable.
  final String name;

  Identifiable({required this.name});
}

/// A variable declaration.
class VariableDeclaration<T> extends Identifiable {
  VariableDeclaration({required super.name});
}

/// A variable definition.
class VariableDefinition<T> extends VariableDeclaration<T> {
  /// The value of the variable.
  final T value;

  VariableDefinition({required super.name, required this.value});
}

/// A function argument.
class FunctionArgument<T> {}

/// A function declaration.

class FunctionDeclaration<T> extends Identifiable {
  /// The arguments of the function.
  final List<FunctionArgument> arguments;

  FunctionDeclaration({required super.name, required this.arguments});
}

/// A function definition.
class FunctionDefinition<T> extends FunctionDeclaration<T> {
  /// The closure of the function.
  final Function closure;

  FunctionDefinition({
    required super.name,
    required super.arguments,
    required this.closure,
  });
}

/// A member accessor.
abstract class MemberAccessor<T> {
  /// Whether the member accessor can handle the [member] of the [object].
  bool canHandle(dynamic object, String member);

  /// Access the [member] of the [object].
  dynamic access(T object, String member);
}

/// A map member accessor. Enables value access of string mapped values via the dot notation.
class MapMemberAccessor extends MemberAccessor<Map<String, dynamic>> {
  /// Whether to throw an error if the member is not found.
  final bool throwOnMissing;

  /// Creates a new map member accessor.
  ///
  /// [throwOnMissing] Whether to throw an error if the member is not found.
  MapMemberAccessor({this.throwOnMissing = true});

  @override
  bool canHandle(dynamic object, String member) {
    return object is Map<String, dynamic> &&
        (!throwOnMissing || object.containsKey(member));
  }

  @override
  dynamic access(Map object, String member) {
    return object[member];
  }
}

/// A class member accessor. Enables value access of class members via the dot notation.
class ClassMemberAccessor<T> extends MemberAccessor<T> {
  /// All members of the class. Key is the name of the member, value is the function to access the member.
  final Map<String, Function(T)> members;

  /// Creates a new class member accessor.
  ///
  /// [members] All members of the class. Key is the name of the member, value is the function to access the member.
  ClassMemberAccessor({required this.members});

  @override
  bool canHandle(dynamic object, String member) {
    return object is T && members.containsKey(member);
  }

  @override
  dynamic access(T object, String member) {
    return members[member]!(object);
  }
}
