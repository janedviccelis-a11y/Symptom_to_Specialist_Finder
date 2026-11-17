import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:symptomm/screens/auth/login_screen.dart';
import 'package:symptomm/services/auth_service.dart';
import 'package:symptomm/widgets/common.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _birthday;
  String? _username;
  String? _loadError;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    if (AuthService.hasSignedInSession) {
      _loadProfile();
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _surnameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final profile = await AuthService.getProfile();
      if (!mounted) return;
      _firstNameController.text = profile['first_name'] as String;
      _surnameController.text = profile['surname'] as String;
      _addressController.text = profile['address'] as String;
      _username = profile['username'] as String;
      _birthday = DateTime.parse(profile['birthday'] as String);
    } on AuthException catch (error) {
      if (mounted) setState(() => _loadError = error.message);
    } on Exception catch (error) {
      if (mounted) {
        setState(() => _loadError = 'Could not load profile: $error');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select your birthday',
    );
    if (selected != null && mounted) setState(() => _birthday = selected);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final birthday = _birthday;
    if (birthday == null) {
      _showMessage('Select your birthday');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await AuthService.updateProfile(
        firstName: _firstNameController.text,
        surname: _surnameController.text,
        birthday: birthday,
        address: _addressController.text,
      );
      if (mounted) _showMessage('Profile updated');
    } on AuthException catch (error) {
      _showMessage(error.message);
    } on Exception catch (error) {
      _showMessage('Could not update profile: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await AuthService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } on AuthException catch (error) {
      _showMessage(error.message);
    } on Exception catch (error) {
      _showMessage('Could not log out: $error');
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? 'Enter your $label' : null;

  @override
  Widget build(BuildContext context) => Shell(
        title: 'Your profile',
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: card(radius: 26),
                      child: AuthService.hasSignedInSession
                          ? _buildSignedInProfile()
                          : _buildGuestProfile(),
                    ),
                  ),
                ),
              ),
      );

  Widget _buildGuestProfile() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Guest profile',
            style: TextStyle(
              color: ink,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log in to view and update your account details.',
            style: TextStyle(color: mutedInk),
          ),
          const SizedBox(height: 16),
          if (!AuthService.isConfigured)
            Text(
              AuthService.configurationError ??
                  'Supabase is not configured. Account login is unavailable.',
              style: const TextStyle(color: Colors.red),
            )
          else
            FilledButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                (_) => false,
              ),
              child: const Text('Log in'),
            ),
        ],
      );

  Widget _buildSignedInProfile() {
    if (_loadError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_loadError!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _loadProfile,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _isSigningOut ? null : _signOut,
            child: const Text('Log out'),
          ),
        ],
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Profile details',
            style: TextStyle(
              color: ink,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _firstNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'First name'),
            validator: (value) => _required(value, 'first name'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _surnameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Surname'),
            validator: (value) => _required(value, 'surname'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickBirthday,
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(
              _birthday == null
                  ? 'Birthday'
                  : '${_birthday!.day.toString().padLeft(2, '0')}/${_birthday!.month.toString().padLeft(2, '0')}/${_birthday!.year}',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Address'),
            validator: (value) => _required(value, 'address'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _username,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Username',
              helperText: 'Username cannot be changed.',
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save changes'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isSigningOut ? null : _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}
