import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static bool _isConfigured = false;

  static bool get isConfigured => _isConfigured;

  static bool get hasSignedInSession =>
      _isConfigured && Supabase.instance.client.auth.currentSession != null;

  static SupabaseClient get _client {
    if (!_isConfigured) {
      throw StateError(
        'Supabase is not configured. Follow the setup steps in README.md.',
      );
    }
    return Supabase.instance.client;
  }

  static String normalizedUsername(String username) =>
      username.trim().toLowerCase();

  static String _authEmail(String username) =>
      '${normalizedUsername(username)}@accounts.mediora.example';

  static Future<void> signIn({
    required String username,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: _authEmail(username),
      password: password,
    );
  }

  static Future<AuthResponse> createAccount({
    required String firstName,
    required String surname,
    required DateTime birthday,
    required String address,
    required String username,
    required String password,
  }) {
    return _client.auth.signUp(
      email: _authEmail(username),
      password: password,
      data: {
        'first_name': firstName.trim(),
        'surname': surname.trim(),
        'birthday': birthday.toIso8601String().substring(0, 10),
        'address': address.trim(),
        'username': normalizedUsername(username),
      },
    );
  }
}

Future<void> initializeSupabaseIfConfigured() async {
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabasePublishableKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty && supabasePublishableKey.isEmpty) return;
  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    throw StateError(
      'Set both SUPABASE_URL and SUPABASE_ANON_KEY to enable account login.',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );
  AuthService._isConfigured = true;
}
