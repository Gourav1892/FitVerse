import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _inputController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _fullPhoneNumber;
  bool _isPhone = true;
  bool _loading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String selectedRole = 'trainee';

  void _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    final input = _inputController.text.trim();

    if (selectedRole == 'trainer') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Trainer registration requires admin approval for email/phone.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_isPhone) {
      if (_fullPhoneNumber == null || !_fullPhoneNumber!.startsWith('+')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid phone number'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() => _loading = true);

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _fullPhoneNumber!,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'OTP failed'), backgroundColor: Colors.red),
          );
        },
        codeSent: (String verId, int? resendToken) {
          setState(() => _loading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OTPVerificationScreen(
                phoneNumber: _fullPhoneNumber!,
                isFromRegister: true,
                verificationId: verId,
                role: selectedRole,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verId) {},
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPVerificationScreen(
            phoneNumber: input,
            isFromRegister: true,
            verificationId: '',
            role: selectedRole,
          ),
        ),
      );
    }
  }

  Widget _buildDynamicInputField() {
    return _isPhone
        ? IntlPhoneField(
      initialCountryCode: 'IN',
      controller: _inputController,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        border: OutlineInputBorder(),
      ),
      onChanged: (PhoneNumber phone) {
        _fullPhoneNumber = phone.completeNumber;
      },
    )
        : TextFormField(
      controller: _inputController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: "Email Address",
        border: OutlineInputBorder(),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Enter an email';
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(val)) return 'Invalid email format';
        return null;
      },
    );
  }

  Widget _buildToggleInputButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _isPhone = !_isPhone;
          _inputController.clear();
          _fullPhoneNumber = null;
        });
      },
      child: Text(
        _isPhone ? "Sign up with Email instead" : "Sign up with Phone Number instead",
        style: TextStyle(color: Colors.blue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == 0 ? Colors.blue : Colors.grey.shade300,
                      ),
                    );
                  }),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text("Step 1 of 4", style: TextStyle(color: Colors.grey.shade600)),
                ),
                SizedBox(height: 24),
                Text("Create Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("Let's get started with your fitness journey", style: TextStyle(color: Colors.grey.shade600)),
                SizedBox(height: 24),

                _buildDynamicInputField(),
                _buildToggleInputButton(),

                SizedBox(height: 16),
                Text("Password"),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    hintText: "Create a password",
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _passwordVisible = !_passwordVisible);
                      },
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Enter password";
                    if (val.length < 6) return "Password must be at least 6 characters";
                    return null;
                  },
                ),

                SizedBox(height: 16),
                Text("Confirm Password"),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_confirmPasswordVisible,
                  decoration: InputDecoration(
                    hintText: "Confirm your password",
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _confirmPasswordVisible = !_confirmPasswordVisible);
                      },
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Confirm your password";
                    if (val != _passwordController.text) return "Passwords do not match";
                    return null;
                  },
                ),

                SizedBox(height: 24),
                _loading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _loading ? null : _sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text("Send OTP", style: TextStyle(color: Colors.white)),
                ),

                SizedBox(height: 24),
                Center(
                  child: Text("Registering as: ${selectedRole.toUpperCase()}",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedRole == 'trainee' ? 0 : 1,
        onTap: (index) {
          setState(() {
            selectedRole = index == 0 ? 'trainee' : 'trainer';
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Trainee',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Trainer',
          ),
        ],
      ),
    );
  }
}
