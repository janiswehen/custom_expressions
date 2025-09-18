import 'package:petitparser/petitparser.dart';

typedef KeepTrimResult<T> = ({String leading, T middle, String trailing});

Parser<KeepTrimResult<T>> keepTrimParser<T>(Parser<T> parser) {
  final ws = whitespace().star().flatten();
  return (ws & parser & ws).map((values) {
    final leading = values[0] as String;
    final middle = values[1];
    final trailing = values[2] as String;
    return (leading: leading, middle: middle, trailing: trailing);
  });
}

extension KeepTrimParser<T> on Parser<T> {
  Parser<KeepTrimResult<T>> keepTrim() {
    return keepTrimParser<T>(this);
  }

  Parser<String> keepTrimFlatten() {
    return keepTrim().map((v) => v.flatten());
  }
}

extension FlattenKeepTrimResult<T> on KeepTrimResult<T> {
  String flatten() {
    if (this.middle is! String) {
      throw ArgumentError('T is not a String');
    }
    return '$leading$middle$trailing';
  }
}
