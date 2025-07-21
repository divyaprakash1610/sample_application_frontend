import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sampleappfrontend/screens/Main_screens/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpController = TextEditingController();

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();
  final otpFocusNode = FocusNode();

  bool showOtpField = false;
  bool isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  Timer? otpTimer;
  int remainingSeconds = 300;

  @override
  void dispose() {
    otpTimer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    otpFocusNode.dispose();
    super.dispose();
  }

  void startOtpTimer() {
    otpTimer?.cancel();
    setState(() => remainingSeconds = 300);
    otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (remainingSeconds == 0) {
        timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP expired, please resend")),
        );
        setState(() => showOtpField = false);
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  Future<void> validateAndShowOtp() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty) {
      FocusScope.of(context).requestFocus(emailFocusNode);
      return;
    }
    if (password.isEmpty || !isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Password must include 8+ chars, uppercase, lowercase, number, and symbol.")),
      );
      return;
    }
    if (confirmPassword != password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse(
        "https://sample-application-backend.onrender.com/auth/signup");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      if (response.statusCode == 201) {
        setState(() => showOtpField = true);
        startOtpTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP sent to your email")),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup failed: ${data['message']}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> verifyOtpAndContinue() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      FocusScope.of(context).requestFocus(otpFocusNode);
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse(
        "https://sample-application-backend.onrender.com/auth/verify-otp");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      if (response.statusCode == 201) {
        otpTimer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP Verified Successfully")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandingPage()),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid OTP: ${data['message']}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> resendOtp() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter email to resend OTP')),
      );
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse(
        "https://sample-application-backend.onrender.com/auth/resend-otp");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      if (response.statusCode == 201) {
        startOtpTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP resent successfully")),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to resend OTP: ${data['message']}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  bool isValidPassword(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$');
    return regex.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Sign Up", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.asset('assets/images/car_logo.png', width: screenWidth * 0.8),
            SizedBox(height: screenHeight * 0.03),
            _buildTextField("Email", emailController, emailFocusNode),
            _buildPasswordField("Password", passwordController,
                passwordFocusNode, _showPassword, () {
              setState(() => _showPassword = !_showPassword);
            }),
            _buildPasswordField("Confirm Password", confirmPasswordController,
                confirmPasswordFocusNode, _showConfirmPassword, () {
              setState(() => _showConfirmPassword = !_showConfirmPassword);
            }),
            SizedBox(height: screenHeight * 0.03),
            if (showOtpField) ...[
              _buildTextField("Enter OTP", otpController, otpFocusNode,
                  TextInputType.number),
              SizedBox(height: screenHeight * 0.02),
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  "Expires in: ${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Expanded(
                      child: _buildButton("Verify OTP", verifyOtpAndContinue)),
                  TextButton(
                      onPressed: resendOtp,
                      child: const Text("Resend OTP",
                          style: TextStyle(color: Colors.white))),
                ],
              ),
            ] else
              _buildButton("Sign Up", validateAndShowOtp),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, FocusNode focusNode,
      [TextInputType keyboard = TextInputType.text]) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboard,
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller,
      FocusNode node, bool isVisible, VoidCallback toggle) {
    return TextField(
      controller: controller,
      focusNode: node,
      obscureText: !isVisible,
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white),
          onPressed: toggle,
        ),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 50),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black),
      child: Text(label),
    );
  }
}
