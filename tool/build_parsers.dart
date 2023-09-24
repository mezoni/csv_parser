import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final exitCodes = <Future<int>>[];
  const files = [
    'lib/src/csv_parser.peg',
    'lib/src/csv_ex_parser.peg',
  ];
  final process = await Process.start(Platform.executable, [
    'pub',
    'global',
    'activate',
    'peg',
  ]);
  unawaited(process.stdout.transform(utf8.decoder).forEach(print));
  unawaited(process.stderr.transform(utf8.decoder).forEach(print));
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    exit(exitCode);
  }

  for (final file in files) {
    final process = await Process.start(Platform.executable, [
      'pub',
      'global',
      'run',
      'peg',
      file,
    ]);
    unawaited(process.stdout.transform(utf8.decoder).forEach(print));
    unawaited(process.stderr.transform(utf8.decoder).forEach(print));
    exitCodes.add(process.exitCode);
  }

  final results = await Future.wait(exitCodes);
  final failed = results.where((e) => e != 0);
  if (failed.isNotEmpty) {
    exit(failed.first);
  }
}
