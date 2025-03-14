import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_proj/views/pet_owner_profile.dart';
import 'doctor_screen.dart';
import 'food_supplier_screen.dart'; // Ensure this file exists in your project

class PetOwnerScreen extends StatefulWidget {
  const PetOwnerScreen({super.key});

  @override
  _PetOwnerScreenState createState() => _PetOwnerScreenState();
}

class _PetOwnerScreenState extends State<PetOwnerScreen> {
  TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {  // Doctor tab clicked
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DoctorListScreen()),
      );
    }
    else if (index == 2) { // Food Supplier tab clicked
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodSupplierListScreen(),
        ),
      );
    }
    else if (index == 3) { // Food Supplier tab clicked
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(),
        ),
      );
    }
    else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Breeding Centers...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                prefixIcon: Icon(Icons.search, color: Colors.orange),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('breeders').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var centers = snapshot.data!.docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>?;
            return data != null &&
                data.containsKey('shopName') &&
                data['shopName'].toString().toLowerCase().contains(_searchController.text.toLowerCase());
          }).toList();

          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: centers.length,
            itemBuilder: (context, index) {
              var center = centers[index];
              var data = center.data() as Map<String, dynamic>?;
              return Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: Container(
                  padding: EdgeInsets.all(12.0),
                  child: ListTile(
                    leading: (data != null && data.containsKey('imageUrls') && data['imageUrls'] != null && data['imageUrls'].isNotEmpty)
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(data['imageUrls'][0], width: 80, height: 80, fit: BoxFit.cover),
                    )
                        : Icon(Icons.store, size: 60, color: Colors.orange),
                    title: Text(
                      data != null && data.containsKey('shopName') ? data['shopName'] : 'Unknown Shop',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      data != null && data.containsKey('ownerName') ? data['ownerName'] : 'Unknown Owner',
                      style: TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PetListScreen(center.id),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: "Doctor"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Food Supplier"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class PetListScreen extends StatelessWidget {
  final String breederId;

  PetListScreen(this.breederId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Available Pets"), backgroundColor: Colors.orange),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('breeders').doc(breederId).collection('pets').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var pets = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              var pet = pets[index];
              var data = pet.data() as Map<String, dynamic>?;
              return Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: Column(
                  children: [
                    (data != null && data.containsKey('imageUrls') && data['imageUrls'] != null && data['imageUrls'].isNotEmpty)
                        ? SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: data['imageUrls'].length,
                        itemBuilder: (context, imgIndex) {
                          return Padding(
                            padding: EdgeInsets.all(5.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(data['imageUrls'][imgIndex], width: 140, height: 180, fit: BoxFit.cover),
                            ),
                          );
                        },
                      ),
                    )
                        : Icon(Icons.pets, size: 120, color: Colors.orange),
                    ListTile(
                      title: Text(
                        data != null && data.containsKey('name') ? data['name'] : 'Unknown Pet',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(
                        "Breed: ${data != null && data.containsKey('breedType') ? data['breedType'] : 'Unknown'}\n${data != null && data.containsKey('description') ? data['description'] : ''}",
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
