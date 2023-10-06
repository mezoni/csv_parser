import 'dart:convert';

import 'csv_ex_parser.dart' as csv_ex_parser;
import 'csv_parser.dart' as csv_parser;

/// The [FastCsvConverter] converts CSV data to [List<List<String>>] value.
///
/// If event-based parsing is required, then the corresponding parser instance
/// (with event handlers) must be passed as a constructor argument.
class FastCsvConverter with Converter<String, List<List<String>>> {
  final csv_parser.CsvParser _parser;

  FastCsvConverter({
    csv_parser.CsvParser? parser,
  }) : _parser = parser ?? const csv_parser.CsvParser();

  @override
  List<List<String>> convert(String input) {
    final result = csv_parser.parseString(_parser.parseStart, input);
    return result;
  }

  @override
  Sink<String> startChunkedConversion(Sink<List<List<String>>> sink) {
    final input = csv_parser.parseAsync(_parser.parseStart$Async, (result) {
      final result2 = result.getResult();
      sink.add(result2);
    });

    return input;
  }
}

/// The [FastCsvExConverter] converts CSV data to [List<List<String>>] value.
///
/// If event-based parsing is required, the corresponding parser instances must
/// have appropriate handlers.
class FastCsvExConverter with Converter<String, List<List<String>>> {
  final csv_ex_parser.CsvExParser _parser;

  FastCsvExConverter({
    csv_ex_parser.CsvExParser? parser,
  }) : _parser = parser ?? csv_ex_parser.CsvExParser();

  @override
  List<List<String>> convert(String input) {
    final result = csv_ex_parser.parseString(_parser.parseStart, input);
    return result;
  }

  @override
  Sink<String> startChunkedConversion(Sink<List<List<String>>> sink) {
    final input = csv_ex_parser.parseAsync(_parser.parseStart$Async, (result) {
      final result2 = result.getResult();
      sink.add(result2);
    });

    return input;
  }
}
