import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:recipe/firebase_options.dart';
// import 'package:recipe/viwe/Screen/add_recipe.dart';
// import 'package:recipe/viwe/Screen/favorites_Screen.dart';
import 'package:recipe/viwe/Screen/home_Screen.dart';
import 'package:recipe/viwe/Screen/login.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => Home(),
        '/login': (context) => AuthScreen(),
      },
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: LoadingIndicator(
                indicatorType:
                    Indicator.ballClipRotate, // Choose your preferred indicator
                colors: [
                  Colors.blue,
                  Colors.green,
                  Colors.red
                ], // Customize colors
                strokeWidth: 2.0, // Customize stroke width
              ),
            ),
          );
        }
        if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: LoadingIndicator(
                      indicatorType: Indicator
                          .ballRotate, // Choose your preferred indicator
                      colors: [
                        Colors.blue,
                        Colors.green,
                        Colors.red
                      ], // Customize colors
                      strokeWidth: 2.0, // Customize stroke width
                    ),
                  ),
                );
              }

              var userData = userSnapshot.data?.data() as Map<String, dynamic>?;

              // 🔹 If the document doesn't exist or doesn't contain a 'role', default to Home()
              if (userData == null || !userData.containsKey('role')) {
                return Home();
              }

              return Home(); // 🔹 After role check, load Home()
            },
          );
        }
        return Home(); // 🔹 If the user is not logged in, redirect to Home()
      },
    );
  }
}
