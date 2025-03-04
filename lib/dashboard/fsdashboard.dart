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
  File? _image;
  final picker = ImagePicker();
  String _imageUrl = "";
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImageToCloudinary() async {
    if (_image == null) {
      _showSnackbar("Please select an image first.", Colors.red);
      return;
    }

    setState(() => _isUploading = true);

    String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    String uploadUrl = "https://api.cloudinary.com/v1_1/$cloudName/raw/upload";
    String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

    var request = http.MultipartRequest("POST", Uri.parse(uploadUrl));
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(await response.stream.bytesToString());
      setState(() {
        _imageUrl = jsonResponse['secure_url'];
      });
      _addProduct();
    } else {
      _showSnackbar("Image upload failed! Try again.", Colors.red);
    }
    setState(() => _isUploading = false);
  }

  void _addProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _imageUrl.isEmpty) {
      _showSnackbar("All fields are required!", Colors.red);
      return;
    }

    DocumentReference productRef = _firestore.collection("products").doc();
    await productRef.set({
      "id": productRef.id,
      "name": _nameController.text.trim(),
      "price": _priceController.text.trim(),
      "imageUrl": _imageUrl,
      "timestamp": FieldValue.serverTimestamp(),
    });

    _nameController.clear();
    _priceController.clear();
    setState(() {
      _image = null;
      _imageUrl = "";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Food Supplier Dashboard"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Product Name"),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Price"),
            ),
            SizedBox(height: 10),
            _image == null
                ? Text("No Image Selected")
                : Image.file(_image!, height: 100),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Pick Image"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadImageToCloudinary,
              child: _isUploading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Add Product"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: _firestore.collection("products").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var products = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product = products[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: Image.network(product["imageUrl"], height: 50, width: 50, fit: BoxFit.cover),
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
            ),
          ],
        ),
      ),
    );
  }
}
