import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:recipe/services/database.dart';
import 'package:recipe/viwe/Screen/Categoryy_Management/Fastfood.dart';
import 'package:recipe/viwe/Screen/Categoryy_Management/Guj.dart';
import 'package:recipe/viwe/Screen/Categoryy_Management/snack.dart';
import 'package:recipe/viwe/Screen/Categoryy_Management/south_ind.dart';
import 'package:recipe/viwe/Screen/add_recipe.dart';
import 'package:recipe/viwe/Screen/favorites_Screen.dart';
import 'package:recipe/viwe/Screen/user_recipe.dart';
import 'package:recipe/viwe/Screen/profile.dart';
import 'package:recipe/viwe/Screen/resepice_data.dart';
import 'package:recipe/viwe/widget/Categorydetails.dart';
import 'package:recipe/viwe/widget/category_mang.dart';
import 'package:recipe/viwe/widget/gradient_decoration.dart';
import 'package:recipe/viwe/widget/support_widget.dart';
import 'Categoryy_Management/panj.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  bool _hasInternet = true; // Moved to _HomeState for top-level control
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    HomeScreen(),
    FavoritesPage(),
    MyRecipesPage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _listenToConnectivityChanges();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkInitialConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _hasInternet = connectivityResult != ConnectivityResult.none;
      });
    }
  }

  void _listenToConnectivityChanges() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (mounted) {
        setState(() {
          _hasInternet =
              results.isNotEmpty && !results.contains(ConnectivityResult.none);
        });
      }
    });
  }

  Widget _noInternetWidget() {
    return Container(
      decoration: GradientDecoration.linearGradient,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              "No Internet Connection",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'roboto',
                  backgroundColor: Colors.transparent),
            ),
            const SizedBox(height: 10),
            const Text(
              "Please enable your internet connection.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey, fontFamily: 'roboto'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasInternet) {
      return _noInternetWidget(); // Show only the no-internet screen
    }

    return Container(
      decoration: GradientDecoration.linearGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.amber,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddRecipe()),
            );
          },
          child: const Icon(Icons.add),
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: CrystalNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          outlineBorderColor: const Color.fromARGB(185, 0, 0, 0),
          items: [
            CrystalNavigationBarItem(
              icon: Icons.home,
              selectedColor: Colors.blue,
            ),
            CrystalNavigationBarItem(
              icon: Icons.favorite,
              selectedColor: Colors.red,
            ),
            CrystalNavigationBarItem(
              icon: Icons.paste,
              selectedColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  Stream? recipeStream;
  String? profileImageUrl;
  bool search = false;
  var queryResultSet = [];
  var tempSearchStore = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    await Future.wait([
      getontheload(),
      fetchUserProfileImage(),
    ]);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getontheload() async {
    recipeStream = await DatabaseMethods().getallRecipe();
  }

  Future<void> fetchUserProfileImage() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists && userDoc.data()!.containsKey('profileImage')) {
          if (mounted) {
            setState(() {
              profileImageUrl = userDoc['profileImage'];
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching profile image: $e");
    }
  }

  void initiateSearch(String value) async {
    if (value.isEmpty) {
      if (mounted) {
        setState(() {
          queryResultSet = [];
          tempSearchStore = [];
          search = false;
          isSearching = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        search = true;
        isSearching = true;
      });
    }

    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);

    try {
      QuerySnapshot userRecipesSnapshot =
          await DatabaseMethods().searchRecipes(capitalizedValue);
      QuerySnapshot adminRecipesSnapshot =
          await DatabaseMethods().searchadminRecipes(capitalizedValue);

      List<DocumentSnapshot> userRecipes = userRecipesSnapshot.docs;
      List<DocumentSnapshot> adminRecipes = adminRecipesSnapshot.docs;

      if (mounted) {
        setState(() {
          queryResultSet = [...userRecipes, ...adminRecipes];
          tempSearchStore = queryResultSet;
          isSearching = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching search results: $e");
      if (mounted) {
        setState(() {
          isSearching = false;
        });
      }
    }
  }

  Widget buildResultCard(DocumentSnapshot ds) {
    var data = ds.data() as Map<String, dynamic>;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Recipe(
              foodname: data["Name"],
              image: data["ImageUrl"],
              recipe: data["CookingInstructions"],
              details: data["Detail"],
              ingredients: List<String>.from(data["Ingredients"]),
              recipeId: ds.id,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.network(
                    data["ImageUrl"] ?? 'assets/images/img_error.jpg',
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/img_error.jpg',
                        height: 35,
                        width: 35,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20.0),
                Container(
                  padding: const EdgeInsets.only(right: 2),
                  child: Text(
                      (data["Name"] != null && data["Name"]!.length > 20)
                          ? '${data["Name"]!.substring(0, 20)}...'
                          : (data["Name"] ?? "Unnamed Recipe"),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget allRecipe() {
    return StreamBuilder(
      stream: recipeStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data.docs.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
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
                      recipeId: ds.id,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        ds["ImageUrl"],
                        height: 135,
                        width: 105,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/img_error.jpg',
                            height: 135,
                            width: 105,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      (ds["Name"] != null && ds["Name"]!.length > 20)
                          ? '${ds["Name"]!.substring(0, 20)}...'
                          : (ds["Name"] ?? "Unnamed Recipe"),
                      overflow: TextOverflow.ellipsis,
                      style: AppWidget.boldfeidtextstyle(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: GradientDecoration.linearGradient,
        child: SafeArea(
          child: isLoading
              ? Center(
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
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Looking For Your\nfavourite Meal",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePage()),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black54,
                                      width: 1.5,
                                    )),
                                child: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  radius: 18.5,
                                  backgroundImage: profileImageUrl != null
                                      ? NetworkImage(profileImageUrl!)
                                      : const AssetImage(
                                              'assets/images/user.png')
                                          as ImageProvider,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.only(left: 21.0, top: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              initiateSearch(value);
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              suffixIcon: Icon(Icons.search),
                              hintText: "Search Recipes...",
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        search
                            ? (isSearching
                                ? Center(
                                    child: Text(
                                      "Please Wait...",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : (queryResultSet.isNotEmpty
                                    ? ListView(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 10.0),
                                        primary: false,
                                        shrinkWrap: true,
                                        children:
                                            tempSearchStore.map((element) {
                                          return buildResultCard(element);
                                        }).toList(),
                                      )
                                    : Center(
                                        child: Text(
                                          "No Recipe Found",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Categories",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 120,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CategoryRecipe(
                                                  category: 'Gujarati',
                                                ),
                                              ),
                                            );
                                          },
                                          child: CategoryItem('Gujarati',
                                              'assets/images/Jalebi.jpg'),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CategoryRecipe(
                                                  category: 'Panjabi',
                                                ),
                                              ),
                                            );
                                          },
                                          child: CategoryItem('Panjabi',
                                              'assets/images/panjabithali.jpg'),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CategoryRecipe(
                                                  category: 'South Indian',
                                                ),
                                              ),
                                            );
                                          },
                                          child: CategoryItem('South Indian',
                                              'assets/images/southindianthali.jpg'),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CategoryRecipe(
                                                  category: 'Fastfood',
                                                ),
                                              ),
                                            );
                                          },
                                          child: CategoryItem('Fastfood',
                                              'assets/images/fastfood.jpg'),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CategoryRecipe(
                                                  category: 'Snacks',
                                                ),
                                              ),
                                            );
                                          },
                                          child: CategoryItem('Snacks',
                                              'assets/images/Snack.jpg'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 13),
                                  Text(
                                    "Popular Recipes",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  SizedBox(height: 10),
                                  SizedBox(
                                    height: 210,
                                    child: allRecipe(),
                                  ),
                                  SizedBox(height: 2),
                                  Text("Gujarati",
                                      style: AppWidget.mainrecipenametitle()),
                                  SizedBox(height: 10),
                                  SizedBox(
                                    height: 250,
                                    child: Gujrati(),
                                  ),
                                  SizedBox(height: 10),
                                  Text("Panjabi",
                                      style: AppWidget.mainrecipenametitle()),
                                  SizedBox(height: 10),
                                  SizedBox(
                                    height: 250,
                                    child: Panj(),
                                  ),
                                  SizedBox(height: 20),
                                  Text("South Indian",
                                      style: AppWidget.mainrecipenametitle()),
                                  SizedBox(height: 10),
                                  SizedBox(
                                    height: 250,
                                    child: SouthInd(),
                                  ),
                                  SizedBox(height: 10),
                                  Text("Fast Food",
                                      style: AppWidget.mainrecipenametitle()),
                                  SizedBox(height: 10),
                                  SizedBox(
                                    height: 250,
                                    child: Fastfood(),
                                  ),
                                  SizedBox(height: 10),
                                  Text("Snacks",
                                      style: AppWidget.mainrecipenametitle()),
                                  SizedBox(height: 10),
                                  SizedBox(
                                    height: 250,
                                    child: Snack(),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
