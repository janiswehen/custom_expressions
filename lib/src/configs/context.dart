import 'parser_config.dart';

class Context {
  final ThisValue? thisValue;
  final Map<String, Identifiable> variablesAndFunctions;
  final Map<String, BinaryOperator> binaryOperators;
  final Map<String, UnaryOperator> unaryOperators;
  final List<MemberAccessor> memberAccessors;

  Context({
    this.thisValue,
    this.variablesAndFunctions = const {},
    this.binaryOperators = const {},
    this.unaryOperators = const {},
    this.memberAccessors = const [],
  });

  Context.defaultContext()
    : this(
        binaryOperators: _defaultBinaryOperators,
        unaryOperators: _defaultUnaryOperators,
        memberAccessors: _defaultMemberAccessors,
      );

  static final Map<String, BinaryOperator> _defaultBinaryOperators = {
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
      implementation: (left, right) => (left as int) ^ (right as int),
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

  static final Map<String, UnaryOperator> _defaultUnaryOperators = {
    '-': UnaryOperator(name: '-', implementation: (operand) => -operand),
    '!': UnaryOperator(name: '!', implementation: (operand) => !operand),
    '~': UnaryOperator(name: '~', implementation: (operand) => ~operand),
    '+': UnaryOperator(name: '+', implementation: (operand) => operand),
  };

  static final List<MemberAccessor> _defaultMemberAccessors = [
    MapMemberAccessor(),
    ClassMemberAccessor<List>(
      members: {
        'first': (list) => list.first,
        'last': (list) => list.last,
        'length': (list) => list.length,
      },
    ),
    ClassMemberAccessor<Map>(
      members: {
        'containsKey': (map) => map.containsKey,
        'length': (map) => map.length,
      },
    ),
  ];

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

  ParserConfig buildParserConfig() {
    return ParserConfig(
      allowThis: thisValue != null,
      unaryOperators: const ['-', '!', '~', '+'],
      binaryOperators: binaryOperators.map(
        (key, value) => MapEntry(key, value.precedence),
      ),
    );
  }
}

class ThisValue<T> {
  final T value;

  ThisValue({required this.value});
}

class BinaryOperator {
  final String name;
  final int precedence;
  final dynamic Function(dynamic left, dynamic right) implementation;

  const BinaryOperator({
    required this.name,
    required this.precedence,
    required this.implementation,
  });
}

class UnaryOperator {
  final String name;
  final dynamic Function(dynamic operand) implementation;

  const UnaryOperator({required this.name, required this.implementation});
}

class Identifiable {
  final String name;

  Identifiable({required this.name});
}

class VariableDeclaration<T> extends Identifiable {
  VariableDeclaration({required super.name});
}

class VariableDefinition<T> extends VariableDeclaration<T> {
  final T value;

  VariableDefinition({required super.name, required this.value});
}

class FunctionArgument<T> {}

class FunctionDeclaration<T> extends Identifiable {
  final List<FunctionArgument> arguments;

  FunctionDeclaration({required super.name, required this.arguments});
}

class FunctionDefinition<T> extends FunctionDeclaration<T> {
  final Function closure;

  FunctionDefinition({
    required super.name,
    required super.arguments,
    required this.closure,
  });
}

abstract class MemberAccessor<T> {
  bool canHandle(dynamic object, String member);
  dynamic access(T object, String member);
}

class MapMemberAccessor extends MemberAccessor<Map<String, dynamic>> {
  final bool throwOnMissing;

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

class ClassMemberAccessor<T> extends MemberAccessor<T> {
  final Map<String, Function(T)> members;

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
