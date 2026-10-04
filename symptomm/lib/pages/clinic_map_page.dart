import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:symptomm/models/clinic_data.dart';

class ClinicMapPage extends StatelessWidget {
  final List<Clinic> clinics;
  final String title;

  const ClinicMapPage({
    super.key,
    required this.clinics,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final markers = clinics
        .map(
          (clinic) => Marker(
            point: clinic.location,
            width: 46,
            height: 46,
            child: Tooltip(
              message: '${clinic.name}\n${clinic.city}',
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.location_on, color: Colors.white, size: 22),
              ),
            ),
          ),
        )
        .toList();

    final center = clinics.length > 1
        ? LatLng(
            clinics.map((c) => c.latitude).reduce((a, b) => a + b) / clinics.length,
            clinics.map((c) => c.longitude).reduce((a, b) => a + b) / clinics.length,
          )
        : clinics.first.location;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 11,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'symptomm',
                  maxZoom: 19,
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            padding: const EdgeInsets.all(12),
            child: ListView.builder(
              itemCount: clinics.length,
              itemBuilder: (_, index) {
                final clinic = clinics[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(clinic.name),
                    subtitle: Text('${clinic.city} • ${clinic.address}'),
                    trailing: const Icon(Icons.call, size: 18),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
