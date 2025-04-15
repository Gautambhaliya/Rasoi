import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe/viwe/widget/gradient_decoration.dart';
import 'package:recipe/viwe/Screen/add_recipe.dart'; // Import AddRecipe

class MyRecipesPage extends StatefulWidget {
  @override
  _MyRecipesPageState createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends State<MyRecipesPage> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Container(
          decoration: GradientDecoration.linearGradient,
          child: Center(
            child: Text(
              "Please log in to view your recipes.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Recipes',
              style: TextStyle(color: Colors.white, fontSize: 17)),
          backgroundColor: Colors.brown,
          elevation: 10,
          centerTitle: true,
        ),
        body: Container(
            decoration: GradientDecoration.linearGradient,
            child: _buildRecipeList(user)),
      ),
    );
  }

  Widget _buildRecipeList(User user) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Recipes')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No recipes added yet.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final recipe = snapshot.data!.docs[index];
            final data = recipe.data() as Map<String, dynamic>;

            return _buildRecipeItem(context, recipe.id, data);
          },
        );
      },
    );
  }

  Widget _buildRecipeItem(
      BuildContext context, String recipeId, Map<String, dynamic> data) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: _buildRecipeImage(data['ImageUrl']),
        title: Text(
          data['Name'] ?? 'Untitled Recipe',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editRecipe(context, recipeId, data),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteRecipe(recipeId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeImage(String? imageUrl) {
    return SizedBox(
      height: 50,
      width: 50,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl ?? '',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 50,
              height: 50,
              color: Colors.grey[200],
              child: Icon(Icons.broken_image, color: Colors.grey[500]),
            );
          },
        ),
      ),
    );
  }

  Future<void> _deleteRecipeFromFavorites(String recipeId) async {
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      for (final userDoc in usersSnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.id)
            .collection('Favorites')
            .doc(recipeId)
            .delete();
      }
    } catch (e) {
      print('Error deleting from favorites: $e');
    }
  }

  Future<void> _deleteRecipe(String recipeId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Recipes')
          .doc(recipeId)
          .delete();
      await _deleteRecipeFromFavorites(recipeId);
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Recipe deleted successfully')),
      );
    } catch (e) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _editRecipe(
      BuildContext context, String recipeId, Map<String, dynamic> recipeData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRecipe(
          recipeId: recipeId,
          recipeData: recipeData,
        ),
      ),
    );
  }
}
