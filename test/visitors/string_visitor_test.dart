import 'package:test/test.dart';
import 'package:uni_expressions/uni_expressions.dart';

// Custom matcher for round-trip testing
Matcher toNotChangeWhenParsedWith(ExpressionParser parser) {
  return _RoundTripMatcher(parser);
}

class _RoundTripMatcher extends Matcher {
  final ExpressionParser parser;

  _RoundTripMatcher(this.parser);

  @override
  bool matches(Object? item, Map matchState) {
    if (item is! String) {
      return false;
    }

    try {
      final expression = parser.parse(item);
      final result = StringVisitor.visit(expression);
      return result == item;
    } catch (e) {
      return false;
    }
  }

  @override
  Description describe(Description description) {
    return description.add('should not change when parsed and stringified');
  }

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! String) {
      return mismatchDescription.add('is not a string');
    }

    try {
      final expression = parser.parse(item);
      final result = StringVisitor.visit(expression);
      return mismatchDescription.add(
        'changes from "$item" to "$result" when parsed and stringified',
      );
    } catch (e) {
      return mismatchDescription.add('fails to parse: $e');
    }
  }
}

void main() {
  group('StringVisitor - Individual Node Tests', () {
    late ExpressionParser parser;

    setUp(() {
      parser = ExpressionParser(config: ParserConfig.defaultConfig());
    });

    group('Binary Expressions', () {
      test('should handle simple binary operations', () {
        expect('1 + 2', toNotChangeWhenParsedWith(parser));
        expect('3 * 4', toNotChangeWhenParsedWith(parser));
        expect('5 - 6', toNotChangeWhenParsedWith(parser));
        expect('7 / 8', toNotChangeWhenParsedWith(parser));
        expect('9 % 10', toNotChangeWhenParsedWith(parser));
      });

      test('should handle comparison operators', () {
        expect('1 == 2', toNotChangeWhenParsedWith(parser));
        expect('3 != 4', toNotChangeWhenParsedWith(parser));
        expect('5 < 6', toNotChangeWhenParsedWith(parser));
        expect('7 > 8', toNotChangeWhenParsedWith(parser));
        expect('9 <= 10', toNotChangeWhenParsedWith(parser));
        expect('11 >= 12', toNotChangeWhenParsedWith(parser));
      });

      test('should handle logical operators', () {
        expect('true && false', toNotChangeWhenParsedWith(parser));
        expect('true || false', toNotChangeWhenParsedWith(parser));
      });

      test('should handle operator precedence', () {
        expect('1 + 2 * 3', toNotChangeWhenParsedWith(parser));
        expect('(1 + 2) * 3', toNotChangeWhenParsedWith(parser));
        expect('1 + 2 * 3 + 4', toNotChangeWhenParsedWith(parser));
        expect('(1 + 2) * (3 + 4)', toNotChangeWhenParsedWith(parser));
      });

      test('should handle complex nested expressions', () {
        expect(
          '(1 + 2) * (3 - 4) / (5 + 6)',
          toNotChangeWhenParsedWith(parser),
        );
        expect('a + b * c - d / e', toNotChangeWhenParsedWith(parser));
        expect('(a + b) * (c - d)', toNotChangeWhenParsedWith(parser));
      });

      test('should handle expressions with different spacing', () {
        expect('1+2', toNotChangeWhenParsedWith(parser));
        expect('1 + 2', toNotChangeWhenParsedWith(parser));
        expect('1  +  2', toNotChangeWhenParsedWith(parser));
        expect('( 1 + 2 )', toNotChangeWhenParsedWith(parser));
      });
    });

    group('Call Expressions', () {
      test('should handle function calls with no arguments', () {
        expect('foo()', toNotChangeWhenParsedWith(parser));
        expect('bar()', toNotChangeWhenParsedWith(parser));
        expect('baz()', toNotChangeWhenParsedWith(parser));
      });

      test('should handle function calls with single argument', () {
        expect('foo(1)', toNotChangeWhenParsedWith(parser));
        expect('bar("hello")', toNotChangeWhenParsedWith(parser));
        expect('baz(true)', toNotChangeWhenParsedWith(parser));
      });

      test('should handle function calls with multiple arguments', () {
        expect('foo(1, 2)', toNotChangeWhenParsedWith(parser));
        expect('bar("a", "b", "c")', toNotChangeWhenParsedWith(parser));
        expect('baz(1, true, "hello")', toNotChangeWhenParsedWith(parser));
      });

      test('should handle function calls with different spacing', () {
        expect('foo(1,2)', toNotChangeWhenParsedWith(parser));
        expect('foo( 1 , 2 )', toNotChangeWhenParsedWith(parser));
        expect('foo( 1, 2 )', toNotChangeWhenParsedWith(parser));
        expect('foo(1 ,2)', toNotChangeWhenParsedWith(parser));
      });

      test('should handle function calls with complex arguments', () {
        expect('foo(1 + 2, 3 * 4)', toNotChangeWhenParsedWith(parser));
        expect('bar(a + b, c - d)', toNotChangeWhenParsedWith(parser));
        expect(
          'baz((1 + 2) * 3, (4 - 5) / 6)',
          toNotChangeWhenParsedWith(parser),
        );
      });

      test('should handle nested function calls', () {
        expect('foo(bar(1))', toNotChangeWhenParsedWith(parser));
        expect('foo(bar(baz(1)))', toNotChangeWhenParsedWith(parser));
        expect(
          'outer(inner(1, 2), other(3, 4))',
          toNotChangeWhenParsedWith(parser),
        );
      });

      test('should handle function calls with array and map arguments', () {
        expect('foo([1, 2, 3])', toNotChangeWhenParsedWith(parser));
        expect('bar({"a": 1, "b": 2})', toNotChangeWhenParsedWith(parser));
        expect(
          'baz([1, 2], {"key": "value"})',
          toNotChangeWhenParsedWith(parser),
        );
      });

      test('should handle multiline function calls', () {
        expect('foo(\n  1,\n  2\n)', toNotChangeWhenParsedWith(parser));
        expect('foo(\n  1\n)', toNotChangeWhenParsedWith(parser));
        expect('foo(\n)', toNotChangeWhenParsedWith(parser));
        expect(
          'bar(\n\t"a",\n\t"b",\n\t"c"\n)',
          toNotChangeWhenParsedWith(parser),
        );
        expect('baz(\n  1 + 2,\n  3 * 4\n)', toNotChangeWhenParsedWith(parser));
      });

      test('should handle trailing comma', () {
        expect('foo(1,)', toNotChangeWhenParsedWith(parser));
        expect('foo(1, 2,)', toNotChangeWhenParsedWith(parser));

        expect(() => parser.parse('foo(,)'), throwsA(isA<Exception>()));
      });
    });

    group('Conditional Expressions', () {
      test('should handle simple ternary expressions', () {
        expect('1 ? 2 : 3', toNotChangeWhenParsedWith(parser));
        expect('true ? "yes" : "no"', toNotChangeWhenParsedWith(parser));
        expect('a ? b : c', toNotChangeWhenParsedWith(parser));
      });

      test('should handle ternary expressions with different spacing', () {
        expect('1?2:3', toNotChangeWhenParsedWith(parser));
        expect('1 ? 2 : 3', toNotChangeWhenParsedWith(parser));
        expect('1  ?  2  :  3', toNotChangeWhenParsedWith(parser));
        expect('( 1 ? 2 : 3 )', toNotChangeWhenParsedWith(parser));
      });

      test('should handle ternary expressions with complex conditions', () {
        expect('a > b ? 1 : 2', toNotChangeWhenParsedWith(parser));
        expect(
          'x == y ? "equal" : "different"',
          toNotChangeWhenParsedWith(parser),
        );
        expect('(a + b) > c ? d : e', toNotChangeWhenParsedWith(parser));
      });

      test('should handle ternary expressions with complex branches', () {
        expect('1 ? (2 + 3) : (4 - 5)', toNotChangeWhenParsedWith(parser));
        expect('a ? b + c : d - e', toNotChangeWhenParsedWith(parser));
        expect('x ? y * z : w / v', toNotChangeWhenParsedWith(parser));
      });

      test('should handle nested ternary expressions', () {
        expect('a ? b ? c : d : e', toNotChangeWhenParsedWith(parser));
        expect('x ? (y ? z : w) : v', toNotChangeWhenParsedWith(parser));
        expect('(a ? b : c) ? d : e', toNotChangeWhenParsedWith(parser));
      });

      test('should handle ternary expressions with function calls', () {
        expect('a ? foo(1) : bar(2)', toNotChangeWhenParsedWith(parser));
        expect(
          'x > y ? max(x, y) : min(x, y)',
          toNotChangeWhenParsedWith(parser),
        );
        expect(
          'condition() ? success() : failure()',
          toNotChangeWhenParsedWith(parser),
        );
      });

      test('should handle ternary expressions with arrays and maps', () {
        expect('a ? [1, 2] : [3, 4]', toNotChangeWhenParsedWith(parser));
        expect('x ? {"a": 1} : {"b": 2}', toNotChangeWhenParsedWith(parser));
        expect(
          'condition ? [1, 2, 3] : {"key": "value"}',
          toNotChangeWhenParsedWith(parser),
        );
      });

      test('should handle multiline ternary expressions', () {
        expect('a ?\n  b :\n  c', toNotChangeWhenParsedWith(parser));
        expect(
          'condition ?\n\t"yes" :\n\t"no"',
          toNotChangeWhenParsedWith(parser),
        );
        expect('x > y ?\n  x :\n  y', toNotChangeWhenParsedWith(parser));
      });
    });

    group('Index Expressions', () {
      test('should handle simple index expressions', () {
        expect('arr[0]', toNotChangeWhenParsedWith(parser));
        expect('arr[1]', toNotChangeWhenParsedWith(parser));
        expect('obj["key"]', toNotChangeWhenParsedWith(parser));
        expect('obj[\'key\']', toNotChangeWhenParsedWith(parser));
      });

      test('should handle index expressions with different spacing', () {
        expect('arr[0]', toNotChangeWhenParsedWith(parser));
        expect('arr[ 0 ]', toNotChangeWhenParsedWith(parser));
        expect('arr[  0  ]', toNotChangeWhenParsedWith(parser));
        expect('( arr[0] )', toNotChangeWhenParsedWith(parser));
      });

      test('should handle index expressions with variable indices', () {
        expect('arr[i]', toNotChangeWhenParsedWith(parser));
        expect('obj[key]', toNotChangeWhenParsedWith(parser));
        expect('data[index]', toNotChangeWhenParsedWith(parser));
      });

      test('should handle index expressions with complex indices', () {
        expect('arr[i + 1]', toNotChangeWhenParsedWith(parser));
        expect('obj[key + "_suffix"]', toNotChangeWhenParsedWith(parser));
        expect('data[(i + j) * 2]', toNotChangeWhenParsedWith(parser));
      });

      test('should handle chained index expressions', () {
        expect('arr[0][1]', toNotChangeWhenParsedWith(parser));
        expect('obj[key1][key2]', toNotChangeWhenParsedWith(parser));
        expect('data[i][j][k]', toNotChangeWhenParsedWith(parser));
      });

      test('should handle index expressions with function calls', () {
        expect('arr[getIndex()]', toNotChangeWhenParsedWith(parser));
        expect('obj[getKey()]', toNotChangeWhenParsedWith(parser));
        expect('data[calculateIndex(i, j)]', toNotChangeWhenParsedWith(parser));
      });

      test('should handle index expressions with ternary indices', () {
        expect('arr[condition ? 0 : 1]', toNotChangeWhenParsedWith(parser));
        expect(
          'obj[flag ? "key1" : "key2"]',
          toNotChangeWhenParsedWith(parser),
        );
        expect('data[x > y ? i : j]', toNotChangeWhenParsedWith(parser));
      });

      test('should handle index expressions with array and map indices', () {
        expect('arr[[1, 2, 3]]', toNotChangeWhenParsedWith(parser));
        expect('obj[{"key": "value"}]', toNotChangeWhenParsedWith(parser));
        expect('data[arr[0]]', toNotChangeWhenParsedWith(parser));
      });

      test('should handle multiline index expressions', () {
        expect('arr[\n  0\n]', toNotChangeWhenParsedWith(parser));
        expect('obj[\n  "key"\n]', toNotChangeWhenParsedWith(parser));
        expect('data[\n  i + j\n]', toNotChangeWhenParsedWith(parser));
      });
    });

    group('Lambda Expressions', () {
      test('should handle lambda expressions with no arguments', () {
        expect('() => 42', toNotChangeWhenParsedWith(parser));
        expect('() => true', toNotChangeWhenParsedWith(parser));
        expect('() => "hello"', toNotChangeWhenParsedWith(parser));
      });

      test('should handle lambda expressions with single argument', () {
        expect('(x) => x', toNotChangeWhenParsedWith(parser));
        expect('(a) => a + 1', toNotChangeWhenParsedWith(parser));
        expect('(value) => value * 2', toNotChangeWhenParsedWith(parser));
      });

      test('should handle lambda expressions with multiple arguments', () {
        expect('(a, b) => a + b', toNotChangeWhenParsedWith(parser));
        expect('(x, y) => x * y', toNotChangeWhenParsedWith(parser));
        expect(
          '(first, second) => first - second',
          toNotChangeWhenParsedWith(parser),
        );
      });

      test('should handle lambda expressions with different spacing', () {
        expect('(x)=>x', toNotChangeWhenParsedWith(parser));
        expect('(x) => x', toNotChangeWhenParsedWith(parser));
        expect('( x ) => x', toNotChangeWhenParsedWith(parser));
        expect('( x , y ) => x + y', toNotChangeWhenParsedWith(parser));
      });

      test('should handle lambda expressions with complex bodies', () {
        expect('(x) => x > 0 ? x : -x', toNotChangeWhenParsedWith(parser));
        expect(
          '(a, b) => (a + b) * (a - b)',
          toNotChangeWhenParsedWith(parser),
        );
        expect('(x) => x * x + 2 * x + 1', toNotChangeWhenParsedWith(parser));
      });

      test('should handle lambda expressions with function calls', () {
        expect('(x) => foo(x)', toNotChangeWhenParsedWith(parser));
        expect('(a, b) => max(a, b)', toNotChangeWhenParsedWith(parser));
        expect('(x) => calculate(x, 2)', toNotChangeWhenParsedWith(parser));
      });

      test('should handle lambda expressions with arrays and maps', () {
        expect('(x) => [x, x + 1]', toNotChangeWhenParsedWith(parser));
        expect(
          '(key, value) => {key: value}',
          toNotChangeWhenParsedWith(parser),
        );
        expect('(x) => {"result": x * 2}', toNotChangeWhenParsedWith(parser));
      });

      test('should handle nested lambda expressions', () {
        expect('(x) => (y) => x + y', toNotChangeWhenParsedWith(parser));
        expect(
          '(a) => (b) => (c) => a + b + c',
          toNotChangeWhenParsedWith(parser),
        );
        expect(
          '(x) => (y) => x > y ? x : y',
          toNotChangeWhenParsedWith(parser),
        );
      });

      test('should handle multiline lambda expressions', () {
        expect('(\n  x\n) => x + 1', toNotChangeWhenParsedWith(parser));
        expect('(\n  a,\n  b\n) => a + b', toNotChangeWhenParsedWith(parser));
        expect(
          '(\n  x\n) =>\n  x > 0 ?\n    x :\n    -x',
          toNotChangeWhenParsedWith(parser),
        );
      });

      test('should handle Trailing Commas', () {
        expect('(a,) => 1', toNotChangeWhenParsedWith(parser));
        expect('(a, b,) => 1', toNotChangeWhenParsedWith(parser));

        expect(() => parser.parse('(,) => 1'), throwsA(isA<Exception>()));
      });
    });

    group('Literal Expressions', () {
      test('should handle simple literals', () {
        expect('42', toNotChangeWhenParsedWith(parser));
        expect('3.14', toNotChangeWhenParsedWith(parser));
        expect('true', toNotChangeWhenParsedWith(parser));
        expect('false', toNotChangeWhenParsedWith(parser));
        expect('null', toNotChangeWhenParsedWith(parser));
      });

      test('should handle string literals with different quote types', () {
        expect("'Hello, World!'", toNotChangeWhenParsedWith(parser));
        expect('"Hello, World!"', toNotChangeWhenParsedWith(parser));
      });

      test('should handle string literals with escape sequences', () {
        expect("'Hello\\nWorld!'", toNotChangeWhenParsedWith(parser));
        expect("'Hello\\tWorld!'", toNotChangeWhenParsedWith(parser));
        expect("'Hello\\rWorld!'", toNotChangeWhenParsedWith(parser));
        expect("'Hello\\'World!'", toNotChangeWhenParsedWith(parser));
        expect('"Hello\\"World!"', toNotChangeWhenParsedWith(parser));
        expect("'Hello\\\\World!'", toNotChangeWhenParsedWith(parser));
      });

      test('should handle array literals', () {
        expect('[1, 2, 3]', toNotChangeWhenParsedWith(parser));
        expect('[]', toNotChangeWhenParsedWith(parser));
        expect('[1]', toNotChangeWhenParsedWith(parser));
      });

      test('should handle array literals with complex formatting', () {
        expect('[\n  1,\n  2,\n  3\n]', toNotChangeWhenParsedWith(parser));
        expect('[\n  1,\n  2\n]', toNotChangeWhenParsedWith(parser));
        expect('[\n  1\n]', toNotChangeWhenParsedWith(parser));
        expect('[\n]', toNotChangeWhenParsedWith(parser));
        expect('[ 1 , 2 , 3 ]', toNotChangeWhenParsedWith(parser));
        expect('[1,2,3]', toNotChangeWhenParsedWith(parser));
      });

      test('should handle map literals', () {
        expect('{"a": 1, "b": 2}', toNotChangeWhenParsedWith(parser));
        expect('{}', toNotChangeWhenParsedWith(parser));
        expect('{"key": "value"}', toNotChangeWhenParsedWith(parser));
      });

      test('should handle map literals with complex formatting', () {
        expect('{\n  "a": 1,\n  "b": 2\n}', toNotChangeWhenParsedWith(parser));
        expect('{\n  "key": "value"\n}', toNotChangeWhenParsedWith(parser));
        expect('{\n}', toNotChangeWhenParsedWith(parser));
        expect('{ "a" : 1 , "b" : 2 }', toNotChangeWhenParsedWith(parser));
        expect('{"a":1,"b":2}', toNotChangeWhenParsedWith(parser));
      });

      test('should handle trailing comma in arrays and maps', () {
        expect('[1,]', toNotChangeWhenParsedWith(parser));
        expect('[1,2,]', toNotChangeWhenParsedWith(parser));
        expect('{"a":1,}', toNotChangeWhenParsedWith(parser));
        expect('{"a":1, "b":2,}', toNotChangeWhenParsedWith(parser));

        expect(() => parser.parse('[,]'), throwsA(isA<Exception>()));
        expect(() => parser.parse('{,}'), throwsA(isA<Exception>()));
      });
    });

    group('Member Expressions', () {
      test('should handle simple member expressions', () {
        expect('obj.prop', toNotChangeWhenParsedWith(parser));
        expect('data.value', toNotChangeWhenParsedWith(parser));
        expect('user.name', toNotChangeWhenParsedWith(parser));
      });

      test('should handle member expressions with different spacing', () {
        expect('obj.prop', toNotChangeWhenParsedWith(parser));
        expect('obj . prop', toNotChangeWhenParsedWith(parser));
        expect('obj  .  prop', toNotChangeWhenParsedWith(parser));
        expect('( obj.prop )', toNotChangeWhenParsedWith(parser));
      });

      test('should handle chained member expressions', () {
        expect('obj.prop.subprop', toNotChangeWhenParsedWith(parser));
        expect('data.user.profile', toNotChangeWhenParsedWith(parser));
        expect('a.b.c.d', toNotChangeWhenParsedWith(parser));
      });

      test('should handle member expressions with complex objects', () {
        expect('arr[0].prop', toNotChangeWhenParsedWith(parser));
        expect('obj[key].value', toNotChangeWhenParsedWith(parser));
        expect('data[i + 1].name', toNotChangeWhenParsedWith(parser));
      });

      test('should handle member expressions with function call objects', () {
        expect('getObj().prop', toNotChangeWhenParsedWith(parser));
        expect('createData().value', toNotChangeWhenParsedWith(parser));
        expect('factory().item.name', toNotChangeWhenParsedWith(parser));
      });

      test('should handle member expressions with ternary objects', () {
        expect(
          '(condition ? obj1 : obj2).prop',
          toNotChangeWhenParsedWith(parser),
        );
        expect(
          '(x > y ? data : backup).value',
          toNotChangeWhenParsedWith(parser),
        );
        expect('(flag ? a : b).c.d', toNotChangeWhenParsedWith(parser));
      });

      test('should handle multiline member expressions', () {
        expect('obj\n  .prop', toNotChangeWhenParsedWith(parser));
        expect('data\n  .user\n  .profile', toNotChangeWhenParsedWith(parser));
        expect(
          'getObj()\n  .prop\n  .subprop',
          toNotChangeWhenParsedWith(parser),
        );
      });
    });

    group('This Expressions', () {
      test('should handle simple this expressions', () {
        expect('this', toNotChangeWhenParsedWith(parser));
      });

      test('should handle this expressions with different spacing', () {
        expect('this', toNotChangeWhenParsedWith(parser));
        expect(' this ', toNotChangeWhenParsedWith(parser));
        expect('  this  ', toNotChangeWhenParsedWith(parser));
      });
    });

    group('Unary Expressions', () {
      test('should handle simple unary expressions', () {
        expect('!true', toNotChangeWhenParsedWith(parser));
        expect('!false', toNotChangeWhenParsedWith(parser));
        expect('-5', toNotChangeWhenParsedWith(parser));
        expect('+10', toNotChangeWhenParsedWith(parser));
      });

      test('should handle unary expressions with different spacing', () {
        expect('!x', toNotChangeWhenParsedWith(parser));
        expect('! x', toNotChangeWhenParsedWith(parser));
        expect('!  x', toNotChangeWhenParsedWith(parser));
        expect('( !x )', toNotChangeWhenParsedWith(parser));
      });

      test('should handle unary expressions with complex operands', () {
        expect('!(a + b)', toNotChangeWhenParsedWith(parser));
        expect('-(x * y)', toNotChangeWhenParsedWith(parser));
        expect('!(x > y)', toNotChangeWhenParsedWith(parser));
      });

      test('should handle unary expressions with function calls', () {
        expect('!foo()', toNotChangeWhenParsedWith(parser));
        expect('-getValue()', toNotChangeWhenParsedWith(parser));
        expect('!calculate(1, 2)', toNotChangeWhenParsedWith(parser));
      });

      test('should handle unary expressions with member access', () {
        expect('!obj.prop', toNotChangeWhenParsedWith(parser));
        expect('-data.value', toNotChangeWhenParsedWith(parser));
        expect('!this.method()', toNotChangeWhenParsedWith(parser));
      });

      test('should handle unary expressions with index access', () {
        expect('!arr[0]', toNotChangeWhenParsedWith(parser));
        expect('-obj[key]', toNotChangeWhenParsedWith(parser));
        expect('!data[i + 1]', toNotChangeWhenParsedWith(parser));
      });

      test('should handle unary expressions with ternary operands', () {
        expect('!(a ? b : c)', toNotChangeWhenParsedWith(parser));
        expect('-(x > y ? 1 : 0)', toNotChangeWhenParsedWith(parser));
        expect(
          '!(condition ? true : false)',
          toNotChangeWhenParsedWith(parser),
        );
      });

      test('should handle nested unary expressions', () {
        expect('!!x', toNotChangeWhenParsedWith(parser));
        expect('--y', toNotChangeWhenParsedWith(parser));
        expect('!-z', toNotChangeWhenParsedWith(parser));
      });

      test('should handle multiline unary expressions', () {
        expect('!\n  x', toNotChangeWhenParsedWith(parser));
        expect('-\n  (a + b)', toNotChangeWhenParsedWith(parser));
        expect('!\n  foo()\n  .value', toNotChangeWhenParsedWith(parser));
      });
    });

    group('Variable Expressions', () {
      test('should handle simple variable expressions', () {
        expect('x', toNotChangeWhenParsedWith(parser));
        expect('y', toNotChangeWhenParsedWith(parser));
        expect('variable', toNotChangeWhenParsedWith(parser));
        expect('data', toNotChangeWhenParsedWith(parser));
      });

      test('should handle variable expressions with different spacing', () {
        expect('x', toNotChangeWhenParsedWith(parser));
        expect(' x ', toNotChangeWhenParsedWith(parser));
        expect('  x  ', toNotChangeWhenParsedWith(parser));
        expect('( x )', toNotChangeWhenParsedWith(parser));
      });

      test('should handle variable expressions with underscores', () {
        expect('_private', toNotChangeWhenParsedWith(parser));
        expect('_internal_var', toNotChangeWhenParsedWith(parser));
        expect('user_name', toNotChangeWhenParsedWith(parser));
      });

      test('should handle variable expressions with numbers', () {
        expect('var1', toNotChangeWhenParsedWith(parser));
        expect('data2', toNotChangeWhenParsedWith(parser));
        expect('item_3', toNotChangeWhenParsedWith(parser));
      });

      test('should handle variable expressions with dollar signs', () {
        expect('\$x', toNotChangeWhenParsedWith(parser));
        expect('\$variable', toNotChangeWhenParsedWith(parser));
        expect('\$data', toNotChangeWhenParsedWith(parser));
      });
    });
  });
}
