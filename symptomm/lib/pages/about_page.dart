import 'package:flutter/material.dart';
import 'package:symptomm/app_state.dart';
import 'package:symptomm/widgets/common.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) => Shell(
        title: 'About Mediora',
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: card(),
              child: const Text(
                'Mediora helps you decide which kind of medical specialist to consult. '
                'It links curated symptom records to ICD-10 symptom codes and weighted specialist relevance. Each selected symptom contributes a normalized share of its weighted associations; percentages describe relative relevance in this catalogue, not a diagnosis or probability.\n\n'
                '$disclaimer It is not a replacement for professional consultation.\n\n'
                'Nearby hospital results use your location only after you request them. Your coordinates are sent to the OpenStreetMap Nominatim service; results and coverage are not guaranteed to be complete or current.\n\n'
                'Project proposal by Celis, Jan Edvic D. and Joson, Ralph Xaviery P. (BSCPE-4).',
              ),
            ),
            emergencyBox(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: card(),
              child: ValueListenableBuilder<double>(
                valueListenable: textScale,
                builder: (_, value, __) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Text size',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    Slider(
                      value: value,
                      min: .85,
                      max: 1.5,
                      divisions: 13,
                      label: '${(value * 100).round()}%',
                      onChanged: (newValue) => textScale.value = newValue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
