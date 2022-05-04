// This code was generated by a tool.
// https://github.com/mezoni/parser_builder

import 'package:source_span/source_span.dart';

/// Parses the CSV data and returns the result as a `List<List<String>>`.
/// - Will not parse numbers
/// - The field separator is parsed as specified in the `separator` argument
/// - Line endings are `\n`, `\r\n` or `\r`
/// - The start and end of strings is the character `"`
/// - Escaping a character `"` in a string is parsed via sequence `""`
/// - Exception `FormatException` will be thrown if parsing fails
List<List<String>> parse(String source, {String separator = ','}) {
  void check(String name, String value) {
    if (value.runes.length != 1) {
      throw ArgumentError.value(value, name, 'Must be 1 code point long');
    }
  }

  check('separator', separator);
  final state = State(source);
  final separatorChar = separator.runes.first;
  state.context =
      _StateContext(separator: separator, separatorChar: separatorChar);
  final result = _parse(state);
  if (!state.ok) {
    final offset = state.errorPos;
    final errors = ParseError.errorReport(offset, state.errors);
    final message = _errorMessage(source, errors);
    throw FormatException('\n$message');
  }

  return result!;
}

void _ws(State<String> state) {
  final source = state.source;
  while (state.pos < source.length) {
    final c = source.codeUnitAt(state.pos);
    final ok = c == 9 || c == 32;
    if (!ok) {
      break;
    }
    state.pos++;
  }
  state.ok = true;
}

void _quote(State<String> state) {
  final source = state.source;
  state.ok = state.pos < source.length && source.codeUnitAt(state.pos) == 34;
  if (state.ok) {
    state.pos += 1;
  } else {
    state.fail(state.pos, const ParseError.expected('"'));
  }
}

void _openQuote(State<String> state) {
  final $pos = state.pos;
  _ws(state);
  if (state.ok) {
    _quote(state);
  }
  if (!state.ok) {
    state.pos = $pos;
  }
}

List<int>? _chars(State<String> state) {
  List<int>? $0;
  final source = state.source;
  final $list = <int>[];
  while (true) {
    int? $1;
    state.ok = state.pos < source.length;
    if (state.ok) {
      final pos = state.pos;
      final c = source.readRune(state);
      state.ok = c != 34;
      if (state.ok) {
        $1 = c;
      } else {
        state.pos = pos;
        state.fail(state.pos, ParseError.unexpected(0, c));
      }
    } else {
      state.fail(state.pos, const ParseError.unexpected(0, 'EOF'));
    }
    if (!state.ok) {
      state.ok = state.pos + 1 < source.length &&
          source.codeUnitAt(state.pos) == 34 &&
          source.codeUnitAt(state.pos + 1) == 34;
      if (state.ok) {
        state.pos += 2;
      } else {
        state.fail(state.pos, const ParseError.expected('""'));
      }
      if (state.ok) {
        $1 = 34;
      }
    }
    if (!state.ok) {
      break;
    }
    $list.add($1!);
  }
  state.ok = true;
  if (state.ok) {
    $0 = $list;
  }
  return $0;
}

void _closeQuote(State<String> state) {
  final $pos = state.pos;
  _quote(state);
  if (state.ok) {
    _ws(state);
  }
  if (!state.ok) {
    state.pos = $pos;
  }
}

String? _string(State<String> state) {
  String? $0;
  final $pos = state.pos;
  _openQuote(state);
  if (state.ok) {
    List<int>? $1;
    $1 = _chars(state);
    if (state.ok) {
      _closeQuote(state);
      if (state.ok) {
        final v1 = $1!;
        $0 = String.fromCharCodes(v1);
      }
    }
  }
  if (!state.ok) {
    state.pos = $pos;
  }
  return $0;
}

String? _field(State<String> state) {
  String? $0;
  final source = state.source;
  final $test = (state.context as _StateContext).separatorChar;
  $0 = _string(state);
  if (!state.ok) {
    final $pos = state.pos;
    while (state.pos < source.length) {
      final pos = state.pos;
      final c = source.readRune(state);
      final ok = c != 0xA && c != 0xD && c != 0x22 && c != $test;
      if (!ok) {
        state.pos = pos;
        break;
      }
    }
    state.ok = true;
    if (state.ok) {
      $0 = $pos == state.pos ? '' : source.substring($pos, state.pos);
    }
  }
  return $0;
}

List<String>? _row(State<String> state) {
  List<String>? $0;
  final source = state.source;
  final $calculate = (state.context as _StateContext).separator;
  var $pos = state.pos;
  final $list = <String>[];
  while (true) {
    String? $1;
    $1 = _field(state);
    if (!state.ok) {
      state.pos = $pos;
      break;
    }
    $list.add($1!);
    $pos = state.pos;
    String? $2;
    state.ok = true;
    if (state.ok) {
      $2 = $calculate;
    }
    if (state.ok) {
      final tag = $2!;
      state.ok = source.startsWith(tag, state.pos);
      if (state.ok) {
        state.pos += tag.length;
      } else {
        state.fail(state.pos, ParseError.expected(tag));
      }
    }
    if (!state.ok) {
      break;
    }
  }
  state.ok = $list.isNotEmpty;
  if (state.ok) {
    $0 = $list;
  }
  return $0;
}

