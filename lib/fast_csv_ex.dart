import 'csv_ex_converter.dart';

/// Parses the CSV data and returns the result as a `List<List<String>>`.
/// - Will not parse numbers
/// - The field separator is parsed as specified in the `separator` argument
/// - Line endings are `\n`, `\r\n` or `\r`
/// - The start and end of strings is the character `"`
/// - Escaping a character `"` in a string is parsed via sequence `""`
/// - Exception `FormatException` will be thrown if parsing fails
List<List<String>> parse(String source, {String separator = ','}) {
  final parser = CsvExParser(separator: separator);
  final result = CsvExConverter(parser: parser).convert(source);
  return result;
}
