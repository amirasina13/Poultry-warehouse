import 'package:farmiera_warehouse/helper/helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ValueParser Unit Tests', () {
    test('parseInt converts null, double, and string safely', () {
      expect(ValueParser.parseInt(null), 0);
      expect(ValueParser.parseInt("123"), 123);
      expect(ValueParser.parseInt(45.8), 45);
      expect(ValueParser.parseInt("invalid"), 0);
    });

    test('parseDouble converts null, int, and string safely', () {
      expect(ValueParser.parseDouble(null), 0.0);
      expect(ValueParser.parseDouble("123.45"), 123.45);
      expect(ValueParser.parseDouble(50), 50.0);
    });

    test('formatNumberPayload preserves integer zero (Fixes [DATA-05])', () {
      expect(ValueParser.formatNumberPayload(0), 0);
      expect(ValueParser.formatNumberPayload("0"), 0);
      expect(ValueParser.formatNumberPayload(0.0), 0.0);
      expect(ValueParser.formatNumberPayload(null), null);
      expect(ValueParser.formatNumberPayload(""), null);
    });

    test('formatStringPayload converts empty/null to null', () {
      expect(ValueParser.formatStringPayload("V-101"), "V-101");
      expect(ValueParser.formatStringPayload(""), null);
      expect(ValueParser.formatStringPayload(null), null);
      expect(ValueParser.formatStringPayload("null"), null);
    });
  });
}
