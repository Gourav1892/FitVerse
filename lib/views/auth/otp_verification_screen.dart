import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SetNewPasswordScreen.dart';
import 'RegisterDetailsScreen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep; // 0 to 3

  const StepProgressIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Column(
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
                color: index == currentStep ? Colors.blue : Colors.grey.shade300,
              ),
            );
          }),
        ),
        SizedBox(height: 10),
        Text("Step \${currentStep + 1} of 4", style: TextStyle(color: Colors.grey.shade600)),
        SizedBox(height: 20),
      ],
    );
  }
}

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final bool isFromRegister;
  final String role;

  const OTPVerificationScreen({
    required this.phoneNumber,
    required this.verificationId,
    required this.isFromRegister,
    required this.role,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  String _error = '';
  bool _loading = false;

  void _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _error = 'Enter a valid 6-digit OTP');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (widget.isFromRegister) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterDetailsScreen(
              phoneOrEmail: widget.phoneNumber,
              role: widget.role,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SetNewPasswordScreen(phoneOrEmail: widget.phoneNumber),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = '⚠️ Invalid OTP. Please try again.';
        _otpController.clear();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StepProgressIndicator(currentStep: 1), // ✅ Step 2 of 4

                Text("Verification Code",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("A 6-digit code was sent to ${widget.phoneNumber}"),
                SizedBox(height: 30),

                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  autoFocus: true,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeColor: _error.isNotEmpty ? Colors.red : Colors.blue,
                    selectedColor: _error.isNotEmpty ? Colors.redAccent : Colors.blueAccent,
                    inactiveColor: _error.isNotEmpty ? Colors.red.shade200 : Colors.grey.shade300,
                  ),
                  animationDuration: Duration(milliseconds: 300),
                  onChanged: (value) {},
                ),

                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _error,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                  ),

                SizedBox(height: 20),

                _loading
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verifyOTP,
                    child: Text("Verify"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
