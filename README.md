# fast_csv

Classic non-configurable CSV parser suitable for most use cases. Pretty fast parsing.  

Also demonstrates an example of creating a parser using [`parser_builder`](https://github.com/mezoni/parser_builder)  
Creating a fast parser is very easy.  
It may be a little slower, a little faster, or have the same performance as a handwritten one, but the time it takes to create it can be reduced by several times using [`parser_builder`](https://github.com/mezoni/parser_builder).

Version: 0.1.4

## Example of the parser usage

```dart
import 'package:fast_csv/fast_csv.dart' as _fast_csv;

void main(List<String> args) {
  final result = _fast_csv.parse(_csv);
  print(result.join('\n'));
  for (final row in result) {
    final car = row[1];
    final price = num.parse(row[4]);
    print('$car $price');
  }
}

const _csv = '''
1997,Ford,E350,"ac, ""abs"", moon",3000.00
1999,Chevy,"Venture В«Extended EditionВ»","",4900.00
1996,Jeep,Grand Cherokee,"MUST SELL! air, moon roof, loaded",4799.00
''';

```

## CSV parser declaration

`tool/build_csv_parser.dart`

```dart
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
  final filename = 'lib/fast_csv.dart';
  await fastBuild(context, [_parse], filename, header: __header);
}

const __header = r'''
// This code was generated by a tool.
// https://github.com/mezoni/parser_builder

// ignore_for_file: unused_local_variable

import 'package:source_span/source_span.dart';

/// Parses the CSV data and returns the result as a `List<List<String>>`.
/// - Will not parse numbers
/// - The character `,` is used as a field separator
/// - Line endings are `\n` or `\r\n`
/// - The start and end of strings is the character `"`
/// - Escaping a character `"` in a string is parsed via sequence `""`
/// - Exception `FormatException` will be thrown if parsing fails
List<List<String>> parse(String source) {
    final state = StringState(source);
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

const _parse = Named('_parse', Terminated(_rows, Eof<String>()));

const _row = Named('_row', SeparatedList1(_field, Tag(',')));

const _rows = Named(
    '_rows',
    Terminated(
        SeparatedList1(_row, Skip<String>([_eol, Not(Eof())])), Opt(_eol)));

const _string =
    Named('_string', Delimited(Tag('"'), Map$(_chars, _toString), Tag('"')));

const _text = Named('_text', TakeWhile1(NotCharClass('[,"] | #xA | #xD')));

const _toString = TX<List<int>, String>('String.fromCharCodes({{x}})');

```
