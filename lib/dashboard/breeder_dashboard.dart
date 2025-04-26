import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

import 'breeder_profile.dart';

class BreederDashboard extends StatefulWidget {
  const BreederDashboard({super.key});

  @override
  _BreederDashboardState createState() => _BreederDashboardState();
}

class _BreederDashboardState extends State<BreederDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  int _currentIndex = 0;
  bool _isLoading = false;

  List<String> imageUrls = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController breedController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Future<void> uploadImages() async {
    List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      for (var image in images) {
        String? imageUrl = await uploadToCloudinary(image);
        if (imageUrl.isNotEmpty) {
          imageUrls.add(imageUrl);
        }
      }
      setState(() {});
    }
  }

  Future<String> uploadToCloudinary(XFile image) async {
    try {
      String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
      String cloudinaryUrl = "https://api.cloudinary.com/v1_1/$cloudName/raw/upload";
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(image.path, filename: image.name),
        "upload_preset": "flutterpre"
      });

      Response response = await Dio().post(cloudinaryUrl, data: formData);
      return response.data["secure_url"];
    } catch (e) {
      print("Cloudinary upload failed: $e");
      return "";
    }
  }

  Future<void> addPet() async {
    if (nameController.text.isEmpty || breedController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required!"), backgroundColor: Colors.red),
      );
      return;
    }

    if (imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload at least one image!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      String breederId = _auth.currentUser!.uid;
      await _firestore.collection('breeders').doc(breederId).collection('pets').add({
        'name': nameController.text,
        'breedType': breedController.text,
        'description': descriptionController.text,
        'imageUrls': imageUrls,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pet added successfully!"), backgroundColor: Colors.green),
      );

      setState(() {
        nameController.clear();
        breedController.clear();
        descriptionController.clear();
        imageUrls.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: _currentIndex == 0 ? buildDashboard() : BreederProfile(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.orange,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget buildDashboard() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Breeder Dashboard"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Pet Name")),
              TextField(controller: breedController, decoration: InputDecoration(labelText: "Breed Type")),
              TextField(controller: descriptionController, decoration: InputDecoration(labelText: "Description")),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: uploadImages,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text("Upload Images", style: TextStyle(color: Colors.white)),
              ),
              Wrap(children: imageUrls.map((url) => Image.network(url, width: 50)).toList()),
              ElevatedButton(
                onPressed: _isLoading ? null : addPet,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Add Pet", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
