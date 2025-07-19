import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _registered = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              _registered
                  ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 64),
                      SizedBox(height: 16),
                      Text(
                        'Registration successful!\nPlease wait for admin approval.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                  : Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Name'),
                          onChanged: (val) => _name = val,
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? 'Enter name'
                                      : null,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Email'),
                          onChanged: (val) => _email = val,
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? 'Enter email'
                                      : null,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          onChanged: (val) => _password = val,
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? 'Enter password'
                                      : null,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                          ),
                          obscureText: true,
                          onChanged: (val) => _confirmPassword = val,
                          validator:
                              (val) =>
                                  val != _password
                                      ? 'Passwords do not match'
                                      : null,
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
                                      final success = await authProvider
                                          .register(_name, _email, _password);
                                      if (success) {
                                        setState(() {
                                          _registered = true;
                                        });
                                      }
                                    }
                                  },
                          child:
                              authProvider.isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Register'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Already have an account? Login'),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
