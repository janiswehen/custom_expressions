import 'package:petitparser/petitparser.dart';
import 'package:uni_expressions/src/parser/bound_string.dart';

import '../expressions.dart';
import 'keep_trim_parser.dart';
import '../configs/parser_config.dart';

typedef _ArrayArgument = ({List<Expression> list, String token});

typedef _LambdaArgument = ({List<Identifier> arguments, String token});

typedef _MapArgument = ({Map<Expression, Expression> map, String token});

typedef _IndexArgument = ({Expression expression, String token});

typedef _MemberArgument = ({Identifier property, String token});

typedef _CallArgument = ({List<Expression> arguments, String token});

/// A comprehensive parser for mathematical and logical expressions.
///
/// This parser supports a wide range of expression types including:
/// - Literals (numbers, strings, booleans, null, arrays, maps)
/// - Variables
/// - Binary operations with configurable operators and precedence
/// - Unary operations
/// - Function calls and method chaining
/// - Member access (dot notation)
/// - Array and map literals
/// - Lambda expressions
/// - Conditional (ternary) expressions
/// - Grouped expressions (parentheses)
/// - Ternary (conditional) expressions
/// - This expression (only when enabled in the parser config)
///
/// The parser is configurable through [ParserConfig], allowing you to
/// customize operators, precedence rules, and other parsing behavior.
///
/// Example:
/// ```dart
/// final parser = ExpressionParser();
/// final expression = parser.parse('a + b * c');
/// ```
class ExpressionParser {
  /// Creates a new expression parser with the given configuration.
  ///
  /// [config] The parser configuration that defines operators, precedence,
  /// and other parsing behavior. Defaults to [ParserConfig.defaultConfig].
  ExpressionParser({this.config = const ParserConfig.defaultConfig()}) {
    _expression.set(
      _binaryExpression
          .seq(_conditionArguments.optional())
          .map(
            (l) => l[1] == null
                ? l[0]
                : ConditionalExpression(
                    condition: l[0],
                    then: l[1][1],
                    otherwise: l[1][3],
                    token: '#c${l[1][0]}#t${l[1][2]}#o',
                  ),
          ),
    );
    _token.set(
      (_lambdaExpression | _variable | _unaryExpression | _literal)
          .cast<Expression>(),
    );
  }

  /// Attempts to parse an expression string and returns a parsed [Expression] tree
  /// or null if the parsing fails.
  ///
  /// Example:
  /// ```dart
  /// final parser = ExpressionParser();
  /// final result1 = parser.tryParse('a + b'); // Returns Expression
  /// final result2 = parser.tryParse('a + b +'); // Returns null
  /// ```
  Expression? tryParse(String formattedString) {
    final result = _finalProgram.parse(formattedString);
    return result is Success ? result.value : null;
  }

  /// Parses an expression string and returns a parsed [Expression] tree
  /// or throws a [ParserException] if the parsing fails.
  ///
  /// Example:
  /// ```dart
  /// final parser = ExpressionParser();
  /// final result1 = parser.parse('a + b'); // Returns Expression
  /// final result2 = parser.parse('a + b +'); // Throws ParserException
  /// ```
  Expression parse(String str) => _finalProgram.parse(str).value;

  /// The configuration used by this parser.
  ///
  /// This configuration defines the operators, precedence rules, and other
  /// parsing behavior for the expression parser.
  final ParserConfig config;

  Parser<Expression> get _finalProgram => _expression
      .trimLR()
      .map(
        (l) => l.middle.copyWithToken(
          token: l.leading + l.middle.token + l.trailing,
        ),
      )
      .end();

  final SettableParser<Expression> _expression = undefined();

  // An individual part of a binary expression:
  // e.g. `foo.bar(baz)`, `1`, `'abc'`, `(a % 2)` (because it's in parenthesis)
  final SettableParser<Expression> _token = undefined<Expression>();

  Parser<Identifier> get _identifier =>
      ([
                digit(),
                boundString('this'),
                boundString('true'),
                boundString('false'),
                boundString('null'),
              ].toChoiceParser().not() &
              (word() | char(r'$')).plus())
          .flatten()
          .map((v) => Identifier(name: v, token: v));

  Parser<Literal> get _numericLiteral =>
      ((digit() | char('.')).and() &
              (digit().star() &
                  ((char('.') & digit().plus()) |
                          (char('x') & digit().plus()) |
                          (anyOf('Ee') &
                              anyOf('+-').optional() &
                              digit().plus()))
                      .optional()))
          .flatten()
          .map((v) {
            return Literal(value: num.parse(v), token: v);
          });

