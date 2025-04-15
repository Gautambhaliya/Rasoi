import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe/viwe/widget/gradient_decoration.dart';
import 'package:recipe/viwe/widget/support_widget.dart';
import 'package:recipe/services/database.dart'; // Import the updated DatabaseMethods
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:loading_indicator/loading_indicator.dart';

class Recipe extends StatefulWidget {
  final String image, foodname, details;
  final List<String> recipe;
  final List<String> ingredients;
  final String recipeId;
  final String collectionName; // Added this parameter

  Recipe({
    required this.foodname,
    required this.image,
    required this.details,
    required List<dynamic> ingredients,
    required List<dynamic> recipe,
    required this.recipeId,
    this.collectionName = "Recipes", // Default to "Recipes"
  })  : ingredients = ingredients.cast<String>(),
        recipe = recipe.cast<String>();

  @override
  State<Recipe> createState() => _RecipeState();
}

class _RecipeState extends State<Recipe> {
  bool isFavorite = false;
  double userRating = 0; // User's current rating for this specific recipe
  double averageRating = 0; // Average rating for this specific recipe
  int totalRatings = 0; // Total number of ratings for this specific recipe
  bool hasUserRated = false; // Track if the user has rated this specific recipe
  bool isLoadingRatings = true; // Track loading state for ratings
  final DatabaseMethods _databaseMethods = DatabaseMethods();

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _loadRatingData(); // Load rating data specific to this recipe
  }

  void _checkIfFavorite() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('Favorites')
          .where('name', isEqualTo: widget.foodname)
          .get();

      if (mounted) {
        setState(() {
          isFavorite = snapshot.docs.isNotEmpty;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading favorites: $e')),
      );
    }
  }

  void _toggleFavorite() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add favorites')),
      );
      return;
    }

    if (mounted) {
      setState(() {
        isFavorite = !isFavorite;
      });
    }

    final collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('Favorites');

    try {
      if (isFavorite) {
        await collectionRef.add({
          'name': widget.foodname,
          'image': widget.image,
          'details': widget.details,
          'ingredients': widget.ingredients,
          'recipe': widget.recipe,
        });
      } else {
        final snapshot =
            await collectionRef.where('name', isEqualTo: widget.foodname).get();
        if (snapshot.docs.isNotEmpty) {
          await collectionRef.doc(snapshot.docs.first.id).delete();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isFavorite = !isFavorite; // Revert if operation fails
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating favorites: $e')),
        );
      }
    }
  }

  // Load rating data from Firestore for this specific recipe
  Future<void> _loadRatingData() async {
    if (!mounted) return;

    setState(() {
      isLoadingRatings = true;
    });

    final User? user = FirebaseAuth.instance.currentUser;
    final String? userId = user?.uid;

    try {
      // Fetch average rating and total ratings for this recipe
      final ratingsData = await _databaseMethods.getRecipeRatings(
          widget.recipeId, widget.collectionName);
      if (mounted) {
        setState(() {
          averageRating = ratingsData['averageRating'] as double;
          totalRatings = ratingsData['totalRatings'] as int;
        });
      }

      // Check if the current user has rated this specific recipe
      if (userId != null) {
        final userRatingValue = await _databaseMethods.getUserRating(
            widget.recipeId, userId, widget.collectionName);
        if (mounted) {
          setState(() {
            userRating = userRatingValue ?? 0;
            hasUserRated = userRatingValue != null;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            userRating = 0;
            hasUserRated = false;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading ratings: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoadingRatings = false;
        });
      }
    }
  }

  // Submit or update user rating for this specific recipe
  Future<void> _submitRating(double rating) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to rate this recipe')),
      );
      return;
    }

    if (!mounted) return;

    try {
      await _databaseMethods.submitRating(
          widget.recipeId, rating, user.uid, widget.collectionName);

      await _loadRatingData(); // Reload to update average and total for this recipe
      if (mounted) {
        setState(() {
          userRating = rating;
          hasUserRated = true;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted!')),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          hasUserRated = false; // Revert if operation fails
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting rating: $e')),
        );
      }
    }
  }

  // Remove user rating for this specific recipe
  Future<void> _removeRating() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (!mounted) return;

    try {
      await _databaseMethods.removeRating(
          widget.recipeId, user.uid, widget.collectionName);

      await _loadRatingData(); // Reload to update average and total for this recipe
      if (mounted) {
        setState(() {
          userRating = 0;
          hasUserRated = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating removed!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing rating: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: GradientDecoration.linearGradient,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.brown,
              expandedHeight: 300.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Positioned.fill(
                      bottom: -18,
                      child: Image.network(
                        widget.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/img_error.jpg',
                            height: 200,
                            width: 160,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                          .animate(
                            onPlay: (controller) => controller.repeat(),
                          )
                          .moveY(
                            begin: -20,
                            end: 1,
                            duration: 10.seconds,
                            curve: Curves.easeInOut,
                          ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.white : Colors.red,
                    size: 30,
                  ),
                  onPressed: _toggleFavorite,
                ).animate().shake(hz: 4, curve: Curves.easeInOut),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating Section
                    if (isLoadingRatings)
                      Center(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: LoadingIndicator(
                            indicatorType: Indicator.ballClipRotate,
                            colors: [Colors.blue, Colors.green, Colors.red],
                            strokeWidth: 2.0,
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                RatingBar.builder(
                                  initialRating: userRating,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 22, // Larger stars for visibility
                                  itemPadding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: _submitRating,
                                  unratedColor:
                                      const Color.fromARGB(255, 184, 182, 182),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '★ ${averageRating.toStringAsFixed(1)} ($totalRatings ratings)',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ).animate().fadeIn(duration: 500.ms),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (hasUserRated)
                              Center(
                                child: ElevatedButton(
                                  iconAlignment: IconAlignment.start,
                                  onPressed: _removeRating,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Remove Rating',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ).animate().fadeIn(duration: 500.ms),
                              ),
                          ],
                        ),
                      ),
                    // Recipe name
                    AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText(widget.foodname,
                            speed: const Duration(milliseconds: 100),
                            textStyle: AppWidget.Recipe_Title()),
                      ],
                      totalRepeatCount: 1,
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.grey[300],
                    ).animate().fadeIn(duration: 1.seconds),
                    const SizedBox(height: 10),
                    Text(
                      widget.details,
                      style: AppWidget.Details(),
                      textAlign: TextAlign.justify,
                    ).animate().fadeIn(duration: 1.seconds),
                    const SizedBox(height: 20),

                    // Ingredients Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.local_grocery_store_outlined,
                          color: Colors.brown,
                        ).animate().shake(hz: 3, duration: 0.5.seconds),
                        const SizedBox(width: 10),
                        Text(
                          "Ingredients",
                          style: AppWidget.Recipedatatitle(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.ingredients.asMap().entries.map((entry) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text("• ${entry.value}",
                                  textAlign: TextAlign.justify,
                                  style: AppWidget.content()),
                            ).animate().slideX(
                                  begin: -1,
                                  end: 0,
                                  duration: 500.ms,
                                ),
                            if (entry.key != widget.ingredients.length - 1)
                              const SizedBox(height: 9),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 25),

                    // Instructions Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.soup_kitchen_sharp,
                          color: Colors.brown,
                        ).animate().shake(hz: 3, duration: 1.seconds),
                        const SizedBox(width: 10),
                        Text(
                          "Instructions",
                          style: AppWidget.Recipedatatitle(),
                        ),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.recipe.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 1),
                              child: Text(
                                  "• ${index + 1}: ${widget.recipe[index]}",
                                  textAlign: TextAlign.justify,
                                  style: AppWidget.content()),
                            ).animate().fadeIn(
                                  delay: (index * 200).ms,
                                  duration: 500.ms,
                                ),
                            if (index != widget.recipe.length - 1)
                              const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
