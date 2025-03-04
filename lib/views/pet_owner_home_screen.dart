import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PetOwnerScreen extends StatefulWidget {
  @override
  _PetOwnerScreenState createState() => _PetOwnerScreenState();
}

class _PetOwnerScreenState extends State<PetOwnerScreen> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search Breeding Centers...",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {});
          },
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
            itemCount: centers.length,
            itemBuilder: (context, index) {
              var center = centers[index];
              var data = center.data() as Map<String, dynamic>?;
              return ListTile(
                leading: (data != null && data.containsKey('imageUrls') && data['imageUrls'] != null && data['imageUrls'].isNotEmpty)
                    ? Image.network(data['imageUrls'][0])
                    : Icon(Icons.store),
                title: Text(data != null && data.containsKey('shopName') ? data['shopName'] : 'Unknown Shop'),
                subtitle: Text(data != null && data.containsKey('ownerName') ? data['ownerName'] : 'Unknown Owner'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PetListScreen(center.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
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
      appBar: AppBar(title: Text("Available Pets")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('breeders').doc(breederId).collection('pets').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var pets = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              var pet = pets[index];
              var data = pet.data() as Map<String, dynamic>?;
              return Card(
                child: Column(
                  children: [
                    (data != null && data.containsKey('imageUrls') && data['imageUrls'] != null && data['imageUrls'].isNotEmpty)
                        ? SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: data['imageUrls'].length,
                        itemBuilder: (context, imgIndex) {
                          return Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Image.network(data['imageUrls'][imgIndex]),
                          );
                        },
                      ),
                    )
                        : Icon(Icons.pets, size: 100),
                    ListTile(
                      title: Text(data != null && data.containsKey('name') ? data['name'] : 'Unknown Pet'),
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
