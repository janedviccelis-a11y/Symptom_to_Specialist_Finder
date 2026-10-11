import 'package:latlong2/latlong.dart';

class Hospital {
  final String id;
  final String name;
  final String address;
  final LatLng location;
  final double distanceMeters;

  const Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.distanceMeters,
  });
}
