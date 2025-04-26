import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BreederProfile extends StatefulWidget {
  const BreederProfile({super.key});

  @override
  State<BreederProfile> createState() => _BreederProfileState();
}

class _BreederProfileState extends State<BreederProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isEditing = false;
  bool _isLoading = true;

  TextEditingController shopController = TextEditingController();
  TextEditingController ownerController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot doc = await _firestore.collection('breeders').doc(uid).get();
    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      shopController.text = data['shopName'] ?? '';
      ownerController.text = data['ownerName'] ?? '';
      addressController.text = data['address'] ?? '';
      phoneController.text = data['phone'] ?? '';
    }
    setState(() => _isLoading = false);
  }

  Future<void> saveProfileData() async {
    String uid = _auth.currentUser!.uid;
    await _firestore.collection('breeders').doc(uid).update({
      'shopName': shopController.text,
      'ownerName': ownerController.text,
      'address': addressController.text,
      'phone': phoneController.text,
    });
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profile updated successfully"), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: Text("Profile"), backgroundColor: Colors.orange),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: shopController, decoration: InputDecoration(labelText: 'Shop Name'), enabled: _isEditing),
            TextField(controller: ownerController, decoration: InputDecoration(labelText: 'Owner Name'), enabled: _isEditing),
            TextField(controller: addressController, decoration: InputDecoration(labelText: 'Address'), enabled: _isEditing),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone Number'), enabled: _isEditing),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_isEditing) {
                      saveProfileData();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: Text(_isEditing ? "Save" : "Edit", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    await _auth.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("Logout", style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
