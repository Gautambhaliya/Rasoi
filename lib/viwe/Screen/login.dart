// import 'package:app/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:recipe/viwe/Screen/home_Screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  bool isLogin = true;
  bool _obscureText = true;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.2), end: Offset(0, 0))
        .animate(_controller);
    _controller.forward();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Error", style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _authenticate() async {
    try {
      if (!isLogin) {
        if (nameController.text.trim().isEmpty ||
            surnameController.text.trim().isEmpty) {
          _showErrorDialog("Please enter both First Name and Last Name.");
          return;
        }
      }

      if (emailController.text.trim().isEmpty ||
          passwordController.text.trim().isEmpty) {
        _showErrorDialog("Email and Password are required.");
        return;
      }

      if (isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            "Login successful!",
            style: TextStyle(fontSize: 10),
          )),
        );

        _clearFields();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': nameController.text.trim(),
          'surname': surnameController.text.trim(),
          'email': emailController.text.trim(),
          'joinDate': FieldValue.serverTimestamp(), // 🔥 Store Joined Date
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            "Registration successful!",
            style: TextStyle(fontSize: 12),
          )),
        );

        _clearFields();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage =
          "Something went wrong. Please try again."; // Default message

      // Firebase Error Code Matching
      if (e.code == 'user-not-found') {
        errorMessage = "No account found with this email. Please sign up.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password. Please try again.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already registered.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format. Please check your email.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password should be at least 6 characters.";
      }

      print("Firebase Error: ${e.code}"); // Debugging
      _showErrorDialog(errorMessage); // Show custom error
    } catch (e) {
      print("Unexpected Error: $e"); // Debugging
      _showErrorDialog(
        "Something went wrong. Please try again.",
      );
    }
  }

  Future<void> _resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          "Please enter your email to reset password",
          style: TextStyle(fontSize: 12),
        )),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "If an account exists, you will receive a password reset email.",
                style: TextStyle(fontSize: 12))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          "Something went wrong. Please try again.",
          style: TextStyle(fontSize: 12),
        )),
      );
    }
  }

  void _clearFields() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    surnameController.clear();
  }

  @override
  void dispose() {
    if (mounted) {
      // ✅ Ensure widget is still active
      dispose();
    }
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _clearFields();
      isLogin = !isLogin;
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 44, 120, 206),
              const Color.fromARGB(255, 204, 220, 224)
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Image.asset(
                    isLogin
                        ? 'assets/images/login_image.png'
                        : 'assets/images/sign_up.png',
                    height: 120,
                  )
                      .animate()
                      .fade(duration: 1000.ms)
                      .slideY(begin: -0.5, end: 0),
                  SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        isLogin ? "Welcome Back!" : "Create Account",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (!isLogin) ...[
                    _buildTextField(
                      controller: nameController,
                      labelText: "First Name",
                      icon: Icons.person,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: surnameController,
                      labelText: "Last Name",
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 20),
                  ],
                  _buildTextField(
                    controller: emailController,
                    labelText: "Email",
                    icon: Icons.email,
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: passwordController,
                    labelText: "Password",
                    icon: Icons.lock,
                    obscureText: _obscureText,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _authenticate,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isLogin ? "Sign In" : "Sign Up",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(height: 10),
                  if (isLogin) // Only show "Forgot Password" on the login page
                    TextButton(
                      onPressed: _resetPassword,
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: _toggleAuthMode,
                    child: Text(
                      isLogin
                          ? "Don't have an account? Sign Up"
                          : "Already have an account? Sign In",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    },
                    style: TextButton.styleFrom(
                        // backgroundColor: Colors.white,
                        padding: EdgeInsets.fromLTRB(18, 15, 18, 15)),
                    child: Text(
                      "Continue as Guest",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 9, 126, 236),
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                ],
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
    Widget? suffixIcon,
    // TextStyle?textStyle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style:
            TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'roboto'),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.white70, fontSize: 13),
          border: InputBorder.none,
          prefixIcon: Icon(
            icon,
            color: Colors.white70,
          ),
          suffixIcon: suffixIcon,
          contentPadding: EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        ),
      ),
    );
  }
}
