import 'package:petitparser/petitparser.dart';

typedef TrimResult<T> = ({String leading, T middle, String trailing});

Parser<TrimResult<T>> trimLRParser<T>(Parser<T> parser) {
  final ws = whitespace().star().flatten();
  return (ws & parser & ws).map((values) {
    final leading = values[0] as String;
    final middle = values[1];
    final trailing = values[2] as String;
    return (leading: leading, middle: middle, trailing: trailing);
  });
}

Parser<TrimResult<T>> trimLParser<T>(Parser<T> parser) {
  final ws = whitespace().star().flatten();
  return (ws & parser).map((values) {
    final leading = values[0] as String;
    final middle = values[1];
    final trailing = '';
    return (leading: leading, middle: middle, trailing: trailing);
  });
}

Parser<TrimResult<T>> trimRParser<T>(Parser<T> parser) {
  final ws = whitespace().star().flatten();
  return (parser & ws).map((values) {
    final leading = '';
    final middle = values[0];
    final trailing = values[1] as String;
    return (leading: leading, middle: middle, trailing: trailing);
  });
}

extension KeepTrimParser<T> on Parser<T> {
  Parser<TrimResult<T>> trimLR() {
    return trimLRParser<T>(this);
  }

  Parser<TrimResult<T>> trimL() {
    return trimLParser<T>(this);
  }

  Parser<TrimResult<T>> trimR() {
    return trimRParser<T>(this);
  }

  Parser<String> trimLRFlatten() {
    return trimLR().map((v) => v.flatten());
  }

  Parser<String> trimLFlatten() {
    return trimL().map((v) => v.flatten());
  }

  Parser<String> trimRFlatten() {
    return trimR().map((v) => v.flatten());
  }
}

extension FlattenKeepTrimResult<T> on TrimResult<T> {
  String flatten() {
    if (this.middle is! String) {
      throw ArgumentError('T is not a String');
    }
    return '$leading$middle$trailing';
  }
}
