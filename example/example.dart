import 'dart:async';

import 'package:fast_csv/csv_parser.dart';
import 'package:fast_csv/fast_csv.dart' as fast_csv;

Future<void> main(List<String> args) async {
  _exampleParseString();
  await _exampleParseStreamWithEvents();
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
  print('Total data amount ${row.length * count} code units.');
  print('The data will arrive in ${chunk.length} code unit chunks.');
  var i = 0;
  Timer.periodic(Duration.zero, (timer) {
    sink.add(chunk);
    i += rowsInChunk;
    if (i < count) {
      sink.add('\n');
    }

    if (i >= count) {
      controller.close();
      timer.cancel();
    }
  });

  return controller.stream;
}

Future<void> _exampleParseStreamWithEvents() async {
  print('=========================');
  print('Start streaming parsing with events');
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
          if (_rows.length > 10000) {
            saveRows(false);
          }

          // Free memory
          result = const <String>[] as R;
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
