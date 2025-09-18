import 'package:petitparser/petitparser.dart';

import '../expressions.dart';
import 'keep_trim_parser.dart';
import 'parser_config.dart';

typedef _ArrayArgument = ({List<Expression> list, String token});

typedef _LambdaArgument = ({List<Identifier> arguments, String token});

typedef _MapArgument = ({Map<Expression, Expression> map, String token});

typedef _IndexArgument = ({Expression expression, String token});

typedef _MemberArgument = ({Identifier property, String token});

typedef _CallArgument = ({List<Expression> arguments, String token});

class ExpressionParser {
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
      (lambdaExpression | _literal | _unaryExpression | _variable)
          .cast<Expression>(),
    );
  }

  Expression? tryParse(String formattedString) {
    final result = _finalProgram.parse(formattedString);
    return result is Success ? result.value : null;
  }

  Expression parse(String formattedString) =>
      _finalProgram.parse(formattedString).value;

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

  // Gobbles only identifiers
  // e.g.: `foo`, `_value`, `$x1`
  Parser<Identifier> get _identifier =>
      (digit().not() & (word() | char(r'$')).plus()).flatten().map(
        (v) => Identifier(name: v, token: v),
      );

  // Parse simple numeric literals: `12`, `3.4`, `.5`.
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

  // Parses a string literal, staring with single or double quotes with basic
  // support for escape codes
  Parser<Literal> get _stringLiteral =>
      _sqStringLiteral.or(_dqStringLiteral).cast();

  // Parses a boolean literal
  Parser<Literal> get _boolLiteral => (string('true') | string('false')).map(
    (v) => Literal(value: v == 'true', token: v),
  );

  // Parses the null literal
  Parser<Literal> get _nullLiteral =>
      string('null').map((v) => Literal(value: null, token: v));

  // Parses the this literal
  Parser<ThisExpression> get _thisExpression =>
      string('this').map((v) => ThisExpression(token: v));

  // Responsible for parsing Array literals `[1, 2, 3]`
  // This function assumes that it needs to gobble the opening bracket
  // and then tries to gobble the expressions as arguments.
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
    if (config.allowNull) _nullLiteral,
    _arrayLiteral,
    _mapLiteral,
  ].toChoiceParser().cast();

  // This function is responsible for gobbling an individual expression,
  // e.g. `1`, `1+2`, `a+(b*2)-Math.sqrt(2)`
  Parser<TrimResult<String>> get _binaryOperation => config.binaryOperators
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

  Parser<UnaryExpression> get _unaryExpression => config.unaryOperators
      .map<Parser<String>>((v) => string(v))
      .reduce((a, b) => (a | b).cast<String>())
      .trimR()
      .seq(_token)
      .map(
        (l) => UnaryExpression(
          operator: l[0].middle,
          operand: l[1],
          token: '${l[0].leading}#o${l[0].trailing}#t',
        ),
      );

  Parser<LambdaExpression> get lambdaExpression =>
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

  // Gobbles a list of arguments within the context of a function call
  // or array literal. This function also assumes that the opening character
  // `(` or `[` has already been gobbled, and gobbles expressions and commas
  // until the terminator character `)` or `]` is encountered.
  // e.g. `foo(bar, baz)`, `my_func()`, or `[bar, baz]`
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
          .optionalWith((map: {}, token: ''));

  // Gobble a non-literal variable name. This variable name may include properties
  // e.g. `foo`, `bar.baz`, `foo['bar'].baz`
  // It also gobbles function calls:
  // e.g. `Math.acos(obj.angle)`
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

  // Responsible for parsing a group of things within parentheses `()`
  // This function assumes that it needs to gobble the opening parenthesis
  // and then tries to gobble everything within that parenthesis, assuming
  // that the next thing it should see is the close parenthesis. If not,
  // then the expression probably doesn't have a `)`
  Parser<Expression> get _group =>
      (char('(').trimRFlatten() & _expression & char(')').trimLFlatten())
          .map((l) => l[1].copyWithToken(token: '${l[0]}${l[1].token}${l[2]}'))
          .cast();

  Parser<Expression> get _groupOrIdentifier => [
    _group,
    if (config.allowThis) _thisExpression,
    _identifier.map((v) => Variable(identifier: v, token: '#')),
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

  // Ternary expression: test ? consequent : alternate
  Parser<List> get _conditionArguments =>
      (char('?').trimLRFlatten() & _expression & char(':').trimLRFlatten()).seq(
        _expression,
      );
}
