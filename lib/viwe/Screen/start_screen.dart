import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:recipe/viwe/Screen/login.dart';
import 'package:recipe/viwe/widget/custom_botton.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of image paths for the slider
    final List<String> imageList = [
      'assets/images/salads.png',
      'assets/images/pizza.png',
      'assets/images/burger.png',
      'assets/images/paneer.png',
      'assets/images/thali2.png'
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(
          255, 238, 179, 18), //fromARGB(255, 247, 173, 77),
      body: Column(
        children: [
          // Image slider section
          Expanded(
            flex: 2,
            child: CarouselSlider(
              options: CarouselOptions(
                height: double.infinity, // Slider takes full height
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
                aspectRatio: 16 / 9,
                autoPlayInterval: const Duration(seconds: 3),
              ),
              items: imageList.map((imagePath) {
                return Builder(
                  builder: (BuildContext context) {
                    return Image.asset(
                      imagePath,
                    );
                  },
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 30),
          // Text and button section
          Expanded(
            child: Column(
              children: [
                Text(
                  "Start Cooking",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  width: 208,
                  child: Text(
                    "Let's join our community to \n     cook better food!",
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 82),
                CustomBotton(
                  onPressed: () {
                    // final prefs = await SharedPreferences.getInstance();
                    // await prefs.setBool('hasSeenStartScreen', true);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AuthScreen(), // Replace with your login screen
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
