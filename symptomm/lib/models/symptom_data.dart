import 'package:flutter/material.dart';

const cats = <String, IconData>{
  'Head & Neck': Icons.face,
  'Chest & Breathing': Icons.monitor_heart_outlined,
  'Abdomen & Digestion': Icons.accessibility_new,
  'Muscles & Joints': Icons.directions_walk,
  'Skin & Hair': Icons.spa_outlined,
};

class Symptom {
  final String name, cat, icd10Code, icd10Description;
  final List<String> alias;
  final Map<String, double> relevance;
  final bool red;

  Symptom(
    this.name,
    this.cat,
    this.alias,
    this.icd10Code,
    this.icd10Description,
    this.relevance, {
    this.red = false,
  });
}

final symptoms = <Symptom>[
  Symptom('Headache', 'Head & Neck', ['head pain', 'migraine'], 'R51.9',
      'Headache, unspecified', {'Neurology': 4, 'ENT - Otolaryngology': 1}),
  Symptom('Dizziness', 'Head & Neck', ['vertigo', 'lightheaded'], 'R42',
      'Dizziness and giddiness', {'Neurology': 3, 'ENT - Otolaryngology': 2, 'Cardiology': 1}),
  Symptom('Sore Throat', 'Head & Neck', ['throat pain'], 'J02.9',
      'Acute pharyngitis, unspecified', {'ENT - Otolaryngology': 4}),
  Symptom('Sinus Pressure', 'Head & Neck', ['stuffy nose', 'congestion'], 'R09.81',
      'Nasal congestion', {'ENT - Otolaryngology': 4, 'Pulmonology': 1}),
  Symptom('Ear Pain', 'Head & Neck', ['earache'], 'H92.09',
      'Otalgia, unspecified ear', {'ENT - Otolaryngology': 4}),
  Symptom('Sudden Numbness', 'Head & Neck', ['numb face', 'weak one side'], 'R20.0',
      'Anesthesia of skin', {'Neurology': 5}, red: true),
  Symptom('Chest Pain', 'Chest & Breathing', ['chest tightness'], 'R07.9',
      'Chest pain, unspecified', {'Cardiology': 4, 'Pulmonology': 2, 'Gastroenterology': 1}, red: true),
  Symptom('Difficulty Breathing', 'Chest & Breathing', ['trouble breathing'], 'R06.00',
      'Dyspnea, unspecified', {'Pulmonology': 4, 'Cardiology': 3}, red: true),
  Symptom('Shortness of Breath (Exercise-related)', 'Chest & Breathing',
      ['short of breath', 'breathless'], 'R06.02', 'Shortness of breath',
      {'Cardiology': 3, 'Pulmonology': 3}),
  Symptom('Persistent Cough', 'Chest & Breathing', ['cough', 'chronic cough'], 'R05.3',
      'Chronic cough', {'Pulmonology': 4, 'ENT - Otolaryngology': 1}),
  Symptom('Palpitations', 'Chest & Breathing', ['racing heart', 'irregular heartbeat'], 'R00.2',
      'Palpitations', {'Cardiology': 4}),
  Symptom('Wheezing', 'Chest & Breathing', [], 'R06.2',
      'Wheezing', {'Pulmonology': 4, 'ENT - Otolaryngology': 1}),
  Symptom('Stomach Pain', 'Abdomen & Digestion',
      ['tummy ache', 'abdominal pain', 'belly pain'], 'R10.9',
      'Unspecified abdominal pain', {'Gastroenterology': 4}),
  Symptom('Nausea', 'Abdomen & Digestion', ['queasy', 'vomiting'], 'R11.0',
      'Nausea', {'Gastroenterology': 3, 'Neurology': 1}),
  Symptom('Heartburn', 'Abdomen & Digestion', ['acid reflux', 'indigestion'], 'R12',
      'Heartburn', {'Gastroenterology': 4, 'Cardiology': 1}),
  Symptom('Diarrhea', 'Abdomen & Digestion', ['loose stools'], 'R19.7',
      'Diarrhea, unspecified', {'Gastroenterology': 4}),
  Symptom('Bloating', 'Abdomen & Digestion', ['gas'], 'R14.0',
      'Abdominal distension (gaseous)', {'Gastroenterology': 3}),
  Symptom('Joint Pain', 'Muscles & Joints', ['achy joints'], 'M25.50',
      'Pain in unspecified joint', {'Rheumatology': 4, 'Orthopedics': 3}),
  Symptom('Joint Stiffness', 'Muscles & Joints', ['morning stiffness'], 'M25.60',
      'Stiffness of unspecified joint', {'Rheumatology': 4, 'Orthopedics': 2}),
  Symptom('Swollen Joints', 'Muscles & Joints', ['joint swelling'], 'M25.40',
      'Effusion, unspecified joint', {'Rheumatology': 4, 'Orthopedics': 2}),
  Symptom('Back Pain', 'Muscles & Joints', ['lower back pain'], 'M54.9',
      'Dorsalgia, unspecified', {'Orthopedics': 4, 'Neurology': 1, 'Rheumatology': 1}),
  Symptom('Muscle Weakness', 'Muscles & Joints', [], 'M62.81',
      'Muscle weakness (generalized)', {'Neurology': 3, 'Orthopedics': 2, 'Rheumatology': 1}),
  Symptom('Unexplained Rash', 'Skin & Hair', ['rash', 'hives'], 'R21',
      'Rash and other nonspecific skin eruption', {'Dermatology': 4, 'Rheumatology': 1}),
  Symptom('Persistent Itching', 'Skin & Hair', ['itchy skin', 'itch'], 'L29.9',
      'Pruritus, unspecified', {'Dermatology': 4}),
  Symptom('Skin Redness', 'Skin & Hair', ['red skin'], 'L53.9',
      'Erythematous condition, unspecified', {'Dermatology': 3, 'Rheumatology': 1}),
  Symptom('Hair Loss', 'Skin & Hair', ['balding', 'thinning hair'], 'L65.9',
      'Nonscarring hair loss, unspecified', {'Dermatology': 4}),
  Symptom('Changing Mole', 'Skin & Hair', ['mole', 'skin changes'], 'D22.9',
      'Melanocytic nevi, unspecified', {'Dermatology': 5}),
];

