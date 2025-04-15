import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recipe/services/database.dart';
import 'package:recipe/viwe/Screen/resepice_data.dart';
import 'package:recipe/viwe/widget/gradient_decoration.dart';
import 'package:rxdart/rxdart.dart';
// import 'package:recipe/viwe/widget/support_widget.dart';

// ignore: must_be_immutable
class CategoryRecipe extends StatefulWidget {
  String category;
  CategoryRecipe({super.key, required this.category});

  @override
  State<CategoryRecipe> createState() => _CategoryRecipeState();
}

class _CategoryRecipeState extends State<CategoryRecipe> {
  Stream<List<DocumentSnapshot>>? categoryStream;

  // Fetch both user and admin recipes
  getontheload() async {
    // Get user recipes
    Stream<QuerySnapshot> userRecipesStream =
        await DatabaseMethods().getCategoryRecipe(widget.category);
    // Get admin recipes
    Stream<QuerySnapshot> adminRecipesStream =
        await DatabaseMethods().getAdminCategoryRecipe(widget.category);

    setState(() {
      categoryStream = Rx.combineLatest2(
        userRecipesStream.map((snapshot) => snapshot.docs),
        adminRecipesStream.map((snapshot) => snapshot.docs),
        (List<DocumentSnapshot> userDocs, List<DocumentSnapshot> adminDocs) {
          List<DocumentSnapshot> allRecipes = [...userDocs, ...adminDocs];
          return allRecipes; // Combine both lists
        },
      );
    });
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  // Same code as before to display the recipes
  Widget allRecipe() {
    return Container(
      decoration: GradientDecoration.linearGradient,
      child: StreamBuilder(
        stream: categoryStream,
        builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> allRecipes = snapshot.data!;

          if (allRecipes.isEmpty) {
            return Center(child: Text("No recipe in this field"));
          }

          return GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              mainAxisSpacing: 1.0,
              crossAxisSpacing: 8.0,
            ),
            itemCount: allRecipes.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = allRecipes[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Recipe(
                        foodname: ds["Name"],
                        image: ds["ImageUrl"],
                        recipe: ds["CookingInstructions"],
                        details: ds["Detail"],
                        ingredients: List<String>.from(ds["Ingredients"]),
                        recipeId: 'recipe.id',
                      ),
                    ),
                  );
                },
                child: Container(
                  // decoration: GradientDecoration.linearGradient,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          ds["ImageUrl"],
                          height: 235,
                          width: 170,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/img_error.jpg',
                              height: 235,
                              width: 170,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        ds["Name"],
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
        ),
        backgroundColor: Colors.brown,
        elevation: 15,
        centerTitle: true,
        shadowColor: Colors.grey,
        title: Text(
          widget.category, // Access widget.category here
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10.0),
        child: Column(
          children: [
            Expanded(child: allRecipe()), // Display recipes
          ],
        ),
      ),
    );
  }
}
