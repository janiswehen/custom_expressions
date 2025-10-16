import 'package:petitparser/petitparser.dart';

/// Creates a parser that matches a specific string as a whole word.
///
/// This parser ensures that the given string is matched only when it appears
/// as a complete word (bounded by word boundaries), preventing partial matches
/// within larger words.
///
/// Example:
/// ```dart
/// final parser = boundString('true');
/// parser.parse('true');     // Success: matches 'true'
/// parser.parse('false');    // Fails: doesn't match 'false'
/// parser.parse('truest');   // Fails: 'true' is not a complete word
/// ```
///
/// [string] The exact string to match as a whole word.
/// Returns a parser that matches the string with word boundaries.
Parser<String> boundString(String string) {
  return PatternParser(
    RegExp('$string\\b'),
    'Expected string: $string',
  ).map((match) => match.group(0)!);
}
