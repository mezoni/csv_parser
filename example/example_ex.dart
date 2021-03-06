import 'package:fast_csv/fast_csv_ex.dart' as _fast_csv_ex;

void main(List<String> args) {
  final result = _fast_csv_ex.parse(_csv, separator: ';');
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
