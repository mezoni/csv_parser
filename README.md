# fast_csv

Classic CSV parsers suitable for most use cases. Pretty fast parsing. With experimental event-based streaming parsing.

Version: 0.2.1

[![Pub Package](https://img.shields.io/pub/v/fast_csv.svg)](https://pub.dev/packages/fast_csv)
[![GitHub Issues](https://img.shields.io/github/issues/mezoni/csv_parser.svg)](https://github.com/mezoni/csv_parser/issues)
[![GitHub Forks](https://img.shields.io/github/forks/mezoni/csv_parser.svg)](https://github.com/mezoni/csv_parser/forks)
[![GitHub Stars](https://img.shields.io/github/stars/mezoni/csv_parser.svg)](https://github.com/mezoni/csv_parser/stargazers)
[![GitHub License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://raw.githubusercontent.com/mezoni/csv_parser/main/LICENSE)

## Example of the parser usage

```dart
import 'dart:async';

import 'package:fast_csv/csv_parser.dart';
import 'package:fast_csv/fast_csv.dart' as fast_csv;

Future<void> main(List<String> args) async {
  _exampleParseString();
  await _exampleParseStream();
}

const _csv = '''
1997,Ford,E350,"ac, ""abs"", moon",3000.00
1999,Chevy,"Venture В«Extended EditionВ»","",4900.00
1996,Jeep,Grand Cherokee,"MUST SELL! air, moon roof, loaded",4799.00''';

Stream<String> _createStream() {
  // Create the stream with 1000000 rows
  const count = 1000 * 1000;
  final controller = StreamController<String>();
  final sink = controller.sink;
  const row = '1999,Chevy,"Venture В«Extended EditionВ»","",4900.00';
  const rowsInChunk = count ~/ 100;
  final chunk = List.generate(rowsInChunk, (i) => row).join('\n');
  print('Total data amount ${chunk.length * rowsInChunk} code units.');
  print('The data will arrive in ${chunk.length} code units chunks.');
  var i = 0;
  Timer.periodic(Duration.zero, (timer) {
    sink.add(chunk);
    i += rowsInChunk;
    if (i <= count) {
      sink.add('\n');
    }

    if (i >= count) {
      controller.close();
      timer.cancel();
    }
  });

  return controller.stream;
}

Future<void> _exampleParseStream() async {
  print('=========================');
  print('Start streaming parsing');
  // Get external data
  final stream = _createStream();
  final parser = _MyParser();
  final completer = Completer<void>();
  final sw = Stopwatch();
  sw.start();
  print('Start saving to virtual database');
  final input = parseAsync(parser.parseStart$Async, (result) {
    sw.stop();
    print('Saving to virtual database complete in ${sw.elapsed}');
    try {
      final input = result.input;
      print('Max buffer load: ${input.bufferLoad} code units');
      result.getResult();
      completer.complete();
    } catch (e, s) {
      completer.completeError(e, s);
    }
  });
  stream.listen(input.add, onDone: input.close);
  return completer.future;
}

void _exampleParseString() {
  final result = fast_csv.parse(_csv);
  print(result.join('\n'));
  for (final row in result) {
    final car = row[1];
    final price = num.parse(row[4]);
    print('$car $price');
  }
}

class _MyParser extends CsvParser {
  int _count = 0;

  int _totalCount = 0;

  int _transactionCount = 0;

  final List<List<String>> _rows = [];

  @override
  void beginEvent(CsvParserEvent event) {
    if (event == CsvParserEvent.startEvent) {
      _count = 0;
      _totalCount = 0;
      _transactionCount = 0;
      _rows.clear();
    }
  }

  @override
  R? endEvent<R>(CsvParserEvent event, R? result, bool ok) {
    void saveRows(bool isLast) {
      final rows = _rows.toList();
      _rows.clear();
      Timer.run(() async {
        // Asynchronous saving to the database.
        await _saveToDatabase(rows, isLast);
      });
    }

    if (ok) {
      switch (event) {
        case CsvParserEvent.rowEvent:
          final row = result as List<String>;
          _rows.add(row);
          if (_rows.length > 5000) {
            saveRows(false);
          }

          break;
        case CsvParserEvent.startEvent:
          saveRows(true);
        default:
      }
    }

    return result;
  }

  Future<void> _saveToDatabase(List<List<String>> rows, bool isLast) async {
    _transactionCount++;
    _count += rows.length;
    _totalCount += rows.length;
    if (_count > 100000 || isLast) {
      print(
          'Saved to virtual database $_totalCount row(s) in $_transactionCount transaction(s)');
      _count = 0;
    }

    if (isLast) {
      print(
          'Totally saved to virtual database $_totalCount row(s) in $_transactionCount transaction(s)');
    }
  }
}

```

Output:

```
[1997, Ford, E350, ac, "abs", moon, 3000.00]
[1999, Chevy, Venture В«Extended EditionВ», , 4900.00]
[1996, Jeep, Grand Cherokee, MUST SELL! air, moon roof, loaded, 4799.00]
Ford 3000.0
Chevy 4900.0
Jeep 4799.0
=========================
Start streaming parsing
Total data amount 5299990000 code units.
The data will arrive in 529999 code unit chunks.
Start saving to virtual database
Saved to virtual database 100020 row(s) in 20 transaction(s)
Saved to virtual database 200040 row(s) in 40 transaction(s)
Saved to virtual database 300060 row(s) in 60 transaction(s)
Saved to virtual database 400080 row(s) in 80 transaction(s)
Saved to virtual database 500100 row(s) in 100 transaction(s)
Saved to virtual database 600120 row(s) in 120 transaction(s)
Saved to virtual database 700140 row(s) in 140 transaction(s)
Saved to virtual database 800160 row(s) in 160 transaction(s)
Saved to virtual database 900180 row(s) in 180 transaction(s)
Saving to virtual database complete in 0:00:04.634083
Max buffer load: 530053 code units
Saved to virtual database 1000000 row(s) in 200 transaction(s)
Totally saved to virtual database 1000000 row(s) in 200 transaction(s)
```

## About the implementation of parsers

Parsers are generated from PEG grammars.  
Software used to generate parsers [![Pub Package](https://img.shields.io/pub/v/peg.svg)](https://pub.dev/packages/peg)  
Below is the source code for one of the grammars.

```
%%

const CsvParser();

%%

Start = v:Rows Eof ;

@inline
Chars = ($[^"]+ / '""' <String>{ $$ = '"'; })* ;

@inline
CloseQuote = '"' Spaces ;

@inline
Eof = !. ;

@inline
Eol = '\n' / '\r\n' / '\r' ;

@event
@inline
Field = String / Text ;

@inline
OpenQuote = Spaces '"' ;

@inline
RowEnding = Eol !Eof ;

@event
Row = @sepBy(Field, ',') ;

Rows = v:@sepBy(Row, RowEnding) Eol? ;

Spaces = [ \t]* ;

String
String = OpenQuote v:Chars CloseQuote { $$ = v.join(); } ;

Text = $[^,"\n\r]* ;

```

## An example of using a configurable parser

This parser is slightly slower than the non-configurable parser.  

The difference between using a normal parser and using a configurable parser is that you can specify a field separator.  
Any value (such as a space or semicolon).

```dart
import 'package:fast_csv/fast_csv_ex.dart' as fast_csv_ex;

void main(List<String> args) {
  final result = fast_csv_ex.parse(_csv, separator: ';');
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

## About the implementation of parsers

Parsers are generated from PEG grammars.  
Software used to generate parsers [![Pub Package](https://img.shields.io/pub/v/peg.svg)](https://pub.dev/packages/peg)  
Below is the source code for one of the grammars.

```
%%

const CsvParser();

%%

@event
Start = v:Rows Eof ;

@inline
Chars = ($[^"]+ / '""' <String>{ $$ = '"'; })* ;

@inline
CloseQuote = '"' Spaces ;

@inline
Eof = !. ;

Eol = '\n' / '\r\n' / '\r' ;

@event
@inline
Field = String / Text ;

@inline
OpenQuote = Spaces '"' ;

@inline
RowEnding = Eol !Eof ;

@event
Row = @sepBy(Field, ',') ;

Rows = v:@sepBy(Row, RowEnding) Eol? ;

Spaces = [ \t]* ;

String
String = OpenQuote v:Chars CloseQuote { $$ = v.join(); } ;

Text = $[^,"\n\r]* ;

```

## An example of using a configurable parser

This parser is slightly slower than the non-configurable parser.  

The difference between using a normal parser and using a configurable parser is that you can specify a field separator.  
Any value (such as a space or semicolon).

```dart
import 'package:fast_csv/fast_csv_ex.dart' as fast_csv_ex;

void main(List<String> args) {
  final result = fast_csv_ex.parse(_csv, separator: ';');
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