import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class FoodSupplierDashboard extends StatefulWidget {
  const FoodSupplierDashboard({super.key, User? user});

  @override
  _FoodSupplierDashboardState createState() => _FoodSupplierDashboardState();
}

class _FoodSupplierDashboardState extends State<FoodSupplierDashboard> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final picker = ImagePicker();
  List<File> _images = [];
  List<String> _imageUrls = [];
  bool _isUploading = false;
  int _selectedIndex = 0;

  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _pickImages() async {
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _uploadImagesToCloudinary() async {
    if (_images.isEmpty) {
      _showSnackbar("Please select images first.", Colors.red);
      return;
    }

    setState(() => _isUploading = true);
    _imageUrls.clear();

    String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    String uploadUrl = "https://api.cloudinary.com/v1_1/$cloudName/raw/upload";
    String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

    for (var image in _images) {
      var request = http.MultipartRequest("POST", Uri.parse(uploadUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(await response.stream.bytesToString());
        _imageUrls.add(jsonResponse['secure_url']);
      } else {
        _showSnackbar("Some images failed to upload!", Colors.red);
      }
    }

    if (_imageUrls.isNotEmpty) {
      _addProduct();
    }
    setState(() => _isUploading = false);
  }

  void _addProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _imageUrls.isEmpty) {
      _showSnackbar("All fields are required!", Colors.red);
      return;
    }

    DocumentReference productRef = _firestore.collection("products").doc();
    await productRef.set({
      "id": productRef.id,
      "name": _nameController.text.trim(),
      "price": _priceController.text.trim(),
      "imageUrls": _imageUrls,
      "timestamp": FieldValue.serverTimestamp(),
    });

    _nameController.clear();
    _priceController.clear();
    setState(() {
      _images = [];
      _imageUrls = [];
    });
    _showSnackbar("Product added successfully!", Colors.green);
  }

  void _deleteProduct(String productId) async {
    await _firestore.collection("products").doc(productId).delete();
    _showSnackbar("Product deleted successfully!", Colors.green);
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _fetchProfileData() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var doc = await _firestore.collection("foodSuppliers").doc(user.uid).get();
      if (doc.exists) {
        var data = doc.data()!;
        _businessNameController.text = data['businessName'] ?? '';
        _addressController.text = data['address'] ?? '';
        _mobileController.text = data['mobile'] ?? '';
      }
    }
  }

  void _saveProfileData() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection("foodSuppliers").doc(user.uid).set({
        'businessName': _businessNameController.text.trim(),
        'address': _addressController.text.trim(),
        'mobile': _mobileController.text.trim(),
      }, SetOptions(merge: true));
      _showSnackbar("Profile updated!", Colors.green);
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pop();
  }

  Widget _buildDashboard() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(controller: _nameController, decoration: InputDecoration(labelText: "Product Name")),
          TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Price")),
          SizedBox(height: 10),
          _images.isEmpty
              ? Text("No Images Selected")
              : SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.file(_images[index], height: 100),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _pickImages,
            child: Text("Pick Images"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
          ElevatedButton(
            onPressed: _isUploading ? null : _uploadImagesToCloudinary,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: _isUploading ? CircularProgressIndicator(color: Colors.white) : Text("Add Product"),
          ),
          SizedBox(height: 20),
          Expanded(
            child: StreamBuilder(
              stream: _firestore.collection("products").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                var products = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    var product = products[index];
                    List<dynamic> imageUrls = product["imageUrls"];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: imageUrls.isNotEmpty ? Image.network(imageUrls[0], height: 50, width: 50, fit: BoxFit.cover) : Icon(Icons.image, size: 50),
                        title: Text(product["name"]),
                        subtitle: Text("₹${product["price"]}"),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProduct(product.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(controller: _businessNameController, decoration: InputDecoration(labelText: "Business Name")),
          TextField(controller: _addressController, decoration: InputDecoration(labelText: "Address")),
          TextField(controller: _mobileController, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: "Mobile")),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveProfileData,
            child: Text("Save"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
          ElevatedButton(
            onPressed: _logout,
            child: Text("Logout"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Food Supplier Dashboard"), backgroundColor: Colors.orange),
      body: _selectedIndex == 0 ? _buildDashboard() : _buildProfile(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.orange,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
