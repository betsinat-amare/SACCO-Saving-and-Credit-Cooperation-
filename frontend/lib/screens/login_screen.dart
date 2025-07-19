import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  onChanged: (val) => _email = val,
                  validator:
                      (val) =>
                          val == null || val.isEmpty ? 'Enter email' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onChanged: (val) => _password = val,
                  validator:
                      (val) =>
                          val == null || val.isEmpty ? 'Enter password' : null,
                ),
                const SizedBox(height: 16),
                if (authProvider.error != null)
                  Text(
                    authProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ElevatedButton(
                  onPressed:
                      authProvider.isLoading
                          ? null
                          : () async {
                            if (_formKey.currentState!.validate()) {
                              final success = await authProvider.login(
                                _email,
                                _password,
                              );
                              if (success) {
                                // Navigate based on role
                                if (authProvider.user!.role == 'admin') {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/admin',
                                  );
                                } else {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/member',
                                  );
                                }
                              }
                            }
                          },
                  child:
                      authProvider.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Login'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text('No account? Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
