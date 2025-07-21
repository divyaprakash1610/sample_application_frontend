import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sampleappfrontend/screens/Main_screens/home_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_pass.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  bool isLoading = false;
  bool obscurePassword = true;
  List<String> emailHistory = [];

  @override
  void initState() {
    super.initState();
    loadEmailHistory();
  }

  Future<void> loadEmailHistory() async {
    final prefs = await SharedPreferences.getInstance();
    emailHistory = prefs.getStringList('email_history') ?? [];
    setState(() {});
  }

  Future<void> saveEmailToHistory(String email) async {
    final prefs = await SharedPreferences.getInstance();
    if (!emailHistory.contains(email)) {
      emailHistory.insert(0, email); // most recent first
      await prefs.setStringList('email_history', emailHistory);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      FocusScope.of(context).requestFocus(emailFocusNode);
      return;
    }
    if (password.isEmpty) {
      FocusScope.of(context).requestFocus(passwordFocusNode);
      return;
    }

    setState(() => isLoading = true);

    final url =
        Uri.parse('https://sample-application-backend.onrender.com/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await saveEmailToHistory(email);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandingPage()),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${data['message']}")),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Login", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/car_logo.png',
                  width: screenWidth * 0.8),
              SizedBox(height: screenHeight * 0.03),

              // Email with Autocomplete
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue value) {
                  if (value.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return emailHistory.where((email) =>
                      email.toLowerCase().contains(value.text.toLowerCase()));
                },
                onSelected: (String selection) {
                  emailController.text = selection;
                },
                fieldViewBuilder: (context, textEditingController, focusNode,
                    onFieldSubmitted) {
                  textEditingController.text = emailController.text;
                  textEditingController.selection = TextSelection.fromPosition(
                    TextPosition(offset: textEditingController.text.length),
                  );
                  return TextField(
                    controller: textEditingController,
                    focusNode: emailFocusNode,
                    onChanged: (val) => emailController.text = val,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 61, 61, 61)),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: screenHeight * 0.02),

              // Password with eye toggle
              TextField(
                controller: passwordController,
                focusNode: passwordFocusNode,
                obscureText: obscurePassword,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() => obscurePassword = !obscurePassword);
                    },
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 61, 61, 61)),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  ),
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize:
                            Size(screenWidth * 0.9, screenHeight * 0.06),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: handleLogin,
                      child: Text("Login",
                          style: TextStyle(fontSize: screenWidth * 0.04)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
