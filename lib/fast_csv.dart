import 'package:fast_csv/csv_parser.dart';

/// Parses the CSV data and returns the result as a `List<List<String>>`.
/// - Will not parse numbers
/// - The character `,` is used as a field separator
/// - Line endings are `\n`, `\r\n` or `\r`
/// - The start and end of strings is the character `"`
/// - Escaping a character `"` in a string is parsed via sequence `""`
/// - Exception `FormatException` will be thrown if parsing fails
List<List<String>> parse(String source) {
  const parser = CsvParser();
  final result = parseString(parser.parseStart, source);
  return result;
}
