import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:symptomm/screens/home/home_screen.dart';
import 'package:symptomm/services/auth_service.dart';
import 'package:symptomm/widgets/common.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _addressController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime? _birthday;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _surnameController.dispose();
    _addressController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthday() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(today.year - 18, today.month, today.day),
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: 'Select your birthday',
    );
    if (selected != null && mounted) {
      setState(() => _birthday = selected);
    }
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthday == null) {
      _showMessage('Select your birthday');
      return;
    }
    if (!AuthService.isConfigured) {
      _showMessage(
        AuthService.configurationError ??
            'Account creation is not configured yet. Follow the Supabase setup in README.md.',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await AuthService.createAccount(
        firstName: _firstNameController.text,
        surname: _surnameController.text,
        birthday: _birthday!,
        address: _addressController.text,
        username: _usernameController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (response.session == null) {
        _showMessage(
          'Account created. If email confirmation is enabled, finish confirmation before logging in.',
        );
        Navigator.of(context).pop();
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } on AuthException catch (error) {
      _showMessage(error.message);
    } on Exception catch (error) {
      _showMessage('Could not create account: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? 'Enter your $label' : null;

  String? _validateUsername(String? value) {
    final username = value?.trim() ?? '';
    if (username.isEmpty) return 'Enter your username';
    if (!RegExp(r'^[a-zA-Z0-9._-]{3,24}$').hasMatch(username)) {
      return 'Use 3–24 letters, numbers, dots, underscores or hyphens';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter a password';
    if (value.length < 8) return 'Use at least 8 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) =>
      value != _passwordController.text ? 'Not match' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        title: const Text('Create an account'),
        backgroundColor: canvas,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: card(radius: 26),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Your details',
                        style: TextStyle(
                          color: ink,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _textField(
                        controller: _firstNameController,
                        label: 'First name',
                        validator: (value) => _required(value, 'first name'),
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      _textField(
                        controller: _surnameController,
                        label: 'Surname',
                        validator: (value) => _required(value, 'surname'),
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _selectBirthday,
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
                      _textField(
                        controller: _addressController,
                        label: 'Address',
                        validator: (value) => _required(value, 'address'),
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      _textField(
                        controller: _usernameController,
                        label: 'Username',
                        validator: _validateUsername,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newUsername],
                      ),
                      const SizedBox(height: 12),
                      _textField(
                        controller: _passwordController,
                        label: 'Password',
                        validator: _validatePassword,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        onChanged: (_) {
                          if (_confirmPasswordController.text.isNotEmpty) {
                            _formKey.currentState?.validate();
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _textField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        validator: _validateConfirmPassword,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => _formKey.currentState?.validate(),
                        onSubmitted: (_) => _createAccount(),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _isLoading ? null : _createAccount,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Create Account'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    Iterable<String>? autofillHints,
    bool obscureText = false,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) =>
      TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        obscureText: obscureText,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        validator: validator,
      );
}
