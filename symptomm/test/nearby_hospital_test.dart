import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:symptomm/services/nearby_hospital_service.dart';

void main() {
  test('hospital results are parsed and ordered by actual coordinates', () {
    const origin = LatLng(14, 121);
    const response = '''
      {
        "elements": [
          {
            "type": "node",
            "id": 2,
            "lat": 14.01,
            "lon": 121,
            "tags": {"amenity": "hospital", "name": "Far Hospital"}
          },
          {
            "type": "way",
            "id": 1,
            "center": {"lat": 14.001, "lon": 121},
            "tags": {
              "amenity": "hospital",
              "name": "Near Hospital",
              "addr:street": "Main Road",
              "addr:city": "Town"
            }
          }
        ]
      }
    ''';

    final hospitals = parseNearbyHospitals(response, origin);

    expect(hospitals.map((hospital) => hospital.name),
        ['Near Hospital', 'Far Hospital']);
    expect(hospitals.first.address, 'Main Road, Town');
    expect(hospitals.first.distanceMeters, lessThan(hospitals.last.distanceMeters));
  });

  test('malformed hospital directory responses are rejected', () {
    expect(
      () => parseNearbyHospitals('{"unexpected": []}', const LatLng(0, 0)),
      throwsFormatException,
    );
  });
}
