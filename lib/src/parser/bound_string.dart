import 'package:petitparser/petitparser.dart';

Parser<String> boundString(String string) {
  return PatternParser(
    RegExp('$string\\b'),
    'Expected string: $string',
  ).map((match) => match.group(0)!);
}