  Parser<String> get _escapedChar =>
      // cSpell:disable-next-line
      (char(r'\') & anyOf("nrtbfv\"'\\")).pick(1).cast();

  String _unescape(String v) => v.replaceAllMapped(
    // cSpell:disable-next-line
    RegExp("\\\\[nrtbf\"']"),
    (v) => const {
      'n': '\n',
      'r': '\r',
      't': '\t',
      'b': '\b',
      'f': '\f',
      'v': '\v',
      "'": "'",
      '"': '"',
    }[v.group(0)!.substring(1)]!,
  );

  Parser<Literal> get _sqStringLiteral =>
      (char("'") &
              (anyOf(r"'\").neg() | _escapedChar).star().flatten() &
              char("'"))
          .pick(1)
          .map((v) => Literal(value: _unescape(v), token: "'$v'"));

  Parser<Literal> get _dqStringLiteral =>
      (char('"') &
              (anyOf(r'"\').neg() | _escapedChar).star().flatten() &
              char('"'))
          .pick(1)
          .map((v) => Literal(value: _unescape(v), token: '"$v"'));

  Parser<Literal> get _stringLiteral =>
      _sqStringLiteral.or(_dqStringLiteral).cast();

  Parser<Literal> get _boolLiteral =>
      (boundString('true') | boundString('false')).map(
        (v) => Literal(value: v == 'true', token: v),
      );

  Parser<Literal> get _nullLiteral =>
      boundString('null').map((v) => Literal(value: null, token: v));

  Parser<ThisExpression> get _thisExpression =>
      boundString('this').map((v) => ThisExpression(token: v));

  Parser<Literal> get _arrayLiteral =>
      (char('[').trimRFlatten() & _arguments & char(']').trimLFlatten()).map(
        (l) => Literal(value: l[1].list, token: '${l[0]}${l[1].token}${l[2]}'),
      );

  Parser<Literal> get _mapLiteral =>
      (char('{').trimRFlatten() & _mapArguments & char('}').trimLFlatten()).map(
        (l) => Literal(value: l[1].map, token: '${l[0]}${l[1].token}${l[2]}'),
      );

  Parser<Literal> get _literal => [
    _numericLiteral,
    _stringLiteral,
    _boolLiteral,
    _nullLiteral,
    _arrayLiteral,
    _mapLiteral,
  ].toChoiceParser().cast();

  Parser<TrimResult<String>> get _binaryOperation =>
      config.binaryOperators.isEmpty
      ? failure()
      : ([...config.binaryOperators.keys]
              // we sort to prevent ambiguity
              ..sort((a, b) => b.length.compareTo(a.length)))
            .map<Parser<String>>((v) => string(v))
            .reduce((a, b) => (a | b).cast<String>())
            .trimLR();

  Parser<Expression> get _binaryExpression =>
      _token.plusSeparated(_binaryOperation).map((sl) {
        var l = sl.sequential.toList();

        var first = l[0];
        var stack = <dynamic>[first];

        for (var i = 1; i < l.length; i += 2) {
          var op = l[i] as TrimResult<String>;
          var precedence = config.precedenceForBinaryOperator(op.middle);

          // Reduce: make a binary expression from the three topmost entries.
          while ((stack.length > 2) &&
              (precedence <=
                  config.precedenceForBinaryOperator(
                    (stack[stack.length - 2] as TrimResult<String>).middle,
                  ))) {
            var right = stack.removeLast();
            var op = stack.removeLast() as TrimResult<String>;
            var left = stack.removeLast();
            var node = BinaryExpression(
              operator: op.middle,
              left: left,
              right: right,
              token: '#l${op.leading}#o${op.trailing}#r',
            );
            stack.add(node);
          }

          var node = l[i + 1];
          stack.addAll([op, node]);
        }
        var i = stack.length - 1;
        var node = stack[i];
        while (i > 1) {
          node = BinaryExpression(
            operator: (stack[i - 1] as TrimResult<String>).middle,
            left: stack[i - 2],
            right: node,
            token: '#l${stack[i - 1].leading}#o${stack[i - 1].trailing}#r',
          );
          i -= 2;
        }
        return node;
      });

  Parser<Expression> get _unaryExpression =>
      (config.unaryOperators.isEmpty
              ? failure()
              : ([...config.unaryOperators]
                      ..sort((a, b) => b.length.compareTo(a.length)))
                    .map((o) => string(o))
                    .toList()
                    .toChoiceParser()
                    .trimR())
          .seq(_token)
          .map(
            (l) => UnaryExpression(
              operator: l[0].middle,
              operand: l[1],
              token: '${l[0].leading}#o${l[0].trailing}#t',
            ),
          );

  Parser<LambdaExpression> get _lambdaExpression =>
      (char('(').trimRFlatten() &
              _lambdaArguments &
              char(')').trimLFlatten() &
              string('=>').trimLRFlatten() &
              _expression)
          .map(
            (l) => LambdaExpression(
              arguments: l[1].arguments,
              body: l[4],
              token: '${l[0]}${l[1].token}${l[2]}${l[3]}#b',
            ),
          );

  Parser<_ArrayArgument> get _arguments => _expression
      .plusSeparated(char(',').trimLRFlatten())
      .map(
        (sl) => (
          list: sl.elements,
          token: sl.sequential.indexed
              .map((e) => e.$2 is String ? e.$2 : '#a${e.$1 ~/ 2}')
              .join(),
        ),
      )
      .seq(char(',').trimLFlatten().optionalWith(''))
      .map((l) => (list: l[0].list, token: l[0].token + l[1]) as _ArrayArgument)
      .optionalWith((list: [], token: ''));

  Parser<_LambdaArgument> get _lambdaArguments => _identifier
      .plusSeparated(char(',').trimLRFlatten())
      .map(
        (sl) => (
          arguments: sl.elements,
          token: sl.sequential.indexed
              .map((e) => e.$2 is String ? e.$2 : '#a${e.$1 ~/ 2}')
              .join(),
        ),
      )
      .seq(char(',').trimLFlatten().optionalWith(''))
      .map(
        (l) =>
            (arguments: l[0].arguments, token: l[0].token + l[1])
                as _LambdaArgument,
      )
      .optionalWith((arguments: [], token: ''));

  Parser<_MapArgument> get _mapArguments =>
      (_expression & char(':').trimLRFlatten() & _expression)
          .map(
            (l) => (
              entry: MapEntry<Expression, Expression>(l[0], l[2]),
              token: '{#k${l[1]}#v}',
            ),
          )
          .plusSeparated(char(',').trimLRFlatten())
          .map(
            (sl) => (
              map: Map<Expression, Expression>.fromEntries(
                sl.elements.map((e) => e.entry),
              ),
              token: sl.sequential.indexed
                  .map(
                    (e) => e.$2 is String ? e.$2 : '${e.$1 ~/ 2}${e.$2.token}',
                  )
                  .join(),
            ),
          )
          .seq(char(',').trimLFlatten().optionalWith(''))
          .map((l) => (map: l[0].map, token: l[0].token + l[1]) as _MapArgument)
          .optionalWith((map: {}, token: ''));

  Parser<Expression> get _variable => _groupOrIdentifier
      .seq((_memberArgument | _indexArgument | _callArgument).star())
      .map((l) {
        var a = l[0] as Expression;
        var b = l[1] as List;
        return b.fold(a, (Expression object, argument) {
          if (argument is _MemberArgument) {
            return MemberExpression(
              object: object,
              property: argument.property,
              token: '#o${argument.token}',
            );
          }
          if (argument is _IndexArgument) {
            return IndexExpression(
              object: object,
              index: argument.expression,
              token: '#o${argument.token}',
            );
          }
          if (argument is _CallArgument) {
            return CallExpression(
              callee: object,
              arguments: argument.arguments,
              token: '#c${argument.token}',
            );
          }
          throw ArgumentError('Invalid type ${argument.runtimeType}');
        });
      });

  Parser<Expression> get _group =>
      (char('(').trimRFlatten() & _expression & char(')').trimLFlatten())
          .map((l) => l[1].copyWithToken(token: '${l[0]}${l[1].token}${l[2]}'))
          .cast();

  Parser<Expression> get _groupOrIdentifier => [
    _literal,
    if (config.allowThis) _thisExpression,
    _identifier.map((v) => Variable(identifier: v, token: '#i')),
    _group,
  ].toChoiceParser().cast();

  Parser<_MemberArgument> get _memberArgument =>
      (char('.').trimLRFlatten() & _identifier).map(
        (l) => (property: l[1], token: '${l[0]}#p'),
      );

  Parser<_IndexArgument> get _indexArgument =>
      (char('[').trimRFlatten() & _expression & char(']').trimLFlatten()).map(
        (l) => (expression: l[1], token: '${l[0]}#i${l[2]}'),
      );

  Parser<_CallArgument> get _callArgument =>
      (char('(').trimRFlatten() & _arguments & char(')').trimLFlatten()).map(
        (l) => (arguments: l[1].list, token: '${l[0]}${l[1].token}${l[2]}'),
      );

  Parser<List> get _conditionArguments =>
      (char('?').trimLRFlatten() & _expression & char(':').trimLRFlatten()).seq(
        _expression,
      );
}