void _eol(State<String> state) {
  final source = state.source;
  state.ok = state.pos < source.length;
  if (state.ok) {
    final pos = state.pos;
    final c = source.codeUnitAt(pos);
    String? v;
    switch (c) {
      case 10:
        state.pos++;
        v = '\n';
        break;
      case 13:
        if (source.startsWith('\r\n', pos)) {
          state.pos += 2;
          v = '\r\n';
          break;
        }
        state.pos++;
        v = '\r';
        break;
    }
    state.ok = v != null;
  }
  if (!state.ok) {
    state.fail(state.pos, const ParseError.expected('\n'));
    state.fail(state.pos, const ParseError.expected('\r\n'));
    state.fail(state.pos, const ParseError.expected('\r'));
  }
}

void _eof(State<String> state) {
  final source = state.source;
  state.ok = state.pos >= source.length;
  if (!state.ok) {
    state.fail(state.pos, const ParseError.expected('EOF'));
  }
}

void _rowEnding(State<String> state) {
  final $pos = state.pos;
  _eol(state);
  if (state.ok) {
    final $pos1 = state.pos;
    final $log = state.log;
    state.log = false;
    _eof(state);
    state.log = $log;
    state.ok = !state.ok;
    if (!state.ok) {
      state.pos = $pos1;
      state.fail(state.pos, const ParseError.message(0, 'Unknown error'));
    }
  }
  if (!state.ok) {
    state.pos = $pos;
  }
}

List<List<String>>? _rows(State<String> state) {
  List<List<String>>? $0;
  final $pos = state.pos;
  var $pos1 = state.pos;
  final $list = <List<String>>[];
  while (true) {
    List<String>? $1;
    $1 = _row(state);
    if (!state.ok) {
      state.pos = $pos1;
      break;
    }
    $list.add($1!);
    $pos1 = state.pos;
    _rowEnding(state);
    if (!state.ok) {
      break;
    }
  }
  state.ok = $list.isNotEmpty;
  if (state.ok) {
    $0 = $list;
  }
  if (state.ok) {
    _eol(state);
    if (!state.ok) {
      state.ok = true;
    }
  }
  if (!state.ok) {
    $0 = null;
    state.pos = $pos;
  }
  return $0;
}

List<List<String>>? _parse(State<String> state) {
  List<List<String>>? $0;
  final $pos = state.pos;
  $0 = _rows(state);
  if (state.ok) {
    _eof(state);
  }
  if (!state.ok) {
    $0 = null;
    state.pos = $pos;
  }
  return $0;
}

