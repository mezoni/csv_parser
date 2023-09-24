import 'package:fast_csv/src/csv_ex_parser.dart';

/// Parses the CSV data and returns the result as a `List<List<String>>`.
/// - Will not parse numbers
/// - The field separator is parsed as specified in the `separator` argument
/// - Line endings are `\n`, `\r\n` or `\r`
/// - The start and end of strings is the character `"`
/// - Escaping a character `"` in a string is parsed via sequence `""`
/// - Exception `FormatException` will be thrown if parsing fails
List<List<String>> parse(String source, {String separator = ','}) {
  if (separator.isEmpty) {
    throw ArgumentError('Must not be empty', 'separator');
  }

  final runes = separator.runes.toList();
  if (runes.length != 1) {
    throw ArgumentError.value(separator, 'separator',
        'The length of the separator must be one character');
  }

  final parser = CsvExParser(
    separator: separator,
    separatorChar: runes[0],
  );
  final result = parseString(parser.parseStart, source);
  return result;
}
