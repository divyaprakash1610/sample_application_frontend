import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sampleappfrontend/screens/Main_screens/home_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class AuthWrapper extends StatelessWidget {
  AuthWrapper({super.key});

  final storage = const FlutterSecureStorage();

  void handleGoogleLogin(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
        clientId:
            '737597825085-ju5fp0r89774aiordsv07q3ibbmlkkr6.apps.googleusercontent.com',
      );
      await googleSignIn.signOut();
      final account = await googleSignIn.signIn();
      final auth = await account?.authentication;
      final idToken = auth?.idToken;

      if (idToken != null) {
        final response = await http.post(
          Uri.parse(
              'https://sample-application-backend.onrender.com/auth/google-mobile'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idToken': idToken}),
        );

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          final appJwt = data['token'];
          await storage.write(key: 'jwt_token', value: appJwt);

          Fluttertoast.showToast(msg: 'Login successful');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LandingPage()),
          );
        } else {
          Fluttertoast.showToast(msg: 'Google login failed');
        }
      } else {
        Fluttertoast.showToast(msg: 'Failed to retrieve ID token');
      }
    } catch (e) {
      print('Google Sign-In error: $e');
      Fluttertoast.showToast(msg: 'Google Sign-in failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.1),

                // App Logo
                Image.asset(
                  'assets/images/car_logo.png',
                  width: screenWidth * 0.8,
                ),
                SizedBox(height: screenHeight * 0.07),

                // Typewriter Animation
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  child: AnimatedTextKit(
                    repeatForever: true,
                    pause: const Duration(milliseconds: 500),
                    animatedTexts: [
                      TypewriterAnimatedText('Start your Engine',
                          speed: const Duration(milliseconds: 100)),
                      TypewriterAnimatedText('Hold Tight',
                          speed: const Duration(milliseconds: 100)),
                      TypewriterAnimatedText('Vroooom!',
                          speed: const Duration(milliseconds: 100)),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.2),

                // Google Sign-In Button
                OutlinedButton.icon(
                  onPressed: () => handleGoogleLogin(context),
                  icon: Image.asset(
                    'assets/images/google.png',
                    height: screenWidth * 0.06,
                  ),
                  label: const Text("Continue with Google"),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(screenWidth * 0.9, screenHeight * 0.06),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.2,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: Colors.white54, thickness: 1),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenHeight * 0.01),
                      child: const Text("or",
                          style: TextStyle(color: Colors.white70)),
                    ),
                    const Expanded(
                      child: Divider(color: Colors.white54, thickness: 1),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02),

                // Log in Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(screenWidth * 0.9, screenHeight * 0.06),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    "Log In with Email",
                    style: TextStyle(
                        color: Colors.black, fontSize: screenWidth * 0.04),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Sign up button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 35, 35, 35),
                    minimumSize: Size(screenWidth * 0.9, screenHeight * 0.06),
                  ),
                  child: Text(
                    "Sign Up instead",
                    style: TextStyle(
                        color: Colors.white, fontSize: screenWidth * 0.04),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
