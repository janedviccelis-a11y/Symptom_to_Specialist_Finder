import 'package:flutter/material.dart';

const _sp = {
  'D': 'Dermatology', 'C': 'Cardiology', 'E': 'ENT - Otolaryngology',
  'G': 'Gastroenterology', 'N': 'Neurology', 'O': 'Orthopedics',
  'P': 'Pulmonology', 'R': 'Rheumatology',
};

const cats = <String, IconData>{
  'Head & Neck': Icons.face,
  'Chest & Breathing': Icons.monitor_heart_outlined,
  'Abdomen & Digestion': Icons.accessibility_new,
  'Muscles & Joints': Icons.directions_walk,
  'Skin & Hair': Icons.spa_outlined,
};

class Symptom {
  final String name, cat;
  final List<String> alias;
  final Map<String, int> w;
  final bool red;

  Symptom(this.name, this.cat, this.alias, String weights, {this.red = false})
      : w = {
          for (final p in weights.split(' ')) _sp[p[0]]!: int.parse(p.substring(1)),
        };
}

final symptoms = <Symptom>[
  Symptom('Headache', 'Head & Neck', ['head pain', 'migraine'], 'N4 E1'),
  Symptom('Dizziness', 'Head & Neck', ['vertigo', 'lightheaded'], 'N3 E2 C1'),
  Symptom('Sore Throat', 'Head & Neck', ['throat pain'], 'E4'),
  Symptom('Sinus Pressure', 'Head & Neck', ['stuffy nose', 'congestion'], 'E4 P1'),
  Symptom('Ear Pain', 'Head & Neck', ['earache'], 'E4'),
  Symptom('Sudden Numbness', 'Head & Neck', ['numb face', 'weak one side'], 'N5', red: true),
  Symptom('Chest Pain', 'Chest & Breathing', ['chest tightness'], 'C4 P2 G1', red: true),
  Symptom('Difficulty Breathing', 'Chest & Breathing', ['trouble breathing'], 'P4 C3', red: true),
  Symptom('Shortness of Breath (Exercise-related)', 'Chest & Breathing', ['short of breath', 'breathless'], 'C3 P3'),
  Symptom('Persistent Cough', 'Chest & Breathing', ['cough', 'chronic cough'], 'P4 E1'),
  Symptom('Palpitations', 'Chest & Breathing', ['racing heart', 'irregular heartbeat'], 'C4'),
  Symptom('Wheezing', 'Chest & Breathing', [], 'P4 E1'),
  Symptom('Stomach Pain', 'Abdomen & Digestion', ['tummy ache', 'abdominal pain', 'belly pain'], 'G4'),
  Symptom('Nausea', 'Abdomen & Digestion', ['queasy', 'vomiting'], 'G3 N1'),
  Symptom('Heartburn', 'Abdomen & Digestion', ['acid reflux', 'indigestion'], 'G4 C1'),
  Symptom('Diarrhea', 'Abdomen & Digestion', ['loose stools'], 'G4'),
  Symptom('Bloating', 'Abdomen & Digestion', ['gas'], 'G3'),
  Symptom('Joint Pain', 'Muscles & Joints', ['achy joints'], 'R4 O3'),
  Symptom('Joint Stiffness', 'Muscles & Joints', ['morning stiffness'], 'R4 O2'),
  Symptom('Swollen Joints', 'Muscles & Joints', ['joint swelling'], 'R4 O2'),
  Symptom('Back Pain', 'Muscles & Joints', ['lower back pain'], 'O4 N1 R1'),
  Symptom('Muscle Weakness', 'Muscles & Joints', [], 'N3 O2 R1'),
  Symptom('Unexplained Rash', 'Skin & Hair', ['rash', 'hives'], 'D4 R1'),
  Symptom('Persistent Itching', 'Skin & Hair', ['itchy skin', 'itch'], 'D4'),
  Symptom('Skin Redness', 'Skin & Hair', ['red skin'], 'D3 R1'),
  Symptom('Hair Loss', 'Skin & Hair', ['balding', 'thinning hair'], 'D4'),
  Symptom('Changing Mole', 'Skin & Hair', ['mole', 'skin changes'], 'D5'),
];

List<Symptom> search(String q) {
  final t = q.toLowerCase().trim();
  return symptoms
      .where((s) =>
          s.name.toLowerCase().contains(t) ||
          s.alias.any((a) => a.contains(t) || t.contains(a)))
      .toList();
}

class Specialty {
  final String name, brief, about, when;
  final IconData icon;
  final List<String> conditions, tests;

  const Specialty(
    this.name,
    this.icon,
    this.brief,
    this.about,
    this.conditions,
    this.when,
    this.tests,
  );
}

