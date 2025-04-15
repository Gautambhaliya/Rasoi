import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe/viwe/widget/gradient_decoration.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Container(
          decoration: GradientDecoration.linearGradient,
          child: Center(
            child: Text(
              "Please log in to view your favorites.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites',
            style: TextStyle(color: Colors.white, fontSize: 17)),
        backgroundColor: Colors.brown,
        elevation: 10,
        centerTitle: true,
      ),
      body: Container(
        decoration: GradientDecoration.linearGradient,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('Favorites')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No favorites added yet.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final favorite = snapshot.data!.docs[index];
                return Dismissible(
                  key: Key(favorite.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  onDismissed: (direction) {
                    _removeFavorite(user.uid, favorite.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('${favorite['name']} removed from favorites'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to the RecipeDetailPage with recipe details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailPage(
                            recipeId: favorite.id,
                            recipeName: favorite['name'],
                            recipeImage: favorite['image'],
                            ingredients: List<String>.from(
                                favorite['ingredients'] ??
                                    []), // Handle missing field

                            recipe: List<String>.from(favorite['recipe'] ??
                                []), // Handle missing field
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            favorite['image'],
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          favorite['name'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _removeFavorite(user.uid, favorite.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${favorite['name']} removed from favorites'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _removeFavorite(String userId, String favoriteId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Favorites')
        .doc(favoriteId)
        .delete();
  }
}

// RecipeDetailPage with Ingredients and Instructions
class RecipeDetailPage extends StatelessWidget {
  final String recipeId;
  final String recipeName;
  final String recipeImage;
  final List<String> ingredients;
  final List<String> recipe;

  RecipeDetailPage({
    required this.recipeId,
    required this.recipeName,
    required this.recipeImage,
    required this.ingredients,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipeName),
        backgroundColor: Colors.brown,
        elevation: 10,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                recipeImage,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),

            // Recipe Name
            Text(
              recipeName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            // Ingredients
            Text(
              "Ingredients:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ingredients
                  .map((ingredient) => Text(
                        "• $ingredient",
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),

            // Instructions
            Text(
              "Instructions:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recipe
                  .map((recipe) => Text(
                        "• $recipe",
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
