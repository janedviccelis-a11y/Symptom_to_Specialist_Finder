import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:symptomm/services/nearby_hospital_service.dart';

void main() {
  test('Nominatim hospital results are sorted and restricted to 15 km', () {
    const origin = LatLng(14, 121);
    const response = '''
      [
        {
          "osm_type": "node",
          "osm_id": 2,
          "lat": "14.05",
          "lon": "121",
          "name": "Far Hospital"
        },
        {
          "osm_type": "way",
          "osm_id": 1,
          "lat": "14.001",
          "lon": "121",
          "name": "Near Hospital",
          "address": {"road": "Main Road", "city": "Town"}
        },
        {
          "osm_type": "node",
          "osm_id": 3,
          "lat": "14.2",
          "lon": "121",
          "name": "Outside Search Radius"
        }
      ]
    ''';

    final hospitals = parseNominatimHospitals(response, origin);

    expect(hospitals.map((hospital) => hospital.name),
        ['Near Hospital', 'Far Hospital']);
    expect(hospitals.first.address, 'Main Road, Town');
    expect(hospitals.first.distanceMeters,
        lessThan(hospitals.last.distanceMeters));
  });

  test('malformed Nominatim responses are rejected', () {
    expect(
      () => parseNominatimHospitals(
        '{"unexpected": []}',
        const LatLng(0, 0),
      ),
      throwsFormatException,
    );
  });

  test('Nominatim errors are not treated as empty results', () {
    expect(
      () => parseNominatimHospitals(
        '{"error": "Unable to geocode"}',
        const LatLng(0, 0),
      ),
      throwsFormatException,
    );
  });
}
