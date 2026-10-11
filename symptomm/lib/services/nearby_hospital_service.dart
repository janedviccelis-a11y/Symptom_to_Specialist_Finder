import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:symptomm/models/hospital.dart';

const _searchRadiusMeters = 15000;
const _overpassEndpoint = 'https://overpass-api.de/api/interpreter';

class HospitalLookupException implements Exception {
  final String message;

  const HospitalLookupException(this.message);

  @override
  String toString() => message;
}

class HospitalSearchResults {
  final LatLng userLocation;
  final List<Hospital> hospitals;

  const HospitalSearchResults({
    required this.userLocation,
    required this.hospitals,
  });
}

Future<HospitalSearchResults> findNearbyHospitals() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw const HospitalLookupException(
      'Turn on location services to find hospitals near you.',
    );
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied) {
    throw const HospitalLookupException(
      'Location permission is needed to find the nearest hospitals.',
    );
  }
  if (permission == LocationPermission.deniedForever) {
    throw const HospitalLookupException(
      'Location access is blocked. Allow it in your device settings, then try again.',
    );
  }

  Position position;
  try {
    position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
  } on LocationServiceDisabledException {
    throw const HospitalLookupException(
      'Turn on location services to find hospitals near you.',
    );
  } on PermissionDeniedException {
    throw const HospitalLookupException(
      'Location permission is needed to find the nearest hospitals.',
    );
  } on TimeoutException {
    throw const HospitalLookupException(
      'Your location could not be determined in time. Check your signal and try again.',
    );
  }

  final location = LatLng(position.latitude, position.longitude);
  final query = '''
[out:json][timeout:25];
(
  node["amenity"="hospital"](around:$_searchRadiusMeters,${location.latitude},${location.longitude});
  way["amenity"="hospital"](around:$_searchRadiusMeters,${location.latitude},${location.longitude});
  relation["amenity"="hospital"](around:$_searchRadiusMeters,${location.latitude},${location.longitude});
  node["healthcare"="hospital"](around:$_searchRadiusMeters,${location.latitude},${location.longitude});
  way["healthcare"="hospital"](around:$_searchRadiusMeters,${location.latitude},${location.longitude});
  relation["healthcare"="hospital"](around:$_searchRadiusMeters,${location.latitude},${location.longitude});
);
out center tags;
''';

  final http.Response response;
  try {
    response = await http
        .post(
          Uri.parse(_overpassEndpoint),
          headers: const {'User-Agent': 'SymptomSpecialistFinder/1.0'},
          body: {'data': query},
        )
        .timeout(const Duration(seconds: 35));
  } on http.ClientException {
    throw const HospitalLookupException(
      'Could not connect to the OpenStreetMap hospital directory. Check your internet connection.',
    );
  } on TimeoutException {
    throw const HospitalLookupException(
      'The hospital directory took too long to respond. Please try again.',
    );
  }

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw HospitalLookupException(
      'The hospital directory is temporarily unavailable (HTTP ${response.statusCode}). Please try again later.',
    );
  }

  try {
    return HospitalSearchResults(
      userLocation: location,
      hospitals: parseNearbyHospitals(response.body, location),
    );
  } on FormatException {
    throw const HospitalLookupException(
      'The hospital directory returned an unreadable response. Please try again later.',
    );
  }
}

List<Hospital> parseNearbyHospitals(String responseBody, LatLng origin) {
  final decoded = jsonDecode(responseBody);
  if (decoded is! Map<String, dynamic> || decoded['elements'] is! List) {
    throw const FormatException('Unexpected OpenStreetMap response');
  }

  final hospitals = <Hospital>[];
  final seenIds = <String>{};
  const distance = Distance();

  for (final element in decoded['elements'] as List) {
    if (element is! Map<String, dynamic>) continue;
    final tags = element['tags'];
    if (tags is! Map<String, dynamic>) continue;

    final center = element['center'];
    final centerMap = center is Map ? center : null;
    final lat =
        _coordinate(element['lat']) ?? _coordinate(centerMap?['lat']);
    final lon =
        _coordinate(element['lon']) ?? _coordinate(centerMap?['lon']);
    if (lat == null ||
        lon == null ||
        lat < -90 ||
        lat > 90 ||
        lon < -180 ||
        lon > 180) {
      continue;
    }

    final id = '${element['type']}/${element['id']}';
    if (!seenIds.add(id)) continue;

    final street = [
      tags['addr:housenumber'],
      tags['addr:street'],
    ].whereType<String>().where((part) => part.isNotEmpty).join(' ');
    final fullAddress = tags['addr:full'];
    final city = tags['addr:city'] ?? tags['addr:town'] ?? tags['addr:suburb'];
    final addressParts = <String>[];
    if (fullAddress is String && fullAddress.isNotEmpty) {
      addressParts.add(fullAddress);
    } else if (street.isNotEmpty) {
      addressParts.add(street);
    }
    if (city is String && city.isNotEmpty) addressParts.add(city);

    final point = LatLng(lat, lon);
    hospitals.add(
      Hospital(
        id: id,
        name: tags['name'] is String ? tags['name'] as String : 'Hospital',
        address: addressParts.join(', '),
        location: point,
        distanceMeters: distance.as(LengthUnit.Meter, origin, point),
      ),
    );
  }

  hospitals.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
  return hospitals;
}

double? _coordinate(Object? value) {
  if (value is num && value.isFinite) return value.toDouble();
  return null;
}