String _normalize(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

int _editDistance(String a, String b) {
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final current = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      current[j] = [
        current[j - 1] + 1,
        previous[j] + 1,
        previous[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1),
      ].reduce((x, y) => x < y ? x : y);
    }
    previous = current;
  }
  return previous[b.length];
}

int _searchScore(String query, Symptom symptom) {
  final fields = [symptom.name, ...symptom.alias].map(_normalize).toList();
  var best = 0;
  for (final field in fields) {
    if (field == query) {
      best = best < 100 ? 100 : best;
    } else if (field.startsWith(query)) {
      best = best < 90 ? 90 : best;
    } else if (field.contains(query)) {
      best = best < 80 ? 80 : best;
    }
  }

  final queryTokens = query.split(' ');
  final allText = fields.join(' ');
  final fieldTokens = allText.split(' ').toSet();
  var matchedTokens = 0;
  for (final token in queryTokens) {
    if (fieldTokens.any((candidate) =>
        candidate == token ||
        candidate.startsWith(token) ||
        (token.length >= 4 &&
            _editDistance(candidate, token) <= (token.length >= 7 ? 2 : 1)))) {
      matchedTokens++;
    }
  }
  if (matchedTokens > 0) {
    final tokenScore = 40 + (matchedTokens * 15 ~/ queryTokens.length);
    if (tokenScore > best) best = tokenScore;
  }
  return best;
}

List<Symptom> search(String query) {
  final normalized = _normalize(query);
  if (normalized.isEmpty) return List.of(symptoms);
  final ranked = [
    for (var index = 0; index < symptoms.length; index++)
      (symptom: symptoms[index], index: index, score: _searchScore(normalized, symptoms[index])),
  ]..removeWhere((item) => item.score == 0);
  ranked.sort((a, b) {
    final relevanceOrder = b.score.compareTo(a.score);
    return relevanceOrder != 0 ? relevanceOrder : a.index.compareTo(b.index);
  });
  return ranked.map((item) => item.symptom).toList();
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
  final List<String> icd10Codes;

  Rec(this.s, this.pct, this.because, this.icd10Codes);
}

class Outcome {
  final List<Rec> recs;
  final List<String> flags;

  Outcome(this.recs, this.flags);
}

Outcome analyze(Iterable<String> names) {
  final chosen = symptoms.where((s) => names.contains(s.name)).toList();
  if (chosen.isEmpty) return Outcome([], []);

  final score = <String, double>{};
  final why = <String, List<String>>{};
  final codes = <String, Set<String>>{};

  for (final s in chosen) {
    final totalRelevance = s.relevance.values.fold<double>(0, (sum, value) => sum + value);
    if (totalRelevance == 0) continue;
    s.relevance.forEach((specialty, weight) {
      score[specialty] = (score[specialty] ?? 0) + weight / totalRelevance;
      (why[specialty] ??= []).add(s.name);
      (codes[specialty] ??= <String>{}).add(s.icd10Code);
    });
  }

  final recs = score.entries
      .map((e) => Rec(
          specialties[e.key]!,
          (e.value * 100 / chosen.length).round().clamp(0, 100).toInt(),
          why[e.key]!,
          codes[e.key]!.toList(),
        ))
      .toList()
    ..sort((a, b) {
      final scoreOrder = b.pct.compareTo(a.pct);
      return scoreOrder != 0 ? scoreOrder : a.s.name.compareTo(b.s.name);
    });

  return Outcome(recs, [for (final s in chosen) if (s.red) s.name]);
}
