import 'package:petitparser/petitparser.dart';

/// Represents the result of parsing with preserved whitespace information.
///
/// This record type captures the leading whitespace, the actual parsed content,
/// and the trailing whitespace from a parsing operation.
///
/// [leading] The whitespace that appeared before the parsed content.
/// [middle] The actual parsed content of type T.
/// [trailing] The whitespace that appeared after the parsed content.
typedef TrimResult<T> = ({String leading, T middle, String trailing});

/// Creates a parser that trims whitespace on both sides while preserving it.
///
/// This parser wraps another parser to consume leading and trailing whitespace
/// while preserving the whitespace information in the result. The parsed content
/// is returned along with the consumed whitespace.
///
/// Example:
/// ```dart
/// final parser = trimLRParser(string('hello'));
/// final result = parser.parse('  hello  ');
/// // result.leading = '  ', result.middle = 'hello', result.trailing = '  '
/// ```
///
/// [parser] The parser to wrap with whitespace trimming.
/// Returns a parser that produces a [TrimResult] with preserved whitespace.
Parser<TrimResult<T>> trimLRParser<T>(Parser<T> parser) {
  final ws = whitespace().star().flatten();
  return (ws & parser & ws).map((values) {
    final leading = values[0] as String;
    final middle = values[1];
    final trailing = values[2] as String;
    return (leading: leading, middle: middle, trailing: trailing);
  });
}

/// Creates a parser that trims whitespace on the left side while preserving it.
///
/// This parser wraps another parser to consume only leading whitespace
/// while preserving the whitespace information in the result. The trailing
/// whitespace is left unconsumed.
///
/// Example:
/// ```dart
/// final parser = trimLParser(string('hello'));
/// final result = parser.parse('  hello  ');
/// // result.leading = '  ', result.middle = 'hello', result.trailing = ''
/// ```
///
/// [parser] The parser to wrap with left-side whitespace trimming.
/// Returns a parser that produces a [TrimResult] with preserved leading whitespace.
Parser<TrimResult<T>> trimLParser<T>(Parser<T> parser) {
  final ws = whitespace().star().flatten();
  return (ws & parser).map((values) {
    final leading = values[0] as String;
    final middle = values[1];
    final trailing = '';
    return (leading: leading, middle: middle, trailing: trailing);
  });
}

/// Creates a parser that trims whitespace on the right side while preserving it.
///
/// This parser wraps another parser to consume only trailing whitespace
/// while preserving the whitespace information in the result. The leading
/// whitespace is left unconsumed.
///
/// Example:
/// ```dart
/// final parser = trimRParser(string('hello'));
/// final result = parser.parse('  hello  ');
/// // result.leading = '', result.middle = 'hello', result.trailing = '  '
/// ```
///
/// [parser] The parser to wrap with right-side whitespace trimming.
/// Returns a parser that produces a [TrimResult] with preserved trailing whitespace.
Parser<TrimResult<T>> trimRParser<T>(Parser<T> parser) {
  final ws = whitespace().star().flatten();
  return (parser & ws).map((values) {
    final leading = '';
    final middle = values[0];
    final trailing = values[1] as String;
    return (leading: leading, middle: middle, trailing: trailing);
  });
}

/// Extension methods for parsers to add whitespace trimming capabilities.
///
/// This extension provides convenient methods for applying whitespace trimming
/// to any parser while preserving the original whitespace information.
extension KeepTrimParser<T> on Parser<T> {
  /// Trims whitespace on both sides while preserving it.
  ///
  /// Equivalent to calling [trimLRParser] with this parser.
  Parser<TrimResult<T>> trimLR() {
    return trimLRParser<T>(this);
  }

  /// Trims whitespace on the left side while preserving it.
  ///
  /// Equivalent to calling [trimLParser] with this parser.
  Parser<TrimResult<T>> trimL() {
    return trimLParser<T>(this);
  }

  /// Trims whitespace on the right side while preserving it.
  ///
  /// Equivalent to calling [trimRParser] with this parser.
  Parser<TrimResult<T>> trimR() {
    return trimRParser<T>(this);
  }

  /// Trims whitespace on both sides and flattens the result to a string.
  ///
  /// This method combines trimming with flattening, useful when you need
  /// the final result as a single string including the preserved whitespace.
  Parser<String> trimLRFlatten() {
    return trimLR().map((v) => v.flatten());
  }

  /// Trims whitespace on the left side and flattens the result to a string.
  ///
  /// This method combines left trimming with flattening, useful when you need
  /// the final result as a single string including the preserved leading whitespace.
  Parser<String> trimLFlatten() {
    return trimL().map((v) => v.flatten());
  }

  /// Trims whitespace on the right side and flattens the result to a string.
  ///
  /// This method combines right trimming with flattening, useful when you need
  /// the final result as a single string including the preserved trailing whitespace.
  Parser<String> trimRFlatten() {
    return trimR().map((v) => v.flatten());
  }
}

/// Extension methods for [TrimResult] to provide flattening capabilities.
///
/// This extension adds methods to convert [TrimResult] objects back into
/// single strings, combining the leading whitespace, middle content, and
/// trailing whitespace.
extension FlattenKeepTrimResult<T> on TrimResult<T> {
  /// Flattens the trim result into a single string.
  ///
  /// Combines the leading whitespace, middle content, and trailing whitespace
  /// into a single string. The middle content must be a String for this to work.
  ///
  /// Throws an [ArgumentError] if the middle content is not a String.
  ///
  /// Example:
  /// ```dart
  /// final result = (leading: '  ', middle: 'hello', trailing: '  ');
  /// final flattened = result.flatten(); // '  hello  '
  /// ```
  String flatten() {
    if (this.middle is! String) {
      throw ArgumentError('T is not a String');
    }
    return '$leading$middle$trailing';
  }
}
