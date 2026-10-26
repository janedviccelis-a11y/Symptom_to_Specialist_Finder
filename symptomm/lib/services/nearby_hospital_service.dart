import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:symptomm/models/hospital.dart';

const _searchRadiusMeters = 15000;
const _nominatimEndpoint = 'https://nominatim.openstreetmap.org/search';
const _cachedLocationMaxAge = Duration(minutes: 2);
const _cachedLocationMaxAccuracyMeters = 100.0;
const _lookupTimeout = Duration(seconds: 30);
const _directoryRequestTimeout = Duration(seconds: 12);

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

Future<HospitalSearchResults> findNearbyHospitals() {
  return _findNearbyHospitals().timeout(
    _lookupTimeout,
    onTimeout: () => throw const HospitalLookupException(
      'Finding nearby hospitals took too long. Check your location and internet connection, then try again.',
    ),
  );
}

Future<HospitalSearchResults> _findNearbyHospitals() async {
  Position position;
  try {
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

    Position? cachedPosition;
    try {
      cachedPosition = await Geolocator.getLastKnownPosition();
    } on PlatformException catch (error) {
      debugPrint(
          'Cached location unavailable: ${error.code}: ${error.message}');
    } on MissingPluginException catch (error) {
      debugPrint('Cached location unavailable: $error');
    }
    if (cachedPosition != null && _isUsableCachedPosition(cachedPosition)) {
      position = cachedPosition;
    } else {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    }
  } on HospitalLookupException {
    rethrow;
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
  } on PlatformException catch (error) {
    throw HospitalLookupException(
      'Could not access your device location (${error.code}). Check location permission and try again.',
    );
  } on MissingPluginException {
    throw const HospitalLookupException(
      'Location services are unavailable in this app build. Rebuild the app and try again.',
    );
  }

  if (!position.latitude.isFinite ||
      !position.longitude.isFinite ||
      position.latitude < -90 ||
      position.latitude > 90 ||
      position.longitude < -180 ||
      position.longitude > 180) {
    throw const HospitalLookupException(
      'Your device returned an invalid location. Check location services and try again.',
    );
  }

  final location = LatLng(position.latitude, position.longitude);
  const latitudeDelta = _searchRadiusMeters / 111320;
  final cosineLatitude =
      math.cos(position.latitude * math.pi / 180).abs().clamp(0.001, 1.0);
  final longitudeDelta = latitudeDelta / cosineLatitude;
  final minLongitude = (position.longitude - longitudeDelta).clamp(-180, 180);
  final maxLongitude = (position.longitude + longitudeDelta).clamp(-180, 180);
  final minLatitude = (position.latitude - latitudeDelta).clamp(-90, 90);
  final maxLatitude = (position.latitude + latitudeDelta).clamp(-90, 90);
  final uri = Uri.parse(_nominatimEndpoint).replace(
    queryParameters: {
      'amenity': '[hospital]',
      'viewbox': '$minLongitude,$maxLatitude,$maxLongitude,$minLatitude',
      'bounded': '1',
      'format': 'jsonv2',
      'limit': '40',
      'addressdetails': '1',
      'namedetails': '1',
    },
  );

  try {
    final response = await http.get(
      uri,
      headers: const {
        'User-Agent': 'SymptomSpecialistFinder/1.0',
        'Accept': 'application/json',
      },
    ).timeout(_directoryRequestTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HospitalLookupException(
        'The hospital directory is temporarily unavailable (HTTP ${response.statusCode}). Please try again later.',
      );
    }
    return HospitalSearchResults(
      userLocation: location,
      hospitals: parseNominatimHospitals(response.body, location),
    );
  } on HospitalLookupException {
    rethrow;
  } on http.ClientException {
    throw const HospitalLookupException(
      'Could not connect to the OpenStreetMap hospital directory. Check your internet connection.',
    );
  } on TimeoutException {
    throw const HospitalLookupException(
      'The hospital directory took too long to respond. Please try again.',
    );
  } on FormatException {
    throw const HospitalLookupException(
      'The hospital directory returned an unreadable response. Please try again later.',
    );
  }
}

bool _isUsableCachedPosition(Position position) {
  final age = DateTime.now().difference(position.timestamp);
  return age >= Duration.zero &&
      age <= _cachedLocationMaxAge &&
      position.accuracy <= _cachedLocationMaxAccuracyMeters;
}

List<Hospital> parseNominatimHospitals(String responseBody, LatLng origin) {
  final decoded = jsonDecode(responseBody);
  if (decoded is! List) {
    throw const FormatException('Unexpected Nominatim response');
  }

  final hospitals = <Hospital>[];
  final seenIds = <String>{};
  const distance = Distance();

  for (final result in decoded) {
    if (result is! Map<String, dynamic>) continue;

    final lat = _coordinate(result['lat']);
    final lon = _coordinate(result['lon']);
    if (lat == null ||
        lon == null ||
        lat < -90 ||
        lat > 90 ||
        lon < -180 ||
        lon > 180) {
      continue;
    }

    final point = LatLng(lat, lon);
    final distanceMeters = distance.as(LengthUnit.Meter, origin, point);
    if (distanceMeters > _searchRadiusMeters) continue;

    final osmType = result['osm_type'];
    final osmId = result['osm_id'];
    final placeId = result['place_id'];
    final id = osmType is String && osmId != null
        ? '$osmType/$osmId'
        : placeId != null
            ? 'place/$placeId'
            : 'coordinate/${point.latitude}/${point.longitude}';
    if (!seenIds.add(id)) continue;

    final nameDetails = result['namedetails'];
    final address = result['address'];
    final displayName = result['display_name'];
    final name = result['name'] ??
        (nameDetails is Map ? nameDetails['name'] : null) ??
        (displayName is String ? displayName.split(',').first : null);
    final addressParts = <String>[];
    if (address is Map) {
      for (final key in [
        'house_number',
        'road',
        'suburb',
        'city',
        'town',
        'village',
        'postcode',
      ]) {
        final value = address[key];
        if (value is String &&
            value.isNotEmpty &&
            !addressParts.contains(value)) {
          addressParts.add(value);
        }
      }
    }
    if (addressParts.isEmpty && displayName is String) {
      addressParts.add(displayName);
    }

    hospitals.add(
      Hospital(
        id: id,
        name: name is String && name.isNotEmpty ? name : 'Hospital',
        address: addressParts.join(', '),
        location: point,
        distanceMeters: distanceMeters,
      ),
    );
  }

  hospitals.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
  return hospitals;
}

double? _coordinate(Object? value) {
  if (value is num && value.isFinite) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
