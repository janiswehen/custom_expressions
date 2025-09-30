import 'package:petitparser/petitparser.dart';

extension KeepTrimParser<T> on Parser<T> {
  Parser<String> join() {
    return map((v) => (v as List).join());
  }
}
