# fast_csv

Classic non-configurable CSV parser suitable for most use cases. Pretty fast parsing.

Version: 0.1.37

Also demonstrates an example of creating a parser using [`parser_builder`](https://github.com/mezoni/parser_builder).  
Creating a fast parser is very easy.  
It may be a little slower, a little faster, or have the same performance as a handwritten one, but the time it takes to create it can be reduced by several times using [`parser_builder`](https://github.com/mezoni/parser_builder).

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

## Source code of the parser

Below is the source code for the parser definition.

```dart
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

```

File with generated parser code:  
[fast_csv.dart](https://github.com/mezoni/csv_parser/blob/master/lib/fast_csv.dart)

## An example of using a configurable parser

This parser is slightly slower than the non-configurable parser.  

The difference between using a normal parser and using a configurable parser is that you can specify a field separator.  
Any value (such as a space or semicolon).

## Performance tests

The comparison was made with the following CSV parser: [`csv`](https://pub.dev/packages/csv).  
The files from the resource listed below were used to measure performance (excluding files with format violation).  

https://people.sc.fsu.edu/~jburkardt/data/csv/csv.html

Source code for testing procedures.

```dart
void _test1(int count) {
  for (var i = 0; i < count; i++) {
    for (var k = 0; k < _tables.length; k++) {
      final table = _tables[k];
      final res = CsvToListConverter(
              allowInvalid: false, eol: '\n', shouldParseNumbers: false)
          .convert(table);
    }
  }
}

void _test2(int count) {
  for (var i = 0; i < count; i++) {
    for (var k = 0; k < _tables.length; k++) {
      final table = _tables[k];
      final res = _fast_csv_ex.parse(table);
    }
  }
}

void _test3(int count) {
  for (var i = 0; i < count; i++) {
    for (var k = 0; k < _tables.length; k++) {
      final table = _tables[k];
      final res = _fast_csv.parse(table);
    }
  }
}

```

Results:

```
List of files:
---------------
test_csv\addresses.csv
test_csv\airtravel.csv
test_csv\biostats.csv
test_csv\cities.csv
test_csv\crash_catalonia.csv
test_csv\deniro.csv
test_csv\example.csv
test_csv\faithful.csv
test_csv\ford_escort.csv
test_csv\freshman_kgs.csv
test_csv\freshman_lbs.csv
test_csv\grades.csv
test_csv\homes.csv
test_csv\hooke.csv
test_csv\hurricanes.csv
test_csv\hw_25000.csv
test_csv\lead_shot.csv
test_csv\letter_frequency.csv
test_csv\news_decline.csv
test_csv\nile.csv
test_csv\oscar_age_female.csv
test_csv\snakes_count_10.csv
test_csv\snakes_count_100.csv
test_csv\snakes_count_1000.csv
test_csv\snakes_count_10000.csv
test_csv\tally_cab.csv
test_csv\taxables.csv
test_csv\trees.csv
test_csv\zillow.csv
---------------
Parse in loop by 5 times:
Results:
Time passed: 0.000, Test 'csv': 3120.185 ms
Time passed: 3.122, Test 'fast_csv_ex': 748.974 ms
Time passed: 3.871, Test 'fast_csv': 634.764 ms
Time passed: 4.506, Test 'csv': 3083.998 ms
Time passed: 7.590, Test 'fast_csv_ex': 648.111 ms
Time passed: 8.238, Test 'fast_csv': 653.347 ms
Time passed: 8.891, Test 'csv': 3049.418 ms
Time passed: 11.941, Test 'fast_csv_ex': 709.234 ms
Time passed: 12.650, Test 'fast_csv': 685.714 ms
Time passed: 13.336, Test 'csv': 3077.536 ms
Time passed: 16.413, Test 'fast_csv_ex': 727.57 ms
Time passed: 17.141, Test 'fast_csv': 692.093 ms
Time passed: 17.833, Test 'csv': 3058.838 ms
Time passed: 20.892, Test 'fast_csv_ex': 726.068 ms
Time passed: 21.618, Test 'fast_csv': 685.781 ms
```