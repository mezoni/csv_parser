// This code was generated by a tool.
// https://github.com/mezoni/parser_builder

// ignore_for_file: unused_local_variable

import 'package:source_span/source_span.dart';

/// Parses the CSV data and returns the result as a `List<List<String>>`.
/// - Will not parse numbers
/// - The character `,` is used as a field separator
/// - Line endings are `\n`, `\r\n` or `\r`
/// - The start and end of strings is the character `"`
/// - Escaping a character `"` in a string is parsed via sequence `""`
/// - Exception `FormatException` will be thrown if parsing fails
List<List<String>> parse(String source) {
  final state = State(source);
  final result = _parse(state);
  if (!state.ok) {
    final errors = Err.errorReport(state.error);
    final message = _errorMessage(source, errors);
    throw FormatException('\n$message');
  }

  return result!;
}

bool? _ws(State<String> state) {
  bool? $0;
  var $c = state.ch;
  bool $test(int x) => x == 0x9 || x == 0x20;
  while ($c != State.eof && $test($c)) {
    $c = state.nextChar();
  }
  state.ok = true;
  if (state.ok) {
    $0 = true;
  }
  return $0;
}

String? _quote(State<String> state) {
  String? $0;
  state.ok = state.ch == 0x22;
  if (state.ok) {
    state.nextChar();
    $0 = '"';
  } else {
    state.error = ErrExpected.tag(state.pos, const Tag('"'));
  }
  return $0;
}

bool? _openQuote(State<String> state) {
  bool? $0;
  final $pos = state.pos;
  final $ch = state.ch;
  bool? $1;
  $1 = _ws(state);
  if (state.ok) {
    String? $2;
    $2 = _quote(state);
    if (state.ok) {
      $0 = true;
    }
  }
  if (!state.ok) {
    state.pos = $pos;
    state.ch = $ch;
  }
  return $0;
}

List<int>? _chars(State<String> state) {
  List<int>? $0;
  final $list = <int>[];
  for (;;) {
    int? $1;
    for (;;) {
      int? $2;
      final $c = state.ch;
      if ($c != State.eof) {
        state.ok = $c != 0x22;
        if (state.ok) {
          $2 = $c;
          state.nextChar();
        } else {
          state.error = ErrUnexpected.char(state.pos, Char($c));
        }
      } else {
        state.ok = false;
        state.error = ErrUnexpected.eof(state.pos);
      }
      if (state.ok) {
        $1 = $2;
        break;
      }
      final $3 = state.error;
      int? $4;
      String? $6;
      state.ok = state.ch == 0x22 && state.source.startsWith('""', state.pos);
      if (state.ok) {
        state.readChar(state.pos + 2);
        $6 = '""';
      } else {
        state.error = ErrExpected.tag(state.pos, const Tag('""'));
      }
      if (state.ok) {
        $4 = 34;
      }
      if (state.ok) {
        $1 = $4;
        break;
      }
      final $5 = state.error;
      state.error = ErrCombined(state.pos, [$3, $5]);
      break;
    }
    if (!state.ok) {
      state.ok = true;
      if (state.ok) {
        $0 = $list;
      }
      break;
    }
    $list.add($1!);
  }
  return $0;
}

bool? _closeQuote(State<String> state) {
  bool? $0;
  final $pos = state.pos;
  final $ch = state.ch;
  String? $1;
  $1 = _quote(state);
  if (state.ok) {
    bool? $2;
    $2 = _ws(state);
    if (state.ok) {
      $0 = true;
    }
  }
  if (!state.ok) {
    state.pos = $pos;
    state.ch = $ch;
  }
  return $0;
}

String? _string(State<String> state) {
  String? $0;
  final $pos = state.pos;
  final $ch = state.ch;
  bool? $1;
  $1 = _openQuote(state);
  if (state.ok) {
    String? $2;
    List<int>? $3;
    $3 = _chars(state);
    if (state.ok) {
      String map(List<int> x) => String.fromCharCodes(x);
      $2 = map($3!);
    }
    if (state.ok) {
      bool? $4;
      $4 = _closeQuote(state);
      if (state.ok) {
        $0 = $2!;
      }
    }
  }
  if (!state.ok) {
    state.pos = $pos;
    state.ch = $ch;
  }
  return $0;
}

String? _text(State<String> state) {
  String? $0;
  final $pos = state.pos;
  var $c = state.ch;
  bool $test(int x) => !(x == 0xA || x == 0xD || x == 0x22 || x == 0x2C);
  while ($c != State.eof && $test($c)) {
    $c = state.nextChar();
  }
  state.ok = true;
  if (state.ok) {
    $0 = state.source.substring($pos, state.pos);
  }
  return $0;
}

