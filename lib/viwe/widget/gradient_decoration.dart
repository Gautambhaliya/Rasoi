import 'package:flutter/material.dart';

class GradientDecoration {
  static BoxDecoration get linearGradient => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFDEFFB), // Very light lavender-pink
            Color(0xFFFFF9EC), // Soft creamy peach
            Color.fromARGB(255, 240, 236, 229), // Soft creamy peach
            Color(0xFFFDEFFB), // Very light lavender-pink
          ],

          // More colors

          // colors: [
          //   Color(0xFFF3E5F5),
          //   Color(0xFFFFF3E0),
          // ],
          // colors: [
          //   Color(0xFFEEDCF6), // Soft lavender with a bit more richness
          //   Color(0xFFFFE9CA), // Brighter, creamy peach
          // ],
          // colors: [
          //   Color(0xFFE1BEE7), // Slightly deeper lavender
          //   Color(0xFFFFCCBC), // Light coral peach
          // ],

          // colors: [
          //   Color(0xFFFCE4EC), // Light pink
          //   Color(0xFFE0F7FA), // Soft aqua blue
          // ],
          // colors: [
          //   Color(0xFFFFF0EB), // Soft peach
          //   Color(0xFFEDE7F6), // Light lavender
          // ],
          // colors: [
          //   Color(0xFFEDE7F6), // Light lavender
          //   Color(0xFFF3F7FF), // Very soft bluish white
          // ],
          // colors: [
          //   Color(0xFFF0F4F8), // Foggy blue
          //   Color(0xFFEBF3FA), // Pale cloud blue
          // ],
          // colors: [
          //   Color(0xFFF7FAFC), // Snow white
          //   Color(0xFFE8ECF1), // Misty grey-blue
          // ],
          // colors: [
          //   Color(0xFFFFFAF3), // Cream white
          //   Color(0xFFE3F2FD), // Baby blue
          // ],
          //  colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
          // colors: [Color(0xFFF1F8E9), Color(0xFFD0F0C0)],
          // colors: [Color(0xFFFFF8E1), Color(0xFFEDE7F6)],
          // colors: [Color(0xFFF0F8FF), Color(0xFFE0F7FA)],
          // colors: [Color(0xFFEDE7F6), Color(0xFFE3F2FD)],
          // colors: [Color(0xFFE6F4EA), Color(0xFFFAFFF9)],
          // colors: [Color(0xFFFFF0F0), Color(0xFFFFF7FA)],
          // colors: [Color(0xFFF9FBFF), Color(0xFFF0F4F8)],
          // colors: [Color(0xFFF0F8FF), Color(0xFFE6F7FF)],
          // colors: [Color(0xFFFFF5F7), Color(0xFFFFFBF2)],
          // colors: [Color(0xFFE8F5E9), Color(0xFFE0F2F1)],
        ),
      );
}
