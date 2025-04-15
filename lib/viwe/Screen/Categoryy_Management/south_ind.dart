import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipe/viwe/widget/support_widget.dart';
import 'package:rxdart/rxdart.dart';
import 'package:recipe/services/database.dart';
import 'package:recipe/viwe/Screen/resepice_data.dart';

// ignore: must_be_immutable
class SouthInd extends StatefulWidget {
  String category = 'South Indian';
  String admincategory = 'South Indian';

  SouthInd({super.key});

  @override
  State<SouthInd> createState() => _SouthIndState();
}

class _SouthIndState extends State<SouthInd> {
  Stream<List<DocumentSnapshot>>? recipeStream;

  void getAllRecipes() {
    Stream<QuerySnapshot> userRecipesStream =
        DatabaseMethods().getCategoryRecipe(widget.category);
    Stream<QuerySnapshot> adminRecipesStream =
        DatabaseMethods().getAdminCategoryRecipe(widget.admincategory);

    recipeStream = Rx.combineLatest2(
      userRecipesStream.map((snapshot) => snapshot.docs),
      adminRecipesStream.map((snapshot) => snapshot.docs),
      (List<DocumentSnapshot> userDocs, List<DocumentSnapshot> adminDocs) {
        List<DocumentSnapshot> allRecipes = [...userDocs, ...adminDocs];
        allRecipes.sort((a, b) => a["Name"]
            .toString()
            .compareTo(b["Name"].toString())); // Alphabet sorting
        return allRecipes;
      },
    );
  }

  @override
  void initState() {
    getAllRecipes();
    super.initState();
  }

  Widget allRecipe(Stream<List<DocumentSnapshot>>? recipeStream) {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: recipeStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        List<DocumentSnapshot> allRecipes = snapshot.data!;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1),
            child: Row(
              children: allRecipes.map((recipe) {
                String collectionName =
                    recipe.reference.parent.parent?.id == 'Recipes'
                        ? 'Recipes'
                        : 'AdminRecipes';
                return Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: recipeCard(recipe, collectionName),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget recipeCard(DocumentSnapshot ds, String collectionName) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Recipe(
              foodname: ds["Name"] ?? "Unnamed Recipe",
              image: ds["ImageUrl"] ?? 'assets/images/img_error.jpg',
              recipe: List<String>.from(ds["CookingInstructions"] ?? []),
              details: ds["Detail"] ?? "",
              ingredients: List<String>.from(ds["Ingredients"] ?? []),
              recipeId: ds.id,
              collectionName: collectionName,
            ),
          ),
        );
      },
      child: Container(
        width: 145,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              child: Image.network(
                ds["ImageUrl"] ?? 'assets/images/img_error.jpg',
                height: 170,
                width: 170,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/img_error.jpg',
                    height: 170,
                    width: 170,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                (ds["Name"] != null && ds["Name"].toString().length > 20)
                    ? '${ds["Name"].toString().substring(0, 20)}...'
                    : (ds["Name"]?.toString() ?? "Unnamed Recipe"),
                overflow: TextOverflow.ellipsis,
                style: AppWidget.boldfeidtextstyle(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Expanded(
              child: allRecipe(recipeStream),
            ),
          ],
        ),
      ),
    );
  }
}