String _errorMessage(String source, List<ParserException> errors,
    [color, int maxCount = 10, String? url]) {
  final sb = StringBuffer();
  for (var i = 0; i < errors.length; i++) {
    if (i > maxCount) {
      break;
    }

    final error = errors[i];
    final start = error.start;
    final end = error.end;
    if (end > source.length) {
      source += ' ' * (end - source.length);
    }

    final file = SourceFile.fromString(source, url: url);
    final span = file.span(start, end);
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

class ParseError {
  final ParseErrorKind kind;

  final int length;

  final Object? value;

  const ParseError.expected(this.value)
      : kind = ParseErrorKind.expected,
        length = 0;

  const ParseError.message(this.length, String message)
      : kind = ParseErrorKind.message,
        value = message;

  const ParseError.unexpected(this.length, this.value)
      : kind = ParseErrorKind.unexpected;

  const ParseError._(this.kind, this.length, this.value);

  @override
  int get hashCode => kind.hashCode ^ length.hashCode ^ value.hashCode;

  @override
  bool operator ==(other) {
    return other is ParseError &&
        other.kind == kind &&
        other.length == length &&
        other.value == value;
  }

  @override
  String toString() {
    switch (kind) {
      case ParseErrorKind.expected:
        return 'Expected: $value';
      case ParseErrorKind.message:
        return '$value';
      case ParseErrorKind.unexpected:
        return 'Unexpected: $value';
    }
  }

  static List<ParserException> errorReport(
      int offset, List<ParseError> errors) {
    final expected = errors.where((e) => e.kind == ParseErrorKind.expected);
    final result = <ParserException>[];
    if (expected.isNotEmpty) {
      final values = expected.map((e) => '\'${_escape(e.value)}\'').join(', ');
      result.add(ParserException(offset, 0, 'Expected: $values'));
    }

    for (var i = 0; i < errors.length; i++) {
      final error = errors[i];
      switch (error.kind) {
        case ParseErrorKind.expected:
          break;
        case ParseErrorKind.message:
          var length = error.length;
          var newOffset = offset;
          if (length < 0) {
            newOffset += length;
            length = -length;
          }

          final newError =
              ParserException(newOffset, length, error.value as String);
          result.add(newError);
          break;
        case ParseErrorKind.unexpected:
          final newError = ParserException(
              offset, error.length, '\'${_escape(error.value)}\'');
          result.add(newError);
          break;
      }
    }

    return result;
  }

  static String _escape(value) {
    if (value is int) {
      if (value >= 0 && value <= 0xd7ff ||
          value >= 0xe000 && value <= 0x10ffff) {
        value = String.fromCharCode(value);
      } else {
        return value.toString();
      }
    } else if (value is! String) {
      return value.toString();
    }

    final map = {
      '\b': '\\b',
      '\f': '\\f',
      '\n': '\\n',
      '\r': '\\t',
      '\t': '\\t',
      '\v': '\\v',
    };
    var result = value.toString();
    for (final key in map.keys) {
      result = result.replaceAll(key, map[key]!);
    }

    return result;
  }
}

enum ParseErrorKind { expected, message, unexpected }

class ParserException {
  final int end;

  final int start;

  final String text;

  ParserException(this.start, this.end, this.text);
}

class State<T> {
  dynamic context;

  int errorPos = -1;

  int lastErrorPos = -1;

  int minErrorPos = -1;

  bool log = true;

  bool ok = false;

  int pos = 0;

  final T source;

  final List<ParseError?> _errors = List.filled(500, null);

  int _length = 0;

  final List<_Memo> _memos = [];

  State(this.source);

  void fail(int pos, ParseError error) {
    if (log) {
      if (errorPos <= pos && minErrorPos <= pos) {
        if (errorPos < pos) {
          errorPos = pos;
          _length = 0;
        }
        _errors[_length++] = error;
      }

      if (lastErrorPos < pos) {
        lastErrorPos = pos;
      }
    }
  }

  List<ParseError> get errors {
    return List.generate(_length, (i) => _errors[i]!);
  }

  @pragma('vm:prefer-inline')
  void memoize<R>(int id, bool fast, int start, [R? result]) {
    final memo = _Memo(id, fast, start, pos, ok, result);
    for (var i = 0; i < _memos.length; i++) {
      if (_memos[i].id == id) {
        _memos[i] = memo;
        return;
      }
    }

    _memos.add(memo);
  }

  @pragma('vm:prefer-inline')
  _Memo<R>? memoized<R>(int id, bool fast, int start) {
    for (var i = 0; i < _memos.length; i++) {
      final memo = _memos[i];
      if (memo.id == id) {
        if (memo.canRestore(start, fast)) {
          return memo as _Memo<R>;
        }

        break;
      }
    }

    return null;
  }

  @pragma('vm:prefer-inline')
  void restoreLastErrorPos(int pos) {
    if (lastErrorPos < pos) {
      lastErrorPos = pos;
    }
  }

  @pragma('vm:prefer-inline')
  int setLastErrorPos(int pos) {
    final result = lastErrorPos;
    lastErrorPos = pos;
    return result;
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

extension on String {
  @pragma('vm:prefer-inline')
  // ignore: unused_element
  int readRune(State<String> state) {
    final w1 = codeUnitAt(state.pos++);
    if (w1 > 0xd7ff && w1 < 0xe000) {
      if (state.pos < length) {
        final w2 = codeUnitAt(state.pos++);
        if ((w2 & 0xfc00) == 0xdc00) {
          return 0x10000 + ((w1 & 0x3ff) << 10) + (w2 & 0x3ff);
        }

        state.pos--;
      }

      throw FormatException('Invalid UTF-16 character', this, state.pos - 1);
    }

    return w1;
  }

  @pragma('vm:prefer-inline')
  // ignore: unused_element
  int runeAt(int index) {
    final w1 = codeUnitAt(index++);
    if (w1 > 0xd7ff && w1 < 0xe000) {
      if (index < length) {
        final w2 = codeUnitAt(index);
        if ((w2 & 0xfc00) == 0xdc00) {
          return 0x10000 + ((w1 & 0x3ff) << 10) + (w2 & 0x3ff);
        }
      }

      throw FormatException('Invalid UTF-16 character', this, index - 1);
    }

    return w1;
  }

  /// Returns a slice (substring) of the string from [start] to [end].
  @pragma('vm:prefer-inline')
  // ignore: unused_element
  String slice(int start, int end) {
    return substring(start, end);
  }
}

class _Memo<T> {
  final int end;

  final bool fast;

  final int id;

  final bool ok;

  final T? result;

  final int start;

  _Memo(this.id, this.fast, this.start, this.end, this.ok, this.result);

  @pragma('vm:prefer-inline')
  bool canRestore(int start, bool fast) {
    return this.start == start && (this.fast == fast || !this.fast);
  }

  @pragma('vm:prefer-inline')
  T? restore(State state) {
    state.ok = ok;
    state.pos = end;
    return result;
  }
}

class _StateContext {
  final String separator;

  final int separatorChar;

  _StateContext({required this.separator, required this.separatorChar});
}
