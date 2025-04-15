import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:recipe/viwe/widget/gradient_decoration.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // Cloudinary API Details (Replace with yours)
  final String cloudinaryUrl =
      "https://api.cloudinary.com/v1_1/dfzquxf4w/image/upload";
  final String uploadPreset = "user_image"; // Set this in Cloudinary Settings

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (doc.exists) {
        setState(() {
          userData = doc.data() as Map<String, dynamic>;
        });
      }
    }
  }

  Future<void> _uploadImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() => _isUploading = true);

      // Convert Image to Multipart File
      var request = http.MultipartRequest("POST", Uri.parse(cloudinaryUrl))
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath("file", image.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        String imageUrl = jsonData['secure_url'];

        // Update Firestore with Cloudinary Image URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'profileImage': imageUrl});

        setState(() {
          userData!['profileImage'] = imageUrl;
          _isUploading = false;
        });
      } else {
        throw Exception("Failed to upload image to Cloudinary");
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  void _editProfile() {
    TextEditingController nameController =
        TextEditingController(text: userData?['name']);
    TextEditingController phoneController =
        TextEditingController(text: userData?['phone']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Edit Profile",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String newName = nameController.text;
                  String newPhone = phoneController.text;

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .update({'name': newName, 'phone': newPhone});

                  fetchUserData(); // Refresh UI
                  Navigator.pop(context);
                },
                child: Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color.fromARGB(255, 139, 98, 83), Colors.brown],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            }),
        actions: [
          if (user != null)
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.white,
              ),
              onPressed: _editProfile, // Open Edit Profile Dialog
            ),
        ],
      ),
      body: Container(
        decoration: GradientDecoration.linearGradient,
        child: _isUploading
            ? Center(child: CircularProgressIndicator())
            : user == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Guest",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: Icon(Icons.login),
                          label: Text("Login"),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context)
                            .size
                            .height, // Full screen height
                      ),
                      child: Column(
                        children: [
                          _buildProfileImage(),
                          SizedBox(height: 24),
                          Text(
                            userData?['name'] ?? 'No Name',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 176, 39, 39),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            userData?['email'] ?? 'No Email',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color.from(
                                  alpha: 1, red: 0, green: 0, blue: 0),
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildInfoCard(
                            'Phone Number',
                            userData?['phone'] ?? 'Not provided',
                            Icons.phone,
                          ),
                          SizedBox(height: 16),
                          _buildInfoCard(
                            'Joined Date',
                            userData?['joinDate'] != null
                                ? "Member since ${userData!['joinDate'].toDate().toLocal().toString().split(' ')[0]}"
                                : "N/A",
                            Icons.calendar_today,
                          ),
                          SizedBox(height: 30),
                          ElevatedButton.icon(
                            icon: Icon(Icons.logout),
                            label: Text("Sign Out"),
                            onPressed: () async {
                              await FirebaseAuth.instance
                                  .signOut(); // Sign out user
                              Navigator.pushReplacementNamed(context,
                                  '/login'); // Redirect to Login Screen
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: 60,
          backgroundImage: userData?['profileImage'] != null
              ? NetworkImage(userData?['profileImage'] ?? '')
              : AssetImage('assets/images/user.png') as ImageProvider,
        ),
        if (user != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.camera_alt,
                  color: Color.fromARGB(255, 238, 141, 14)),
              onPressed: () => _uploadImage(ImageSource.gallery),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      color: const Color.fromARGB(255, 248, 243, 243),
      elevation: 30,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title, style: TextStyle(color: Colors.grey, fontSize: 12)),
        subtitle: Text(value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
