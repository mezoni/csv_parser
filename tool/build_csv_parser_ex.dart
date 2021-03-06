import 'package:parser_builder/branch.dart';
import 'package:parser_builder/bytes.dart';
import 'package:parser_builder/capture.dart';
import 'package:parser_builder/char_class.dart';
import 'package:parser_builder/character.dart';
import 'package:parser_builder/combinator.dart';
import 'package:parser_builder/error.dart';
import 'package:parser_builder/fast_build.dart';
import 'package:parser_builder/multi.dart';
import 'package:parser_builder/parser_builder.dart';
import 'package:parser_builder/sequence.dart';

void main(List<String> args) async {
  final context = Context();
  final filename = 'lib/fast_csv_ex.dart';
  await fastBuild(context, [_parse], filename,
      footer: __footer, header: __header);
}

const __footer = '''
class _StateContext {
  final String separator;

  final int separatorChar;

  _StateContext({required this.separator, required this.separatorChar});
}
''';

const __header = r'''
// This code was generated by a tool.
// https://github.com/mezoni/parser_builder

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
  state.context = _StateContext(
      separator: separator,
      separatorChar: separatorChar);
  final result = _parse(state);
  if (!state.ok) {
    final message = _errorMessage(source, state.errors);
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

const _isSeparator = VariableAction<bool>(
    ['c'], '{{c}} != 0xA && {{c}} != 0xD && {{c}} != 0x22 && {{c}} != {{sep}}',
    key: 'sep', init: '(state.context as _StateContext).separatorChar');

const _openQuote = Named('_openQuote', Fast<String>(Pair(_ws, _quote)));

const _parse = Named('_parse', Terminated(_rows, _eof));

const _quote = Named('_quote', Tag('"'));

const _row = Named('_row', SeparatedList1(_field, _separator));

const _rowEnding = Named('_rowEnding', Fast<String>(Pair(_eol, Not(_eof))));

const _rows =
    Named('_rows', Terminated(SeparatedList1(_row, _rowEnding), Opt(_eol)));

const _separator = TagOf(Calculate(VariableAction([], '{{sep}}',
    key: 'sep', init: '(state.context as _StateContext).separator')));

const _string = Named<String, String>(
    '_string',
    HandleLastErrorPos(
      Map3(
          CaptureStart('start', _openQuote),
          _chars,
          Alt2(
            _closeQuote,
            FailMessage(
              LastErrorPositionAction(),
              'Unterminated string',
              CapturedValueAction('start'),
            ),
          ),
          ExpressionAction<String>(['v'], 'String.fromCharCodes({{v}})')),
    ));

const _text = TakeWhile(_isSeparator);

const _ws = Named('_ws', SkipWhile(CharClass('#x9 | #x20')));
