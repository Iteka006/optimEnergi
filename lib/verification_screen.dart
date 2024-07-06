import 'package:flutter/material.dart';

class VerificationScreen extends StatelessWidget {
  final String phoneNumber;
  final String verificationCode;

  VerificationScreen({required this.phoneNumber, required this.verificationCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Phone Number'),
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Verification Code Sent to $phoneNumber',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Verification Code',
                prefixIcon: Icon(Icons.code, color: Colors.red),
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the verification code';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add logic to verify the entered code
                // For simplicity, check if the entered code matches the generated one
                String enteredCode = ''; // Get the entered code from TextFormField
                if (enteredCode == verificationCode) {
                  // Navigate to reset password screen
                  Navigator.pushReplacementNamed(context, '/reset-password');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Invalid verification code. Please try again.'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: Text(
                'Verify Code',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
