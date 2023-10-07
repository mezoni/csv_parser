import 'dart:async';
import 'dart:convert';

import 'csv_ex_parser.dart';

/// The [CsvExConverter] converts CSV data to [List<List<String>>] value.
///
/// If event-based parsing is required, the corresponding parser instances must
/// have appropriate handlers.
class CsvExConverter with Converter<String, List<List<String>>> {
  final CsvExParser _parser;

  CsvExConverter({
    CsvExParser? parser,
  }) : _parser = parser ?? CsvExParser();

  @override
  List<List<String>> convert(String input) {
    final result = parseString(_parser.parseStart, input);
    return result;
  }

  @override
  Sink<String> startChunkedConversion(Sink<List<List<String>>> sink) {
    final input = parseAsync(_parser.parseStart$Async, (result) {
      try {
        final value = result.getResult();
        sink.add(value);
      } catch (error, stackTrace) {
        if (sink case final EventSink<Object?> sink) {
          sink.addError(error, stackTrace);
        } else {
          rethrow;
        }
      }
    });

    return input;
  }
}
