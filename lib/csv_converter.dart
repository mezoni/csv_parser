import 'dart:async';
import 'dart:convert';

import 'csv_parser.dart';

/// The [CsvConverter] converts CSV data to [List<List<String>>] value.
///
/// If event-based parsing is required, then the corresponding parser instance
/// (with event handlers) must be passed as a constructor argument.
class CsvConverter with Converter<String, List<List<String>>> {
  final CsvParser _parser;

  CsvConverter({
    CsvParser? parser,
  }) : _parser = parser ?? const CsvParser();

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
