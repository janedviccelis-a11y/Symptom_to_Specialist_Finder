import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static bool _isConfigured = false;
  static String? _configurationError;

  static bool get isConfigured => _isConfigured;
  static String? get configurationError => _configurationError;

  static bool get hasSignedInSession =>
      _isConfigured && Supabase.instance.client.auth.currentSession != null;

  static String? get currentUsername {
    if (!_isConfigured) return null;
    final user = Supabase.instance.client.auth.currentUser;
    final username = user?.userMetadata?['username'];
    return username is String && username.isNotEmpty ? username : null;
  }

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

  static Future<Map<String, dynamic>> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Sign in to view your profile.');

    final profile = await _client
        .from('profiles')
        .select('first_name, surname, birthday, address, username')
        .eq('id', user.id)
        .single();
    return Map<String, dynamic>.from(profile);
  }

  static Future<void> updateProfile({
    required String firstName,
    required String surname,
    required DateTime birthday,
    required String address,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Sign in to update your profile.');

    await _client.from('profiles').update({
      'first_name': firstName.trim(),
      'surname': surname.trim(),
      'birthday': birthday.toIso8601String().substring(0, 10),
      'address': address.trim(),
    }).eq('id', user.id);
  }

  static Future<void> signOut() => _client.auth.signOut();
}

Future<void> initializeSupabaseIfConfigured() async {
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ogonbbmuojjbfdwhzbvv.supabase.co',
  );
  const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_v0MYGTvbjEz15YXyNqkrEQ_SHoZDLst',
  );

  if (supabaseUrl.isEmpty && supabasePublishableKey.isEmpty) return;
  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    AuthService._configurationError =
        'Set both SUPABASE_URL and SUPABASE_ANON_KEY to enable account login.';
    return;
  }

  final projectUri = Uri.tryParse(supabaseUrl);
  if (projectUri == null ||
      (projectUri.scheme != 'https' && projectUri.scheme != 'http') ||
      projectUri.host.isEmpty ||
      (projectUri.path.isNotEmpty && projectUri.path != '/') ||
      projectUri.hasQuery ||
      projectUri.hasFragment) {
    AuthService._configurationError =
        'SUPABASE_URL must be the project URL only, for example '
        'https://your-project.supabase.co. Do not include /rest/v1 or /auth/v1.';
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl.replaceFirst(RegExp(r'/+$'), ''),
    publishableKey: supabasePublishableKey,
  );
  AuthService._isConfigured = true;
}