String? _field(State<String> state) {
  String? $0;
  for (;;) {
    String? $1;
    $1 = _string(state);
    if (state.ok) {
      $0 = $1;
      break;
    }
    final $2 = state.error;
    String? $3;
    $3 = _text(state);
    if (state.ok) {
      $0 = $3;
      break;
    }
    final $4 = state.error;
    state.error = ErrCombined(state.pos, [$2, $4]);
    break;
  }
  return $0;
}

List<String>? _row(State<String> state) {
  List<String>? $0;
  var $pos = state.pos;
  var $ch = state.ch;
  final $list = <String>[];
  for (;;) {
    String? $1;
    $1 = _field(state);
    if (!state.ok) {
      state.pos = $pos;
      state.ch = $ch;
      break;
    }
    $list.add($1!);
    $pos = state.pos;
    $ch = state.ch;
    String? $2;
    state.ok = state.ch == 0x2C;
    if (state.ok) {
      state.nextChar();
      $2 = ',';
    } else {
      state.error = ErrExpected.tag(state.pos, const Tag(','));
    }
    if (!state.ok) {
      break;
    }
  }
  if ($list.isNotEmpty) {
    state.ok = true;
    $0 = $list;
  }
  return $0;
}

String? _eol(State<String> state) {
  final source = state.source;
  String? $0;
  switch (state.ch) {
    case 10:
      state.readChar(state.pos + 1);
      $0 = '\n';
      break;
    case 13:
      if (source.startsWith('\r\n', state.pos)) {
        state.readChar(state.pos + 2);
        $0 = '\r\n';
        break;
      }
      state.readChar(state.pos + 1);
      $0 = '\r';
      break;
  }
  state.ok = $0 != null;
  if (!state.ok) {
    state.error = ErrCombined(state.pos, [
      ErrExpected.tag(state.pos, Tag('\n')),
      ErrExpected.tag(state.pos, Tag('\r\n')),
      ErrExpected.tag(state.pos, Tag('\r'))
    ]);
  }
  return $0;
}

bool? _eof(State<String> state) {
  bool? $0;
  state.ok = state.source.atEnd(state.pos);
  if (state.ok) {
    $0 = true;
  } else {
    state.error = ErrExpected.eof(state.pos);
  }
  return $0;
}

List<List<String>>? _rows(State<String> state) {
  List<List<String>>? $0;
  final $pos = state.pos;
  final $ch = state.ch;
  List<List<String>>? $1;
  var $pos1 = state.pos;
  var $ch1 = state.ch;
  final $list = <List<String>>[];
  for (;;) {
    List<String>? $2;
    $2 = _row(state);
    if (!state.ok) {
      state.pos = $pos1;
      state.ch = $ch1;
      break;
    }
    $list.add($2!);
    $pos1 = state.pos;
    $ch1 = state.ch;
    bool? $3;
    final $pos2 = state.pos;
    final $ch2 = state.ch;
    String? $4;
    $4 = _eol(state);
    if (state.ok) {
      bool? $5;
      final $pos3 = state.pos;
      final $ch3 = state.ch;
      bool? $6;
      $6 = _eof(state);
      state.ok = !state.ok;
      if (state.ok) {
        $5 = true;
      } else {
        state.pos = $pos3;
        state.ch = $ch3;
        state.error = ErrUnknown(state.pos);
      }
      if (state.ok) {
        $3 = true;
      }
    }
    if (!state.ok) {
      state.pos = $pos2;
      state.ch = $ch2;
    }
    if (!state.ok) {
      break;
    }
  }
  if ($list.isNotEmpty) {
    state.ok = true;
    $1 = $list;
  }
  if (state.ok) {
    dynamic $7;
    String? $8;
    $8 = _eol(state);
    if (state.ok) {
      $7 = $8!;
    } else {
      state.ok = true;
      $7 = null;
    }
    if (state.ok) {
      $0 = $1!;
    }
  }
  if (!state.ok) {
    state.pos = $pos;
    state.ch = $ch;
  }
  return $0;
}

List<List<String>>? _parse(State<String> state) {
  List<List<String>>? $0;
  final $pos = state.pos;
  final $ch = state.ch;
  List<List<String>>? $1;
  $1 = _rows(state);
  if (state.ok) {
    bool? $2;
    $2 = _eof(state);
    if (state.ok) {
      $0 = $1!;
    }
  }
  if (!state.ok) {
    state.pos = $pos;
    state.ch = $ch;
  }
  return $0;
}

