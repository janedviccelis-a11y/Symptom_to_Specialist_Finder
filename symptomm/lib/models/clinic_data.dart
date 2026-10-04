import 'package:latlong2/latlong.dart';

class Clinic {
  final String name;
  final String specialty;
  final String city;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String hours;

  const Clinic({
    required this.name,
    required this.specialty,
    required this.city,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.hours,
  });

  LatLng get location => LatLng(latitude, longitude);
}

const List<Clinic> _allClinics = [
  Clinic(
    name: 'City Heart Center',
    specialty: 'Cardiology',
    city: 'Manila',
    address: 'Makati Ave, Makati City',
    latitude: 14.5547,
    longitude: 121.0244,
    phone: '+63 2 8120 1111',
    hours: 'Mon-Sat • 8:00 AM - 6:00 PM',
  ),
  Clinic(
    name: 'Metro Cardio Clinic',
    specialty: 'Cardiology',
    city: 'Quezon City',
    address: 'Timog Avenue, Quezon City',
    latitude: 14.6399,
    longitude: 121.0359,
    phone: '+63 2 8250 2200',
    hours: 'Mon-Sun • 7:30 AM - 7:00 PM',
  ),
  Clinic(
    name: 'Luzon HeartCare',
    specialty: 'Cardiology',
    city: 'Pasig',
    address: 'Ortigas Center, Pasig City',
    latitude: 14.5764,
    longitude: 121.086,
    phone: '+63 2 8634 5000',
    hours: 'Mon-Fri • 9:00 AM - 5:00 PM',
  ),
  Clinic(
    name: 'Skin & Beauty Institute',
    specialty: 'Dermatology',
    city: 'Manila',
    address: 'Taft Avenue, Manila',
    latitude: 14.5837,
    longitude: 120.9826,
    phone: '+63 2 8821 4400',
    hours: 'Mon-Sat • 8:00 AM - 6:00 PM',
  ),
  Clinic(
    name: 'Dermal Care Center',
    specialty: 'Dermatology',
    city: 'Quezon City',
    address: 'Katipunan Avenue, Quezon City',
    latitude: 14.6331,
    longitude: 121.0566,
    phone: '+63 2 8723 9900',
    hours: 'Mon-Sun • 9:00 AM - 7:00 PM',
  ),
  Clinic(
    name: 'Bahay Skin Clinic',
    specialty: 'Dermatology',
    city: 'Makati',
    address: 'Ayala Avenue, Makati City',
    latitude: 14.5547,
    longitude: 121.0235,
    phone: '+63 2 8812 5500',
    hours: 'Mon-Fri • 8:30 AM - 5:30 PM',
  ),
  Clinic(
    name: 'Nose & Throat Center',
    specialty: 'ENT - Otolaryngology',
    city: 'Manila',
    address: 'United Nations Avenue, Manila',
    latitude: 14.6005,
    longitude: 120.9921,
    phone: '+63 2 8522 1130',
    hours: 'Mon-Sat • 8:00 AM - 6:00 PM',
  ),
  Clinic(
    name: 'Ears, Nose & Voice Clinic',
    specialty: 'ENT - Otolaryngology',
    city: 'Makati',
    address: 'Paseo de Roxas, Makati City',
    latitude: 14.5516,
    longitude: 121.024,
    phone: '+63 2 8814 8000',
    hours: 'Mon-Sat • 9:00 AM - 6:00 PM',
  ),
  Clinic(
    name: 'Digestive Health Clinic',
    specialty: 'Gastroenterology',
    city: 'Pasig',
    address: 'Meridian Avenue, Pasig City',
    latitude: 14.5638,
    longitude: 121.0819,
    phone: '+63 2 8631 2400',
    hours: 'Mon-Sat • 8:00 AM - 5:30 PM',
  ),
  Clinic(
    name: 'Gut & Liver Specialists',
    specialty: 'Gastroenterology',
    city: 'Makati',
    address: 'Dela Rosa Street, Makati City',
    latitude: 14.554,
    longitude: 121.018,
    phone: '+63 2 8810 2300',
    hours: 'Mon-Fri • 7:30 AM - 6:00 PM',
  ),
  Clinic(
    name: 'Brain & Spine Center',
    specialty: 'Neurology',
    city: 'Quezon City',
    address: 'EDSA, Quezon City',
    latitude: 14.6288,
    longitude: 121.0467,
    phone: '+63 2 8260 9500',
    hours: 'Mon-Sat • 8:00 AM - 6:00 PM',
  ),
  Clinic(
    name: 'NeuroCare Medical',
    specialty: 'Neurology',
    city: 'Taguig',
    address: 'BGC, Taguig City',
    latitude: 14.551,
    longitude: 121.0497,
    phone: '+63 2 8816 1800',
    hours: 'Mon-Sun • 8:00 AM - 8:00 PM',
  ),
  Clinic(
    name: 'Motion & Bone Clinic',
    specialty: 'Orthopedics',
    city: 'Quezon City',
    address: 'Commonwealth Avenue, Quezon City',
    latitude: 14.676,
    longitude: 121.0457,
    phone: '+63 2 8255 7800',
    hours: 'Mon-Sat • 8:30 AM - 6:30 PM',
  ),
  Clinic(
    name: 'Joint & Spine Institute',
    specialty: 'Orthopedics',
    city: 'Makati',
    address: 'Legazpi Street, Makati City',
    latitude: 14.5545,
    longitude: 121.0157,
    phone: '+63 2 8843 1100',
    hours: 'Mon-Sat • 9:00 AM - 6:00 PM',
  ),
  Clinic(
    name: 'LungCare Specialists',
    specialty: 'Pulmonology',
    city: 'Manila',
    address: 'Pedro Gil Street, Manila',
    latitude: 14.5916,
    longitude: 120.983,
    phone: '+63 2 8523 6644',
    hours: 'Mon-Sat • 8:00 AM - 5:30 PM',
  ),
  Clinic(
    name: 'Breathing Better Clinic',
    specialty: 'Pulmonology',
    city: 'Pasig',
    address: 'C5 Road, Pasig City',
    latitude: 14.5793,
    longitude: 121.056,
    phone: '+63 2 8632 7700',
    hours: 'Mon-Fri • 9:00 AM - 6:00 PM',
  ),
  Clinic(
    name: 'Rheum & Joint Center',
    specialty: 'Rheumatology',
    city: 'Makati',
    address: 'Salcedo Village, Makati City',
    latitude: 14.553,
    longitude: 121.019,
    phone: '+63 2 8820 6600',
    hours: 'Mon-Fri • 8:00 AM - 5:00 PM',
  ),
  Clinic(
    name: 'Autoimmune Wellness Clinic',
    specialty: 'Rheumatology',
    city: 'Taguig',
    address: 'Bonifacio Global City, Taguig',
    latitude: 14.544,
    longitude: 121.049,
    phone: '+63 2 8834 3000',
    hours: 'Mon-Sat • 8:30 AM - 6:00 PM',
  ),
];

String _normalize(String value) => value.toLowerCase().trim();

List<Clinic> searchClinics(String specialty, {String query = ''}) {
  final normalizedSpecialty = _normalize(specialty);
  final normalizedQuery = _normalize(query);

  return _allClinics.where((clinic) {
    final specialtyMatch = _normalize(clinic.specialty).contains(normalizedSpecialty) ||
        normalizedSpecialty.contains(_normalize(clinic.specialty));
    if (!specialtyMatch) {
      return false;
    }

    if (normalizedQuery.isEmpty) {
      return true;
    }

    final haystack = [
      clinic.name,
      clinic.city,
      clinic.address,
      clinic.specialty,
    ].join(' ');

    return _normalize(haystack).contains(normalizedQuery);
  }).toList();
}
