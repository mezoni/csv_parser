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
  final String separator;

  final int separatorChar;

  _StateContext({required this.separator, required this.separatorChar});
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
      NoneOf([0x22]),
      Value(0x22, Tag('""')),
    ])));

const _closeQuote = Named('_closeQuote', Sequence<String>([_quote, _ws]));

const _eof = Named('_eof', Eof<String>());

const _eol = Named('_eol', Tags(['\n', '\r\n', '\r']));

const _field = Named('_field', Alt([_string, _text]));

const _openQuote = Named('_openQuote', Sequence<String>([_ws, _quote]));

const _parse = Named('_parse', Terminated(_rows, _eof));

const _quote = Named('_quote', Tag('"'));

const _row = Named('_row', SeparatedList1(_field, _separator));

const _rowEnding = Named('_rowEnding', Sequence<String>([_eol, Not(_eof)]));

const _rows =
    Named('_rows', Terminated(SeparatedList1(_row, _rowEnding), Opt(_eol)));

const _separator = Named('_separator',
    TagEx(VarTransformer('(state.context as _StateContext).separator')));

const _string = Named(
    '_string',
    Map3(
        _openQuote,
        _chars,
        _closeQuote,
        ExprTransformer<String>(
            ['o', 'v', 'c'], 'String.fromCharCodes({{v}})')));

const _text = TakeWhile(_IsSeparator());

const _ws = Named('_ws', SkipWhile(CharClass('#x9 | #x20')));

class _IsSeparator extends ExprTransformer<bool> {
  const _IsSeparator()
      : super(const [
          'x'
        ], '{{x}} != 0xA && {{x}} != 0xD && {{x}} != 0x22 && {{x}} != {{name}}');

  @override
  String declare(Transformation transformation) {
    transformation.checkArguments(parameters);
    final name = transformation.name;
    final result =
        'final {{name}} = (state.context as _StateContext).separatorChar;';
    return result.replaceAll('{{name}}', name);
  }

  @override
  String invoke(Transformation transformation) {
    var result = super.invoke(transformation);
    final name = transformation.name;
    return result.replaceAll('{{name}}', name);
  }
}
