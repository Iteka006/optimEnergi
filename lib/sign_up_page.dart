import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optim_energi/sign_in_page.dart';
import 'package:optim_energi/sign_in_page_web.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _meterNumberController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

Future<void> _signUp() async {
  if (_formKey.currentState!.validate()) {
    final meterNumber = _meterNumberController.text;
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final telephone = _telephoneController.text;
    final password = _passwordController.text;

    try {
      DocumentReference userRef = await FirebaseFirestore.instance.collection('users').add({
        'meterNumber': meterNumber,
        'firstName': firstName,
        'lastName': lastName,
        'telephone': telephone,
        'password': password,
      });

      // Add energy_usage sub-collection for the new user
      await userRef.collection('energy_usage').add({
        'date': Timestamp.now(), // Example initial usage document
        'usage': 0.0,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign Up Successful')));
      Navigator.pop(context); // Navigate back after sign-up
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}



  String? _validateMeterNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Meter Number';
    }
    if (value.length != 11 || !RegExp(r'^\d{11}$').hasMatch(value)) {
      return 'Meter Number must be 11 digits';
    }
    return null;
  }

  String? _validateTelephone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Telephone Number';
    }
    if (value.length != 10 || !RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Telephone Number must be 10 digits';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Password';
    }
    if (value.length < 8 ||
        !RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$').hasMatch(value)) {
      return 'Password must be at least 8 characters long and include a mix of letters, numbers, and special characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 244, 244, 0.9),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.0, 80.0, 16.0, 0), // Adjusted top padding to 20.0
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Text(
                'Create an Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 20), // Added a smaller sized SizedBox for spacing
              _buildTextField(
                controller: _meterNumberController,
                labelText: 'Meter Number',
                icon: Icons.electric_meter,
                validator: _validateMeterNumber,
              ),
              SizedBox(height: 10),
              _buildTextField(
                controller: _firstNameController,
                labelText: 'First Name',
                icon: Icons.person,
              ),
              SizedBox(height: 10),
              _buildTextField(
                controller: _lastNameController,
                labelText: 'Last Name',
                icon: Icons.person_outline,
              ),
              SizedBox(height: 10),
              _buildTextField(
                controller: _telephoneController,
                labelText: 'Telephone Number',
                icon: Icons.phone,
                validator: _validateTelephone,
              ),
              SizedBox(height: 10),
              _buildTextField(
                controller: _passwordController,
                labelText: 'Password',
                icon: Icons.lock,
                obscureText: true,
                validator: _validatePassword,
              ),
              SizedBox(height: 10),
              _buildTextField(
                controller: _confirmPasswordController,
                labelText: 'Confirm Password',
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _signUp,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Already have an account?',
                style: TextStyle(color: Color.fromARGB(255, 151, 97, 83)),
              ),
              TextButton(
                 onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignInPageWeb()), // Navigate to SignInPage
                  );
                },
                child: Text(
                  'Sign In',
                  style: TextStyle(color: Colors.red, fontSize: 16), // Changed text color to blue
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.red),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        errorStyle: TextStyle(
          fontSize: 14,
          color: Colors.red,
          height: 1.4,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }
}
