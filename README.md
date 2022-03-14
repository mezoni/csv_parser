# fast_csv

Classic non-configurable CSV parser suitable for most use cases. Pretty fast parsing.

Version: 0.1.29

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

## An example of using a configurable parser

This parser is slightly slower than the non-configurable parser.

```dart
import 'package:fast_csv/fast_csv_ex.dart' as _fast_csv_ex;

void main(List<String> args) {
  final result = _fast_csv_ex.parse(_csv, separator: ';');
  print(result.join('\n'));
  for (final row in result) {
    final car = row[1];
    final price = num.parse(row[4]);
    print('$car $price');
  }
}

const _csv = '''
1997;Ford;E350;"ac, ""abs"", moon";3000.00
1999;Chevy;"Venture В«Extended EditionВ»";"";4900.00
1996;Jeep;Grand Cherokee;"MUST SELL! air, moon roof, loaded";4799.00
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

const _row = Named('_row', SeparatedList1(_field, Tag(',')));

const _rowEnding = Named('_rowEnding', Sequence<String>([_eol, Not(_eof)]));

const _rows =
    Named('_rows', Terminated(SeparatedList1(_row, _rowEnding), Opt(_eol)));

const _string = Named(
    '_string', Delimited(_openQuote, Map$(_chars, _toString), _closeQuote));

const _text = TakeWhile(NotCharClass('[,"] | #xA | #xD'));

const _toString =
    ExprTransformer<List<int>, String>('x', 'String.fromCharCodes({{x}})');

const _ws = Named('_ws', SkipWhile(CharClass('#x9 | #x20')));

```

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
Time passed: 0.000, Test 'csv': 3111.059 ms
Time passed: 3.113, Test 'fast_csv_ex': 688.029 ms
Time passed: 3.801, Test 'fast_csv': 620.634 ms
Time passed: 4.422, Test 'csv': 3102.082 ms
Time passed: 7.524, Test 'fast_csv_ex': 687.735 ms
Time passed: 8.212, Test 'fast_csv': 577.923 ms
Time passed: 8.790, Test 'csv': 3067.303 ms
Time passed: 11.857, Test 'fast_csv_ex': 661.551 ms
Time passed: 12.519, Test 'fast_csv': 571.068 ms
Time passed: 13.090, Test 'csv': 3034.619 ms
Time passed: 16.124, Test 'fast_csv_ex': 675.33 ms
Time passed: 16.800, Test 'fast_csv': 536.99 ms
Time passed: 17.337, Test 'csv': 3032.914 ms
Time passed: 20.370, Test 'fast_csv_ex': 672.563 ms
Time passed: 21.042, Test 'fast_csv': 577.966 ms
```