import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:symptomm/models/hospital.dart';
import 'package:symptomm/widgets/common.dart';

class HospitalMapPage extends StatelessWidget {
  final List<Hospital> hospitals;
  final LatLng userLocation;

  const HospitalMapPage({
    super.key,
    required this.hospitals,
    required this.userLocation,
  });

  String _formatDistance(double meters) => meters < 1000
      ? '${meters.round()} m away'
      : '${(meters / 1000).toStringAsFixed(1)} km away';

  @override
  Widget build(BuildContext context) {
    final markers = [
      Marker(
        point: userLocation,
        width: 46,
        height: 46,
        child: const Tooltip(
          message: 'Your location',
          child: Icon(Icons.my_location, color: Color(0xFF2F6AA3), size: 32),
        ),
      ),
      for (final hospital in hospitals)
        Marker(
          point: hospital.location,
          width: 46,
          height: 46,
          child: Tooltip(
            message: hospital.name,
            child: const Icon(
              Icons.local_hospital,
              color: Color(0xFFD34B43),
              size: 32,
            ),
          ),
        ),
    ];

    return Shell(
      title: 'Nearby hospitals',
      child: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: userLocation,
                initialZoom: 12,
                interactionOptions:
                    const InteractionOptions(flags: InteractiveFlag.all),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'symptomm',
                  maxZoom: 19,
                ),
                MarkerLayer(markers: markers),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxHeight: 280),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: BoxDecoration(
              color: canvas,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha: .28)
                      : const Color(0xFFC9D5E3),
                  blurRadius: 14,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospitals.isEmpty
                      ? 'No hospitals found within 15 km'
                      : '${hospitals.length} nearby hospital${hospitals.length == 1 ? '' : 's'} · nearest first',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView.builder(
                    itemCount: hospitals.length,
                    itemBuilder: (_, index) {
                      final hospital = hospitals[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: ListTile(
                          leading: const Icon(
                            Icons.local_hospital,
                            color: Color(0xFFD34B43),
                          ),
                          title: Text(hospital.name),
                          subtitle: Text([
                            if (hospital.address.isNotEmpty) hospital.address,
                            _formatDistance(hospital.distanceMeters),
                          ].join(' · ')),
                          isThreeLine: hospital.address.isNotEmpty,
                        ),
                      );
                    },
                  ),
                ),
                const Text(
                  'Distances are straight-line estimates. Hospital data: OpenStreetMap contributors; coverage may be incomplete.',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
