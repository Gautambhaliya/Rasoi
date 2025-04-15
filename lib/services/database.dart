import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future Addrecipe(Map<String, dynamic> addrecipe) async {
    try {
      return await FirebaseFirestore.instance
          .collection("Recipes")
          .add(addrecipe);
    } catch (e) {
      throw Exception('Error adding recipe: $e');
    }
  }

  Future<void> updateRecipe(
      String recipeId, Map<String, dynamic> recipeData) async {
    await FirebaseFirestore.instance
        .collection('Recipes')
        .doc(recipeId)
        .update(recipeData);
  }

  Future<Stream<QuerySnapshot>> getallRecipe() async {
    try {
      return await FirebaseFirestore.instance
          .collection("Recipes")
          .orderBy("Name", descending: false)
          .snapshots();
    } catch (e) {
      throw Exception('Error fetching all recipes: $e');
    }
  }

  Stream<QuerySnapshot> getCategoryRecipe(String category) {
    try {
      return FirebaseFirestore.instance
          .collection('Recipes')
          .where('Category', isEqualTo: category)
          .snapshots();
    } catch (e) {
      throw Stream.error('Error fetching category recipes: $e');
    }
  }

  Future<QuerySnapshot> searchRecipes(String query) async {
    try {
      return await FirebaseFirestore.instance
          .collection('Recipes')
          .where('Name', isGreaterThanOrEqualTo: query)
          .where('Name', isLessThan: '${query}z')
          .orderBy("Name")
          .get();
    } catch (e) {
      throw Exception('Error searching recipes: $e');
    }
  }

  // Admin recipes
  Future AdminRecipes(Map<String, dynamic> addadminrecipe) async {
    try {
      return await FirebaseFirestore.instance
          .collection("AdminRecipes")
          .add(addadminrecipe);
    } catch (e) {
      throw Exception('Error adding admin recipe: $e');
    }
  }

  Future<Stream<QuerySnapshot>> getalladminRecipe() async {
    try {
      return await FirebaseFirestore.instance
          .collection("AdminRecipes")
          .orderBy("Name", descending: false)
          .snapshots();
    } catch (e) {
      throw Exception('Error fetching all admin recipes: $e');
    }
  }

  Stream<QuerySnapshot> getAdminCategoryRecipe(String admincategory) {
    try {
      return FirebaseFirestore.instance
          .collection('AdminRecipes')
          .where('Category', isEqualTo: admincategory)
          .snapshots();
    } catch (e) {
      throw Stream.error('Error fetching admin category recipes: $e');
    }
  }

  Future<QuerySnapshot> searchadminRecipes(String query) async {
    try {
      return await FirebaseFirestore.instance
          .collection('AdminRecipes')
          .where('Name', isGreaterThanOrEqualTo: query)
          .where('Name', isLessThan: '${query}z')
          .orderBy("Name")
          .get();
    } catch (e) {
      throw Exception('Error searching admin recipes: $e');
    }
  }

  // Rating methods for recipes (updated to support both Recipes and AdminRecipes)
  Future<void> submitRating(String recipeId, double rating, String userId,
      String collectionName) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(recipeId)
          .collection('ratings')
          .doc(userId)
          .set({
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error submitting rating: $e');
    }
  }

  Future<void> removeRating(
      String recipeId, String userId, String collectionName) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(recipeId)
          .collection('ratings')
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Error removing rating: $e');
    }
  }

  Future<Map<String, dynamic>> getRecipeRatings(
      String recipeId, String collectionName) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(recipeId)
          .collection('ratings')
          .get();

      double totalRating = 0;
      int ratingCount = snapshot.docs.length;

      for (var doc in snapshot.docs) {
        totalRating += doc['rating'] as double;
      }

      double averageRating = ratingCount > 0 ? totalRating / ratingCount : 0;
      return {
        'averageRating': averageRating,
        'totalRatings': ratingCount,
      };
    } catch (e) {
      throw Exception('Error fetching recipe ratings: $e');
    }
  }

  Future<double?> getUserRating(
      String recipeId, String userId, String collectionName) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(recipeId)
          .collection('ratings')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc['rating'] as double?;
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user rating: $e');
    }
  }
}
