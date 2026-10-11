import 'package:flutter_test/flutter_test.dart';
import 'package:symptomm/models/symptom_data.dart';

void main() {
  test('symptom search ranks exact, alias, and typo-tolerant matches', () {
    expect(search('headache').first.name, 'Headache');
    expect(search('headake').first.name, 'Headache');
    expect(search('belly pain').first.name, 'Stomach Pain');
    expect(search('').length, symptoms.length);
  });

  test('ICD-10 weighted relevance produces normalized specialist rankings', () {
    final result = analyze(['Headache', 'Chest Pain']);
    final total = result.recs.fold<int>(0, (sum, rec) => sum + rec.pct);

    expect(result.recs.first.s.name, 'Neurology');
    expect(result.recs.first.pct, 40);
    expect(result.recs.map((rec) => rec.pct).toList(), [40, 29, 14, 10, 7]);
    expect(total, 100);
    expect(result.recs.first.because, ['Headache']);
    expect(result.recs.first.icd10Codes, ['R51.9']);
    expect(result.flags, ['Chest Pain']);
  });

  test('red-flag symptoms remain visible in the outcome', () {
    final result = analyze(['Chest Pain']);

    expect(result.flags, ['Chest Pain']);
    expect(result.recs.first.s.name, 'Cardiology');
    expect(result.recs.first.icd10Codes, ['R07.9']);
  });
}
