import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:symptomm/screens/auth/create_account_screen.dart';
import 'package:symptomm/screens/home/home_screen.dart';
import 'package:symptomm/services/auth_service.dart';
import 'package:symptomm/widgets/common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    if (!AuthService.isConfigured) {
      _showMessage(
        'Account login is not configured yet. Follow the Supabase setup in README.md.',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.signIn(
        username: _usernameController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      _openHome();
    } on AuthException catch (error) {
      _showMessage(error.message);
    } on Exception catch (error) {
      _showMessage('Could not log in: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvas,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xFF182633), const Color(0xFF1D2D3B)]
                : [const Color(0xFFEAF1F8), const Color(0xFFF1F6FB)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: card(radius: 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _BrandHeader(),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _usernameController,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: _validateUsername,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _signIn(),
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Enter your password'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _isLoading ? null : _signIn,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Log in'),
                        ),
                        const SizedBox(height: 18),
                        const Divider(),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          key: const ValueKey('continue-as-guest'),
                          onPressed: _isLoading ? null : _openHome,
                          child: const Text('Continue as a guest'),
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const CreateAccountScreen(),
                                    ),
                                  ),
                          child: const Text('Create an account'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? _validateUsername(String? value) {
  final username = value?.trim() ?? '';
  if (username.isEmpty) return 'Enter your username';
  if (!RegExp(r'^[a-zA-Z0-9._-]{3,24}$').hasMatch(username)) {
    return 'Use 3–24 letters, numbers, dots, underscores or hyphens';
  }
  return null;
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(7),
            decoration: insetSurface(radius: 21),
            child: Image.asset(
              'assets/images/mediora_logo.png',
              semanticLabel: 'Mediora logo',
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Welcome to Mediora',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ink,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );
}
