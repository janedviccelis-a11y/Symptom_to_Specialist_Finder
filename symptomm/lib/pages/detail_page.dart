import 'package:flutter/material.dart';
import 'package:symptomm/models/symptom_data.dart';
import 'package:symptomm/pages/clinic_map_page.dart';
import 'package:symptomm/services/nearby_hospital_service.dart';
import 'package:symptomm/widgets/common.dart';

class DetailPage extends StatefulWidget {
  final Specialty specialty;

  const DetailPage(this.specialty, {super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool findingHospitals = false;

  Future<void> findHospitals() async {
    if (findingHospitals) return;
    setState(() => findingHospitals = true);
    try {
      final results = await findNearbyHospitals();
      if (!mounted) return;
      setState(() => findingHospitals = false);
      if (results.hospitals.isEmpty) {
        snack(context,
            'No mapped hospitals were found within 15 km of your location.');
        return;
      }
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HospitalMapPage(
            hospitals: results.hospitals,
            userLocation: results.userLocation,
          ),
        ),
      );
    } on HospitalLookupException catch (error) {
      if (mounted) snack(context, error.message);
    } catch (error, stackTrace) {
      debugPrint('Nearby hospital search failed: $error\n$stackTrace');
      if (mounted) {
        snack(
          context,
          'Hospital search failed: $error',
        );
      }
    } finally {
      if (mounted) setState(() => findingHospitals = false);
    }
  }

  Widget heading(String title) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 6),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
      );

  Widget bulletList(List<String> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Text('•  $item', style: const TextStyle(fontSize: 16, height: 1.5)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final specialty = widget.specialty;
    final firstWord = specialty.name.split(' ').first;

    return Shell(
      title: specialty.name,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: card(radius: 22),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: insetSurface(radius: 20),
                  child: Icon(specialty.icon, size: 31, color: blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        specialty.name,
                        style: TextStyle(
                          color: ink,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        specialty.brief,
                        style: TextStyle(color: mutedInk, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          heading('What is a $firstWord specialist?'),
          Text(specialty.about, style: const TextStyle(fontSize: 16)),
          heading('What Conditions They Handle'),
          bulletList(specialty.conditions),
          heading('When to See One'),
          Text(specialty.when, style: const TextStyle(fontSize: 16)),
          heading('Common Diagnostic Tests'),
          bulletList(specialty.tests),
          heading('Find a hospital near you'),
          const Text(
            'Use your current device location to search OpenStreetMap for hospitals within 15 km. Your coordinates are sent to the OpenStreetMap Nominatim service for this search.',
            style: TextStyle(fontSize: 14, height: 1.45),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: findingHospitals ? null : findHospitals,
            icon: findingHospitals
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.my_location),
            label: Text(findingHospitals
                ? 'Finding nearby hospitals...'
                : 'Find nearest hospitals'),
            style: FilledButton.styleFrom(
              backgroundColor: teal,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'OpenStreetMap data may be incomplete. If you need urgent care, call your local emergency number.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          const Text(disclaimer, style: TextStyle(fontSize: 12.5)),
        ],
      ),
    );
  }
}
