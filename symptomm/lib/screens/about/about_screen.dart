import 'package:flutter/material.dart';
import 'package:symptomm/app_state.dart';
import 'package:symptomm/widgets/common.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) => Shell(
        title: 'About this App',
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: card(),
              child: const Text(
                'Symptom to Specialist Finder helps you decide which kind of medical specialist to consult. '
                'It matches the symptoms you choose against a curated rule table and ranks specialties by a weighted score.\n\n'
                '$disclaimer It is not a replacement for professional consultation.\n\n'
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
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
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
