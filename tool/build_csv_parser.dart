import 'package:parser_builder/branch.dart';
import 'package:parser_builder/bytes.dart';
import 'package:parser_builder/char_class.dart';
import 'package:parser_builder/character.dart';
import 'package:parser_builder/combinator.dart';
import 'package:parser_builder/fast_build.dart';
import 'package:parser_builder/multi.dart';
import 'package:parser_builder/parser_builder.dart';
import 'package:parser_builder/sequence.dart';

void main(List<String> args) async {
  final context = Context();
  final filename = 'lib/fast_csv.dart';
  await fastBuild(context, [_parse], filename, header: __header);
}

const __header = r'''
// This code was generated by a tool.
// https://github.com/mezoni/parser_builder

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

''';

const _chars = Named(
    '_chars',
    Many0(Alt2(
      NoneOf([0x22]),
      Value(0x22, Tag('""')),
    )));

const _closeQuote = Named('_closeQuote', Fast<String>(Pair(_quote, _ws)));

const _eof = Named('_eof', Eof<String>());

const _eol = Named('_eol', Tags(['\n', '\r\n', '\r']));

const _field = Named('_field', Alt2(_string, _text));

const _openQuote = Named('_openQuote', Fast<String>(Pair(_ws, _quote)));

const _parse = Named('_parse', Terminated(_rows, _eof));

const _quote = Named('_quote', Tag('"'));

const _row = Named('_row', SeparatedList1(_field, Tag(',')));

const _rowEnding = Named('_rowEnding', Fast<String>(Pair(_eol, Not(_eof))));

const _rows =
    Named('_rows', Terminated(SeparatedList1(_row, _rowEnding), Opt(_eol)));

const _string = Named(
    '_string',
    Map3(_openQuote, _chars, _closeQuote,
        ExpressionAction<String>(['v'], 'String.fromCharCodes({{v}})')));

const _text = TakeWhile(NotCharClass('[,"] | #xA | #xD'));

const _ws = Named('_ws', SkipWhile(CharClass('#x9 | #x20')));
