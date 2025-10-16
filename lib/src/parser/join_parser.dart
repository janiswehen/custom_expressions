import 'package:petitparser/petitparser.dart';

/// Returns a parser that joins the result of the parser.
extension KeepTrimParser<T> on Parser<T> {
  /// Returns a parser that joins the result of the parser.
  Parser<String> join() {
    return map((v) => (v as List).join());
  }
}
