import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<AdminLogin> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String? _email, _password;
  bool _isLoading = false;

  Future<void> _showDialog(String title, String content) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        // Verify the specific admin email and password
        if (_email == 'yasithinosh1@gmail.com' && _password == 'Admin@2001') {
          // Attempt to log in the user with Firebase
          await _auth.signInWithEmailAndPassword(
            email: _email!,
            password: _password!,
          );

          await _showDialog('Success', 'Login Successful!');
          if (!mounted) return;

          // Navigate to the admin dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
        } else {
          await _showDialog('Login Failed', 'Invalid email or password.');
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'No user found for that Email.';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password provided.';
        } else {
          message = 'Login failed. Please try again.';
        }
        await _showDialog('Login Failed', message);
      } catch (e) {
        await _showDialog(
          'Error',
          'An unexpected error occurred. Please try again.',
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/facultyimage.jpg', fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 234, 222, 222).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(31, 8, 8, 8),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Admin Login',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _buildTextField(
                          'Admin Email',
                          onSaved: (value) => _email = value,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          'Password',
                          onSaved: (value) => _password = value,
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 254, 169, 58),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Log In',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 57, 22, 161),
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint,
      {bool obscureText = false,
      required Function(String?) onSaved,
      TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $hint';
        }
        if (hint == 'University Email' &&
            !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey.shade200,
        hintText: hint,
      ),
    );
  }
}
