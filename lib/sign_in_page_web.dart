import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'verification_screen.dart';
import 'sign_up_page.dart'; // Import your SignUpPage

class SignInPageWeb extends StatefulWidget {
  @override
  _SignInPageWebState createState() => _SignInPageWebState();
}

class _SignInPageWebState extends State<SignInPageWeb> {
  final _formKey = GlobalKey<FormState>();
  final _meterNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  Future<void> _signIn(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final meterNumber = _meterNumberController.text;
      final password = _passwordController.text;

      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('meterNumber', isEqualTo: meterNumber)
            .where('password', isEqualTo: password)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var userData = querySnapshot.docs.first;
          String userID = userData.id;

          // Navigate to real-time energy page with user data
          Navigator.pushReplacementNamed(
            context,
            '/real-time-energy',
            arguments: {
              'userID': userID,
              'firstName': userData['firstName'],
              'lastName': userData['lastName'],
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Invalid meter number or password'),
            backgroundColor: Colors.red,
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _forgotPassword() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Enter your phone number to reset your password:'),
              SizedBox(height: 10),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String phoneNumber = _phoneNumberController.text;

                try {
                  String verificationCode = await _sendVerificationCode(phoneNumber);

                  Navigator.of(context).pop();
                  _navigateToVerificationScreen(phoneNumber, verificationCode);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error sending verification code: $e'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: Text('Send Verification Code'),
            ),
          ],
        );
      },
    );
  }

  Future<String> _sendVerificationCode(String phoneNumber) async {
    String apiUrl = 'https://api.mtn.com/sms/send';
    Map<String, dynamic> requestData = {
      'phone_number': phoneNumber,
      'message': 'Your verification code is: 123456',
    };

    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('api_username:api_password'));

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        return '123456';
      } else {
        throw Exception('Failed to send SMS: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send SMS: $e');
    }
  }

  void _navigateToVerificationScreen(String phoneNumber, String verificationCode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationScreen(
          phoneNumber: phoneNumber,
          verificationCode: verificationCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 244, 244, 0.9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(32.0),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20), // Add space at the top
                    Image.asset(
                      'assets/images/idCvAAYI-f_logos.png',
                      height: 100,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _buildTextField(
                            controller: _meterNumberController,
                            labelText: 'Meter Number',
                            icon: Icons.format_list_numbered,
                          ),
                          SizedBox(height: 10),
                          _buildTextField(
                            controller: _passwordController,
                            labelText: 'Password',
                            icon: Icons.lock,
                            obscureText: true,
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: SizedBox(
                              width: 150, // Reduce the width of the sign-in button
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () => _signIn(context),
                                icon: Icon(Icons.login, color: Colors.white),
                                label: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10), // Add space between the button and the forgot password text
                          TextButton(
                            onPressed: _forgotPassword,
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.red,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignUpPage()),
                              );
                            },
                            child: Text(
                              'Don\'t have an account? Sign Up',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 20), // Add space at the bottom
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
  }) {
    return Center(
      child: Container(
        width: 600, // Set the desired width for the text fields
        child: TextFormField(
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
          ),
          obscureText: obscureText,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your $labelText';
            }
            return null;
          },
        ),
      ),
    );
  }
}
