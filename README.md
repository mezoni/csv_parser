# fast_csv

Classic CSV parsers suitable for most use cases. Pretty fast parsing.

Version: 0.2.0

## Example of the parser usage

```dart
import 'package:fast_csv/fast_csv.dart' as fast_csv;

void main(List<String> args) {
  final result = fast_csv.parse(_csv);
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

## About the implementation of parsers

Parsers are generated from PEG grammars.  
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