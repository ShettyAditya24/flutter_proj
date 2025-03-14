import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  String name = "";
  String email = "";
  String phone = "";
  bool isEditingName = false;
  bool isEditingPhone = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('petOwners').doc(user!.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>? ?? {};

        setState(() {
          name = userData.containsKey('name') ? userData['name'] : "";
          email = userData.containsKey('email') ? userData['email'] : "";
          phone = userData.containsKey('phone') ? userData['phone'] : "";

          _nameController.text = name;
          _phoneController.text = phone;
        });
      }
    }
  }

  Future<void> _updateUserData(String field, String value) async {
    if (user != null) {
      await _firestore.collection('petOwners').doc(user!.uid).update({
        field: value,
      });

      setState(() {
        if (field == 'name') name = value;
        if (field == 'phone') phone = value;
        isEditingName = false;
        isEditingPhone = false;
      });
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileField("Name", _nameController, 'name', isEditingName,
                      () {
                    setState(() {
                      isEditingName = true;
                    });
                  }, () {
                    _updateUserData('name', _nameController.text);
                  }),
              _buildProfileField("mobile", _phoneController, 'mobile',
                  isEditingPhone, () {
                    setState(() {
                      isEditingPhone = true;
                    });
                  }, () {
                    _updateUserData('phone', _phoneController.text);
                  }),
              _buildNonEditableField("Email", email),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller,
      String field, bool isEditing, VoidCallback onEdit, VoidCallback onSave) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: isEditing
            ? Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(border: UnderlineInputBorder()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: onSave,
            ),
          ],
        )
            : Row(
          children: [
            Expanded(child: Text(controller.text)),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNonEditableField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
