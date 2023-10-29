import 'dart:async';

import 'package:fast_csv/csv_converter.dart';

Future<void> main(List<String> args) async {
  _exampleParseString();
  await _exampleParseStreamWithEvents();
}

const _data = '''
Year,Make,Model,Description,Price
1997,Ford,E350,"ac, abs, moon",3000.00
1999,Chevy,"Venture ""Extended Edition""","",4900.00
1999,Chevy,"Venture ""Extended Edition, Very Large""","",5000.00
1996,Jeep,Grand Cherokee,"MUST SELL!
air, moon roof, loaded",4799.00
''';

Stream<String> _createStream() {
  // Create the stream with 1000000 rows
  const count = 1000 * 1000;
  final controller = StreamController<String>();
  final sink = controller.sink;
  const row = '1999,Chevy,"Venture В«Extended EditionВ»","",4900.00';
  const rowsInChunk = count ~/ 100;
  final chunk = List.generate(rowsInChunk, (i) => row).join('\n');
  print('Total data amount ${row.length * count} UTF-16 code units.');
  print('The data will arrive in ${chunk.length} UTF-16 code unit chunks.');
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
  final sw = Stopwatch();
  sw.start();
  final parser = _MyParser(() async {
    print('Saving to virtual database complete in ${sw.elapsed}');
    sw.stop();
  });

  await stream.transform(CsvConverter(parser: parser)).first;
}

void _exampleParseString() {
  print('=========================');
  print('Parsing string');
  final result = CsvConverter().convert(_data);
  print(result.join('\n'));
  for (var i = 1; i < result.length; i++) {
    final row = result[i];
    final car = row[1];
    final price = num.parse(row[4]);
    print('$car $price');
  }
}

class _MyParser extends CsvParser {
  final Future<void> Function()? onComplete;

  int _count = 0;

  int _totalCount = 0;

  int _transactionCount = 0;

  final List<List<String>> _rows = [];

  _MyParser([this.onComplete]);

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
          if (onComplete != null) {
            Timer.run(onComplete!);
          }

          // Completely freeing memory from the entire list
          result = const <List<String>>[] as R;
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
