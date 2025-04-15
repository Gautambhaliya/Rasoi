import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe/viwe/Screen/home_Screen.dart';
import '/services/cloudinary_services.dart';
import '/services/database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminRecipes extends StatefulWidget {
  const AdminRecipes({super.key});

  @override
  State<AdminRecipes> createState() => _AdminRecipesState();
}

class _AdminRecipesState extends State<AdminRecipes> {
  File? selectedImage;
  TextEditingController nameController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  TextEditingController ingredientsController = TextEditingController();
  // TextEditingController prepTimeController = TextEditingController();
  TextEditingController instructionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  List<String> ingredientsList = [];
  List<String> cookingInstructions = [];
  String? selectedCategory;
  User? user = FirebaseAuth.instance.currentUser;

  int? selectedIngredientIndex;
  int? selectedInstructionIndex;

  Future<void> getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void addIngredient() {
    if (ingredientsController.text.isNotEmpty) {
      setState(() {
        if (selectedIngredientIndex != null) {
          ingredientsList[selectedIngredientIndex!] =
              ingredientsController.text;
          selectedIngredientIndex = null;
        } else {
          ingredientsList.add(ingredientsController.text);
        }
        ingredientsController.clear();
      });
    }
  }

  void addInstruction() {
    if (instructionController.text.isNotEmpty) {
      if (instructionController.text.length > 20000) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Please enter the text in a good format (keep it concise).")),
        );
      } else {
        setState(() {
          if (selectedInstructionIndex != null) {
            cookingInstructions[selectedInstructionIndex!] =
                instructionController.text;
            selectedInstructionIndex = null;
          } else {
            cookingInstructions.add(instructionController.text);
          }
          instructionController.clear();
        });
      }
    }
  }

  void removeIngredient(int index) {
    setState(() {
      ingredientsList.removeAt(index);
    });
  }

  void removeInstruction(int index) {
    setState(() {
      cookingInstructions.removeAt(index);
    });
  }

  Future<void> uploadItem() async {
    if (nameController.text.isEmpty ||
        detailController.text.isEmpty ||
        ingredientsList.isEmpty ||
        // prepTimeController.text.isEmpty ||
        selectedCategory == null ||
        selectedImage == null ||
        cookingInstructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Please fill all fields, add ingredients, add instructions, and select an image")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    String? imageUrl = await CloudinaryService.uploadImage(selectedImage!);
    if (imageUrl != null) {
      Map<String, dynamic> recipeData = {
        "Name": nameController.text,
        "Detail": detailController.text,
        "Ingredients": ingredientsList,
        // "PreparationTime": prepTimeController.text,
        "Category": selectedCategory,
        "CookingInstructions": cookingInstructions,
        "ImageUrl": imageUrl,
        "Timestamp": DateTime.now(),
        'userId': user?.uid, // 🔹 Store User ID
      };

      await DatabaseMethods().AdminRecipes(recipeData);
      Fluttertoast.showToast(
          msg: "Recipe Saved Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(255, 6, 92, 221),
          textColor: Colors.white,
          fontSize: 16.0);

      setState(() {
        nameController.clear();
        detailController.clear();
        ingredientsController.clear();
        // prepTimeController.clear();
        instructionController.clear();
        ingredientsList.clear();
        cookingInstructions.clear();
        selectedImage = null;
        selectedCategory = null;
        _isUploading = false;
      });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Recipe added successfully!")),
      // );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image upload failed!")),
      );
      setState(() {
        _isUploading = false;
      });
    }
  }

  // @override
  // void dispose() {
  //   if (mounted) {
  //     // ✅ Ensure widget is still active
  //     dispose();
  //   }
  //   super.dispose();
  // }
  // @override
  // void dispose() {
  //   nameController.dispose();
  //   detailController.dispose();
  //   ingredientsController.dispose();
  //   prepTimeController.dispose();
  //   instructionController.dispose();
  //   super.dispose();
  // }

  List<String> splitTextIntoLines(String text, double width) {
    List<String> lines = [];
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: 16)),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: width);

    String line = '';
    for (int i = 0; i < text.length; i++) {
      line += text[i];
      textPainter.text = TextSpan(text: line, style: TextStyle(fontSize: 16));
      textPainter.layout(maxWidth: width);

      if (textPainter.didExceedMaxLines) {
        lines.add(line.trim());
        line = '';
      }
    }

    if (line.isNotEmpty) {
      lines.add(line.trim());
    }

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width - 40;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            "Add Recipe",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Home()), // Navigate back to the home page
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: getImage,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(Icons.camera_alt_outlined, size: 50),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text("Recipe Name",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Enter Recipe Name",
                  ),
                ),
                SizedBox(height: 20),
                Text("Recipe Details",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextField(
                  controller: detailController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Enter Recipe Details",
                  ),
                ),
                SizedBox(height: 20),
                Text("Ingredients",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextField(
                  controller: ingredientsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Enter Ingredient",
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: addIngredient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    selectedIngredientIndex != null
                        ? "Update Ingredient"
                        : "Add Ingredient",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ingredientsList.asMap().entries.map((entry) {
                    int index = entry.key;
                    String ingredient = entry.value;
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text("• $ingredient"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                setState(() {
                                  ingredientsController.text = ingredient;
                                  selectedIngredientIndex = index;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                removeIngredient(index);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                // Text("Preparation Time",
                //     style:
                //         TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                // TextField(
                //   controller: prepTimeController,
                //   decoration: InputDecoration(
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     hintText: "Enter Preparation Time",
                //   ),
                // ),
                // SizedBox(height: 20),
                Text("Category",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      padding: EdgeInsets.only(left: 10),
                      isExpanded: true,
                      value: selectedCategory,
                      hint: Text("Select Recipe Category"),
                      onChanged: (String? newCategory) {
                        setState(() {
                          selectedCategory = newCategory;
                        });
                      },
                      items: <String>[
                        'Gujarati',
                        'Panjabi',
                        'South Indian',
                        'Fastfood',
                        'Snacks'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text("Cooking Instructions",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextField(
                  controller: instructionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Enter Cooking Instructions",
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: addInstruction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    selectedInstructionIndex != null
                        ? "Update Instruction"
                        : "Add Instruction",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cookingInstructions.asMap().entries.map((entry) {
                    int index = entry.key;
                    String instruction = entry.value;

                    List<String> lines =
                        splitTextIntoLines(instruction, screenWidth);

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var line in lines)
                              Text("• $line", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                setState(() {
                                  instructionController.text = instruction;
                                  selectedInstructionIndex = index;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                removeInstruction(index);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 30),
                _isUploading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(500, 60),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 8.0,
                        ),
                        onPressed: uploadItem,
                        child: Text(
                          "Save Recipe",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
