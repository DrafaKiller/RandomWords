import 'package:flutter/material.dart';
import 'package:random_words/api.dart';

import 'register.dart';

class LoginPage extends StatefulWidget {
  final void Function(API api)? onLogin;
  
  const LoginPage({
    Key? key,
    this.onLogin,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Random Words',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
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
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () => _login(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        child: Text('Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showRegister(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        child: Text('Register')
                      ),
                    ),
                  ]
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showRegister() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => RegisterPage(
        onRegister: (username, password) {
          Navigator.pop(context);
          _usernameController.text = username;
          _passwordController.text = password;
          _login();
        },
        onCancel: () => Navigator.of(context).pop())
      )
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      API? api = await API.login(_usernameController.text, _passwordController.text);
      if (api != null) {
        widget.onLogin?.call(api);

        _usernameController.clear();
        _passwordController.clear();
      } else {
        _passwordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username or password is incorrect', textAlign: TextAlign.center),
          ),
        );
      }
    }
  }
}