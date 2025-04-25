import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gyansagar_frontend/ui/kit/alert.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/ui/widget/form/p_textfield.dart';
import 'package:gyansagar_frontend/ui/widget/p_button.dart';
import 'package:gyansagar_frontend/helper/images.dart';
import 'package:gyansagar_frontend/admin/utils/admin_preferences.dart'; // Add this import

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simulating API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Here you would make your actual API call
      final success = await _authenticateAdmin(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        setState(() {
          _error = 'Invalid admin credentials';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _authenticateAdmin(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Check if the response contains user data and verify admin role
        if (data['user'] != null) {
          final user = data['user'];
          if (user['role'] == 'admin') {
            await _saveAuthToken(user['token']);
            return true;
          } else {
            setState(() {
              _error = "Access denied. Admin privileges required.";
            });
            return false;
          }
        }
        return false;
      } else {
        // Handle different error responses
        final errorData = json.decode(response.body);
        if (errorData['errors']?['email'] != null) {
          setState(() {
            _error = errorData['errors']['email'][0];
          });
        } else if (errorData['errors']?['password'] != null) {
          setState(() {
            _error = errorData['errors']['password'][0];
          });
        } else if (response.statusCode == 403) {
          setState(() {
            _error = "User not verified!";
          });
        } else {
          setState(() {
            _error = "Login failed. Please try again.";
          });
        }
        return false;
      }
    } catch (e) {
      print('Authentication error: $e');
      setState(() {
        _error = "Connection error. Please try again.";
      });
      return false;
    }
  }

  Future<void> _saveAuthToken(String token) async {
    await AdminPreferences.saveAdminToken(
      token,
    ); // Changed from setAdminToken to saveAdminToken
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(
        255,
        255,
        255,
        1,
      ), // Add white background
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Add the logo image here with larger dimensions
                Center(
                  child: Image.asset(
                    Images.logo,
                    height: 280, // Increased from 120 to 180
                    width: 280, // Increased from 120 to 180
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Admin Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                PTextField(
                  controller: _emailController,
                  label: 'Email',
                  type: FieldType.email,
                  hintText: 'Enter admin email',
                ),
                const SizedBox(height: 16),
                PTextField(
                  controller: _passwordController,
                  label: 'Password',
                  type: FieldType.password,
                  hintText: 'Enter password',
                ),
                const SizedBox(height: 24),
                PFlatButton(
                  label: 'Login',
                  onPressed: () {
                    _handleLogin(); // Remove async/await here since PFlatButton expects VoidCallback
                  },
                  isLoading: ValueNotifier<bool>(_isLoading),
                  isColored: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
