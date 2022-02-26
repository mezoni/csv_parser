import 'package:parser_builder/branch.dart';
import 'package:parser_builder/bytes.dart';
import 'package:parser_builder/character.dart';
import 'package:parser_builder/combinator.dart';
import 'package:parser_builder/fast_build.dart';
import 'package:parser_builder/multi.dart';
import 'package:parser_builder/parser_builder.dart';
import 'package:parser_builder/sequence.dart';
import 'package:parser_builder/transformers.dart';

void main(List<String> args) async {
  final context = Context();
  context.optimizeForSize = false;
  final filename = 'lib/fast_csv_ex.dart';
  await fastBuild(context, [_parse], filename,
      footer: __footer, header: __header);
}

const __footer = '''
class _StateContext {
  final bool Function(int) notTextChar;

  final String separator;

  _StateContext({required this.notTextChar, required this.separator});
}
''';

const __header = r'''
// This code was generated by a tool.
// https://github.com/mezoni/parser_builder

// ignore_for_file: unused_local_variable

import 'package:source_span/source_span.dart';

/// Parses the CSV data and returns the result as a `List<List<String>>`.
/// - Will not parse numbers
/// - The field separator is parsed as specified in the `separator` argument
/// - Line endings are `\n` or `\r\n`
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
  final state = StringState(source);
  final separatorChar = separator.runes.first;
  state.context = _StateContext(
      notTextChar: (int x) => !(x == 0xA || x == 0xD || x == 0x22 || x == separatorChar),
      separator: separator);
  final result = _parse(state);
  if (!state.ok) {
    final errors = Err.errorReport(state.error);
    final message = _errorMessage(source, errors);
    throw FormatException('\n$message');
  }

  return result!;
}

''';

const _chars = Named(
    '_chars',
    Many0(Alt([
      Value(0x22, Tag('""')),
      Satisfy(NotCharClass('["]')),
    ])));

const _empty = Named('_empty', Value<String, String>(''));

const _eol = Named('_eol', LineEnding());

const _field = Named('_field', Alt([_text, _string, _empty]));

const _notTextChar =
    TX<int, bool>('(state.context as _StateContext).notTextChar({{x}})');

const _parse = Named('_parse', Terminated(_rows, Eof<String>()));

const _row = Named('_row', SeparatedList1(_field, _separator));

const _rows = Named(
    '_rows',
    Terminated(
        SeparatedList1(_row, Skip<String>([_eol, Not(Eof())])), Opt(_eol)));

const _separator = Named(
    '_separator', TagEx(TX('(state.context as _StateContext).separator')));

const _string =
    Named('_string', Delimited(Tag('"'), Map$(_chars, _toString), Tag('"')));

const _text = Named('_text', TakeWhile1(_notTextChar));

const _toString = TX<List<int>, String>('String.fromCharCodes({{x}})');
