import 'package:fast_csv/csv_ex_converter.dart';

void main(List<String> args) {
  final parser = CsvExParser(separator: ';');
  final result = CsvExConverter(parser: parser).convert(_data);
  print(result.join('\n'));
  for (var i = 1; i < result.length; i++) {
    final row = result[i];
    final car = row[1];
    final price = num.parse(row[4]);
    print('$car $price');
  }
}

const _data = '''
Year;Make;Model;Description;Price
1997;Ford;E350;"ac, abs, moon";3000.00
1999;Chevy;"Venture ""Extended Edition""";"";4900.00
1999;Chevy;"Venture ""Extended Edition, Very Large""";"";5000.00
1996;Jeep;Grand Cherokee;"MUST SELL!
air, moon roof, loaded";4799.00
''';
