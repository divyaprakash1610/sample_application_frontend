import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final emailFocus = FocusNode();
  final otpFocus = FocusNode();
  final newPassFocus = FocusNode();
  final confirmPassFocus = FocusNode();

  bool showOtpField = false;
  bool otpVerified = false;
  bool isLoading = false;

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  final baseUrl = "https://sample-application-backend.onrender.com";

  Timer? otpTimer;
  int remainingSeconds = 300;

  @override
  void dispose() {
    otpTimer?.cancel();
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    emailFocus.dispose();
    otpFocus.dispose();
    newPassFocus.dispose();
    confirmPassFocus.dispose();
    super.dispose();
  }

  void startOtpTimer() {
    otpTimer?.cancel();
    setState(() => remainingSeconds = 300);
    otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (remainingSeconds == 0) {
        timer.cancel();
        setState(() => showOtpField = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP expired. Please resend.")),
        );
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  Future<void> handleSendOtp({bool isResend = false}) async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      FocusScope.of(context).requestFocus(emailFocus);
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/forgot-password"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 201) {
        if (!isResend) {
          setState(() => showOtpField = true);
        }
        startOtpTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isResend ? "OTP resent" : "OTP sent")),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${data['message']}")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> handleVerifyOtp() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      FocusScope.of(context).requestFocus(otpFocus);
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/verify-otp"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 201) {
        setState(() => otpVerified = true);
        otpTimer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP Verified Successfully")),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid OTP: ${data['message']}")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> handleResetPassword() async {
    final email = emailController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final otp = otpController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      FocusScope.of(context).requestFocus(
        newPassword.isEmpty ? newPassFocus : confirmPassFocus,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/reset-password"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset successfully")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${data['message']}")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Reset Password", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.025),
              _buildTextField(
                label: 'Enter your email',
                controller: emailController,
                focusNode: emailFocus,
              ),
              if (showOtpField) ...[
                SizedBox(height: screenHeight * 0.025),
                _buildTextField(
                  label: 'Enter OTP',
                  controller: otpController,
                  focusNode: otpFocus,
                  keyboardType: TextInputType.number,
                ),
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
                        child: _buildButton(
                            "Verify OTP", handleVerifyOtp, screenWidth)),
                    TextButton(
                      onPressed: () => handleSendOtp(isResend: true),
                      child: const Text("Resend OTP",
                          style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ] else ...[
                SizedBox(height: screenHeight * 0.025),
                _buildButton("Send OTP", handleSendOtp, screenWidth),
              ],
              if (otpVerified) ...[
                SizedBox(height: screenHeight * 0.025),
                _buildTextField(
                  label: 'New Password',
                  controller: newPasswordController,
                  focusNode: newPassFocus,
                  obscureText: !_showPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),
                _buildTextField(
                  label: 'Confirm New Password',
                  controller: confirmPasswordController,
                  focusNode: confirmPassFocus,
                  obscureText: !_showConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword),
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),
                _buildButton("Continue", handleResetPassword, screenWidth),
              ],
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed, double width) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width * 0.9, 50),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      child: Text(label, style: TextStyle(fontSize: width * 0.04)),
    );
  }
}
