import 'package:flutter/material.dart';

class CustomBotton extends StatelessWidget {
  final VoidCallback onPressed; // Callback for button action

  const CustomBotton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250, // Full-width button
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color.fromARGB(255, 231, 45, 59), // Button background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32), // Rounded corners
          ),
          padding:
              const EdgeInsets.symmetric(vertical: 17), // Padding for height

          elevation: 10, // Shadow effect
        ),
        child: const Text(
          "Get Started  ->",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Inter",
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