String _errorMessage(String source, List<Err> errors,
    [color, int maxCount = 10, String? url]) {
  final sb = StringBuffer();
  for (var i = 0; i < errors.length; i++) {
    if (i > maxCount) {
      break;
    }

    final error = errors[i];
    if (error.offset + error.length > source.length) {
      source += ' ' * (error.offset + error.length - source.length);
    }

    final file = SourceFile.fromString(source, url: url);
    final span = file.span(error.offset, error.offset + error.length);
    if (sb.isNotEmpty) {
      sb.writeln();
    }

    sb.write(span.message(error.toString(), color: color));
  }

  if (errors.length > maxCount) {
    sb.writeln();
    sb.write('(${errors.length - maxCount} more errors...)');
  }

  return sb.toString();
}

/// Represents the `char` used in parsing errors.
class Char {
  final int charCode;

  const Char(this.charCode);

  @override
  int get hashCode => charCode.hashCode;

  @override
  operator ==(other) {
    return other is Char && other.charCode == charCode;
  }

  @override
  String toString() {
    final s = String.fromCharCode(charCode)._escape();
    return '\'$s\'';
  }
}

abstract class Err {
  @override
  int get hashCode => length.hashCode ^ offset.hashCode;

  int get length;

  int get offset;

  @override
  bool operator ==(other) {
    return other is Err && other.length == length && other.offset == offset;
  }

  static List<Err> errorReport(Err error) {
    var result = Err.flatten(error);
    result = Err.groupExpected(result);
    return result;
  }

  static List<Err> flatten(Err error) {
    void flatten(Err error, List<Err> result) {
      if (error is ErrCombined) {
        for (final error in error.errors) {
          flatten(error, result);
        }
      } else if (error is ErrWithTagAndErrors) {
        final inner = <Err>[];
        for (final nestedError in error.errors) {
          flatten(nestedError, inner);
        }

        int max(int x, int y) => x > y
            ? x
            : y < x
                ? x
                : y;
        final maxOffset = inner.map((e) => e.offset).reduce(max);
        final farthest = inner.where((e) => e.offset == maxOffset);
        final offset = error.offset;
        final tag = error.tag;
        result.add(ErrExpected.tag(offset, tag));
        if (maxOffset > offset) {
          if (error is ErrMalformed) {
            result
                .add(ErrMessage(offset, maxOffset - offset, 'Malformed $tag'));
            result.addAll(farthest);
          } else if (error is ErrNested) {
            result.addAll(farthest);
          } else {
            throw StateError('Internal error');
          }
        }
      } else {
        result.add(error);
      }
    }

    final result = <Err>[];
    flatten(error, result);
    return result.toSet().toList();
  }

  static List<Err> groupExpected(List<Err> errors) {
    final result = <Err>[];
    final expected = errors.whereType<ErrExpected>();
    Map<T, List<S>> groupBy<S, T>(Iterable<S> values, T Function(S) key) {
      final map = <T, List<S>>{};
      for (final element in values) {
        (map[key(element)] ??= []).add(element);
      }
      return map;
    }

    final groupped = groupBy(expected, (Err e) => e.offset);
    final offsets = <int>{};
    final processed = <Err>{};
    for (final error in errors) {
      if (!processed.add(error)) {
        continue;
      }

      if (error is! ErrExpected) {
        result.add(error);
        continue;
      }

      final offset = error.offset;
      if (!offsets.add(offset)) {
        continue;
      }

      final elements = <String>[];
      for (final error in groupped[offset]!) {
        elements.add(error.value.toString());
        processed.add(error);
      }

      final message = elements.join(', ');
      final newError = ErrMessage(offset, 1, 'Expected: $message');
      result.add(newError);
    }

    return result;
  }
}

class ErrCombined extends ErrWithErrors {
  @override
  final List<Err> errors;

  @override
  final int offset;

  ErrCombined(this.offset, this.errors);

  @override
  int get length => 1;
}

class ErrExpected extends Err {
  @override
  final int offset;

  final Object? value;

  ErrExpected(this.offset, this.value);

  ErrExpected.char(this.offset, Char value) : value = value;

  ErrExpected.eof(this.offset) : value = const Tag('EOF');

  ErrExpected.label(this.offset, String value) : value = value;

  ErrExpected.tag(this.offset, Tag value) : value = value;

  @override
  int get length => 1;

  @override
  String toString() {
    final result = 'Expected: $value';
    return result;
  }
}

class ErrMalformed extends ErrWithTagAndErrors {
  @override
  final List<Err> errors;

  @override
  final int offset;

  @override
  final Tag tag;

  ErrMalformed(this.offset, this.tag, this.errors);

  @override
  int get length => 1;

  @override
  String toString() {
    final result = 'Malformed $tag';
    return result;
  }
}

class ErrMessage extends Err {
  @override
  final int length;

  final String message;

  @override
  final int offset;

  ErrMessage(this.offset, this.length, this.message);

  @override
  String toString() {
    return message;
  }
}

class ErrNested extends ErrWithTagAndErrors {
  @override
  final List<Err> errors;

