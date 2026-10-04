import 'package:flutter_test/flutter_test.dart';
import 'package:symptomm/models/clinic_data.dart';

void main() {
  test('clinic search returns matching entries for a specialty', () {
    final matches = searchClinics('Cardiology', query: 'Manila');

    expect(matches, isNotEmpty);
    expect(matches.first.specialty, 'Cardiology');
  });

  test('clinic search falls back to a specialty when query is blank', () {
    final matches = searchClinics('Dermatology');

    expect(matches, isNotEmpty);
    expect(matches.any((clinic) => clinic.specialty == 'Dermatology'), isTrue);
  });
}
