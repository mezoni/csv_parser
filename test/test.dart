import 'package:fast_csv/fast_csv.dart' as fast_csv;
import 'package:test/test.dart';

void main(List<String> args) {
  _test();
}

void _test() {
  test('CSV parser', () {
    {
      const s = '''
123''';
      final r = fast_csv.parse(s);
      expect(r, [
        ['123']
      ]);
    }
    {
      const s = '''
123
''';
      final r = fast_csv.parse(s);
      expect(r, [
        ['123']
      ]);
    }
    {
      const s = '''
123
456
''';
      final r = fast_csv.parse(s);
      expect(r, [
        ['123'],
        ['456']
      ]);
    }
    {
      const s = '''
123,"abc😄"
456,def😄
''';
      final r = fast_csv.parse(s);
      expect(r, [
        ['123', 'abc😄'],
        ['456', 'def😄']
      ]);
    }
    {
      const s = '''
123,"""abc😄"""
456,def😄
''';
      final r = fast_csv.parse(s);
      expect(r, [
        ['123', '"abc😄"'],
        ['456', 'def😄']
      ]);
    }
    {
      const s = '''
123,"ab""c😄"""
456,def😄
''';
      final r = fast_csv.parse(s);
      expect(r, [
        ['123', 'ab"c😄"'],
        ['456', 'def😄']
      ]);
    }
    {
      const s = '''
123,abc😄,1
456,def😄,
''';
      final r = fast_csv.parse(s);
      expect(r, [
        ['123', 'abc😄', '1'],
        ['456', 'def😄', '']
      ]);
    }
    {
      const s = '''
123,"multi
line",1
456,def😄,
''';
      final r = fast_csv.parse(s);
      expect(r, [
        ['123', 'multi\nline', '1'],
        ['456', 'def😄', '']
      ]);
    }
    {
      const s = '''
123,abc😄
456,"multi
line"

# Comment

789
''';
      final r = fast_csv.parse(s);
      expect(r, [
        ['123', 'abc😄'],
        ['456', 'multi\nline'],
        [''],
        ['# Comment'],
        [''],
        ['789'],
      ]);
    }
  });
}
