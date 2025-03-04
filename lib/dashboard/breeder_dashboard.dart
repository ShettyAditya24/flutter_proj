import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BreederDashboard extends StatefulWidget {
  const BreederDashboard({super.key});

  @override
  _BreederDashboardState createState() => _BreederDashboardState();
}

class _BreederDashboardState extends State<BreederDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  List<String> imageUrls = [];
  bool _isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController breedController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Future<void> uploadImages() async {
    print("Upload Images button clicked");
    List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      print("Selected images: ${images.length}");
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
      if (cloudName.isEmpty) {
        print("Cloudinary cloud name is not set in .env file");
        return "";
      }

      String cloudinaryUrl = "https://api.cloudinary.com/v1_1/$cloudName/raw/upload";
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(image.path, filename: image.name),
        "upload_preset": "flutterpre"
      });

      print("Uploading to Cloudinary: ${image.name}");
      Response response = await Dio().post(cloudinaryUrl, data: formData);
      print("Upload successful: ${response.data["secure_url"]}");
      return response.data["secure_url"];
    } catch (e) {
      print("Cloudinary upload failed: $e");
      return "";
    }
  }

  Future<void> addPet() async {
    print("Add Pet button clicked");
    if (nameController.text.isEmpty || breedController.text.isEmpty || descriptionController.text.isEmpty) {
      print("Validation failed: All fields are required");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required!"), backgroundColor: Colors.red),
      );
      return;
    }

    if (imageUrls.isEmpty) {
      print("Validation failed: No images uploaded");
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
      print("Pet added successfully to Firestore");
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
      print("Error adding pet: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Breeder Dashboard"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
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
    );
  }
}