const _list = <Specialty>[
  Specialty('Dermatology', Icons.spa, 'Specializes in conditions affecting skin, hair, and nails.',
      'A dermatologist is a doctor who diagnoses and treats problems of the skin, hair, and nails.',
      ['Eczema and rashes', 'Acne', 'Hair loss', 'Skin infections and moles'],
      'Consider one when a rash, itch, or skin change lasts more than a couple of weeks, spreads, or a mole changes shape or color.',
      ['Skin exam', 'Skin biopsy', 'Patch test']),
  Specialty('Cardiology', Icons.favorite, 'Focuses on the heart and circulatory system.',
      'A cardiologist is a doctor who specializes in the heart and blood vessels.',
      ['Heart failure', 'Arrhythmias', 'Coronary artery disease', 'High blood pressure'],
      'Consider one for palpitations, shortness of breath when active, or heart-related symptoms that keep coming back. Chest pain can be an emergency.',
      ['EKG', 'Echocardiogram', 'Stress test']),
  Specialty('ENT - Otolaryngology', Icons.hearing, 'Treats ear, nose, and throat issues.',
      'An ENT doctor treats conditions of the ears, nose, throat, and related areas of the head and neck.',
      ['Sinusitis', 'Ear infections', 'Tonsillitis', 'Hearing and balance problems'],
      'Consider one for sinus pressure, ear pain, or a sore throat that does not improve or keeps returning.',
      ['Hearing test', 'Nasal endoscopy', 'Throat exam']),
  Specialty('Gastroenterology', Icons.restaurant, 'Focuses on the digestive system.',
      'A gastroenterologist treats the stomach, intestines, liver, and other digestive organs.',
      ['Acid reflux (GERD)', 'Irritable bowel syndrome', 'Ulcers', 'Liver disease'],
      'Consider one for stomach pain, nausea, heartburn, or bowel changes lasting more than a few weeks.',
      ['Endoscopy', 'Colonoscopy', 'Stool test']),
  Specialty('Neurology', Icons.psychology, 'Focuses on the brain, spinal cord, and nerves.',
      'A neurologist treats conditions of the brain, spinal cord, and nervous system.',
      ['Migraine', 'Epilepsy', 'Neuropathy', 'Stroke recovery'],
      'Consider one for recurring headaches, dizziness, numbness, or unexplained weakness. Sudden numbness is an emergency.',
      ['Neurological exam', 'MRI / CT scan', 'EEG']),
  Specialty('Orthopedics', Icons.accessibility_new, 'Treats bones, joints, muscles, and ligaments.',
      'An orthopedic doctor treats injuries and conditions of the bones, joints, muscles, and ligaments.',
      ['Fractures', 'Arthritis', 'Back and spine problems', 'Sports injuries'],
      'Consider one for joint or back pain that limits movement or does not improve with rest.',
      ['X-ray', 'MRI', 'Physical exam']),
  Specialty('Pulmonology', Icons.air, 'Focuses on the lungs and breathing.',
      'A pulmonologist treats diseases of the lungs and airways.',
      ['Asthma', 'COPD', 'Chronic cough', 'Pneumonia'],
      'Consider one for a cough lasting weeks, wheezing, or ongoing breathing trouble. Severe breathing difficulty is an emergency.',
      ['Spirometry', 'Chest X-ray', 'Oxygen level test']),
  Specialty('Rheumatology', Icons.back_hand, 'Treats autoimmune and joint-inflammation conditions.',
      'A rheumatologist treats arthritis and autoimmune diseases that affect joints, muscles, and bones.',
      ['Rheumatoid arthritis', 'Lupus', 'Gout', 'Joint inflammation'],
      'Consider one for swollen, stiff, or painful joints that last for weeks, especially with morning stiffness.',
      ['Blood tests', 'Joint X-ray', 'Joint fluid test']),
];

final specialties = <String, Specialty>{for (final s in _list) s.name: s};

class Rec {
  final Specialty s;
  final int pct;
  final List<String> because;

  Rec(this.s, this.pct, this.because);
}

class Outcome {
  final List<Rec> recs;
  final List<String> flags;

  Outcome(this.recs, this.flags);
}

Outcome analyze(Iterable<String> names) {
  final chosen = symptoms.where((s) => names.contains(s.name)).toList();
  if (chosen.isEmpty) return Outcome([], []);

  final score = <String, int>{};
  final why = <String, List<String>>{};
  var max = 0;

  for (final s in chosen) {
    max += s.w.values.reduce((a, b) => a > b ? a : b);
    s.w.forEach((k, v) {
      score[k] = (score[k] ?? 0) + v;
      (why[k] ??= []).add(s.name);
    });
  }

  final recs = score.entries
      .map((e) => Rec(
          specialties[e.key]!,
          (e.value * 100 / max).round().clamp(0, 100).toInt(),
          why[e.key]!,
        ))
      .toList()
    ..sort((a, b) => b.pct.compareTo(a.pct));

  return Outcome(recs, [for (final s in chosen) if (s.red) s.name]);
}
