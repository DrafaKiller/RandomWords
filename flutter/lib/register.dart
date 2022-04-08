import 'package:flutter/material.dart';
import 'package:random_words/api.dart';

class RegisterPage extends StatefulWidget {
  final void Function(String username, String password)? onRegister;
  final void Function()? onCancel;

  const RegisterPage({
    Key? key,
    this.onRegister,
    this.onCancel,
  }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'New Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(hintText: 'Username'),
                      validator: (String? value) {
                        if (value == null || value.isEmpty || value.length < 3) {
                          return 'Username must be at least 3 characters long';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(hintText: 'Password'),
                      obscureText: true,
                      validator: (String? value) {
                        if (value == null || value.isEmpty || value.length < 5) {
                          return 'Password must be at least 5 characters long';
                        }
                        return null;
                      },
                    ),
                  ],
                )
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _register(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Text('Register', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                ),
              ),
              TextButton(
                onPressed: () => _cancel(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Text('Cancel')
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _register(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      bool registered = await API.register(_usernameController.text, _passwordController.text);
      if (registered) {
        widget.onRegister?.call(_usernameController.text, _passwordController.text);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username already registered'),
          ),
        );
      }
    }
  }

  void _cancel() {
    _usernameController.clear();
    _passwordController.clear();
    widget.onCancel?.call();
  }
}