  @override
  final int offset;

  @override
  final Tag tag;

  ErrNested(this.offset, this.tag, this.errors);

  @override
  int get length => 1;

  @override
  String toString() {
    final result = 'Nested $tag';
    return result;
  }
}

class ErrUnexpected extends Err {
  @override
  final int length;

  @override
  final int offset;

  final Object? value;

  ErrUnexpected(this.offset, this.length, this.value);

  ErrUnexpected.char(this.offset, Char value)
      : length = 1,
        value = value;

  ErrUnexpected.eof(this.offset)
      : length = 1,
        value = const Tag('EOF');

  ErrUnexpected.label(this.offset, String value)
      : length = value.length,
        value = value;

  ErrUnexpected.tag(this.offset, Tag value)
      : length = value.name.length,
        value = value;

  @override
  String toString() {
    final result = 'Unexpected: $value';
    return result;
  }
}

class ErrUnknown extends Err {
  @override
  final int offset;

  ErrUnknown(this.offset);

  @override
  int get length => 1;

  @override
  String toString() {
    final result = 'Unknown error';
    return result;
  }
}

abstract class ErrWithErrors extends Err {
  List<Err> get errors;

  @override
  String toString() {
    final list = errors.join(', ');
    final result = '[$list]';
    return result;
  }
}

abstract class ErrWithTagAndErrors extends ErrWithErrors {
  Tag get tag;
}

class State<T> {
  static const eof = 0x110000;

  dynamic context;

  int ch = eof;

  Err error = ErrUnknown(0);

  bool ok = false;

  int pos = 0;

  final T source;

  State(this.source) {
    if (this is State<String>) {
      final this_ = this as State<String>;
      ch = this_.readChar(0);
    }
  }

  @override
  String toString() {
    if (source is String) {
      final s = source as String;
      if (pos >= s.length) {
        return '$pos:';
      }

      var length = s.length - pos;
      length = length > 40 ? 40 : length;
      final string = s.substring(pos, pos + length);
      return '$pos:$string';
    } else {
      return super.toString();
    }
  }
}

/// Represents the `tag` (symbol) used in parsing errors.
class Tag {
  final String name;

  const Tag(this.name);

  @override
  int get hashCode => name.hashCode;

  @override
  operator ==(other) {
    return other is Tag && other.name == name;
  }

  @override
  String toString() {
    final s = name._escape();
    return '\'$s\'';
  }
}

extension on State<String> {
  @pragma('vm:prefer-inline')
  // ignore: unused_element
  int getChar(int index) {
    if (index < source.length) {
      final c = source.codeUnitAt(index);
      return c <= 0xD7FF || c >= 0xE000 ? c : _getChar32(c, index + 1);
    } else {
      return State.eof;
    }
  }

  @pragma('vm:prefer-inline')
  // ignore: unused_element
  int nextChar() {
    final index = pos + (ch > 0xffff ? 2 : 1);
    if (index < source.length) {
      pos = index;
      final c = source.codeUnitAt(index);
      ch = c <= 0xD7FF || c >= 0xE000 ? c : _getChar32(c, index + 1);
    } else {
      pos = source.length;
      ch = State.eof;
    }
    return ch;
  }

  @pragma('vm:prefer-inline')
  // ignore: unused_element
  int readChar(int index) {
    if (index < source.length) {
      pos = index;
      final c = source.codeUnitAt(index);
      ch = c <= 0xD7FF || c >= 0xE000 ? c : _getChar32(c, index + 1);
    } else {
      pos = source.length;
      ch = State.eof;
    }
    return ch;
  }

  @pragma('vm:prefer-inline')
  int _getChar32(int c, int index) {
    if (index < source.length) {
      final c2 = source.codeUnitAt(index);
      if ((c2 & 0xfc00) == 0xdc00) {
        return 0x10000 + ((c & 0x3ff) << 10) + (c2 & 0x3ff);
      }
    }
    return State.eof;
  }
}

extension on String {
  /// Returns `true` if [pos] points to the end of the string (or beyond).
  @pragma('vm:prefer-inline')
  // ignore: unused_element
  bool atEnd(int pos) {
    return pos >= length;
  }

  /// Returns a slice (substring) of the string from [start] to [end].
  @pragma('vm:prefer-inline')
  // ignore: unused_element
  String slice(int start, int end) {
    return substring(start, end);
  }

  String _escape() {
    final map = {
      '\b': '\\b',
      '\f': '\\f',
      '\n': '\\n',
      '\r': '\\t',
      '\t': '\\t',
      '\v': '\\v',
    };

    var s = this;
    for (final key in map.keys) {
      s = s.replaceAll(key, map[key]!);
    }

    return '\'$s\'';
  }
}
