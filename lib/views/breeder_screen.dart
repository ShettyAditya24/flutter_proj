import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BreederScreen extends StatelessWidget {
  const BreederScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Breeding Centers"),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('breeders').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var centers = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: centers.length,
            itemBuilder: (context, index) {
              var center = centers[index];
              var data = center.data() as Map<String, dynamic>?;
              return Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: ListTile(
                  leading: (data != null && data['imageUrls'] != null && data['imageUrls'].isNotEmpty)
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(data['imageUrls'][0], width: 80, height: 80, fit: BoxFit.cover),
                  )
                      : Icon(Icons.store, size: 60, color: Colors.orange),
                  title: Text(data?['shopName'] ?? 'Unknown Shop', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text(data?['ownerName'] ?? 'Unknown Owner', style: TextStyle(fontSize: 14)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetListScreen(center.id, data?['number'] ?? ''), // Pass breeder number
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PetListScreen extends StatelessWidget {
  final String breederId;
  final String breederNumber;

  PetListScreen(this.breederId, this.breederNumber);

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
                    (data != null && data['imageUrls'] != null && data['imageUrls'].isNotEmpty)
                        ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PetDetailScreen(data, breederNumber), // Pass breeder number
                          ),
                        );
                      },
                      child: SizedBox(
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
                      ),
                    )
                        : Icon(Icons.pets, size: 120, color: Colors.orange),
                    ListTile(
                      title: Text(data?['name'] ?? 'Unknown Pet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text("Breed: ${data?['breedType'] ?? 'Unknown'}"),
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

class PetDetailScreen extends StatelessWidget {
  final Map<String, dynamic> petData;
  final String breederNumber;

  PetDetailScreen(this.petData, this.breederNumber);

  void _callBreeder() async {
    if (breederNumber.isNotEmpty) {
      final Uri callUri = Uri(scheme: 'tel', path: breederNumber);
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        throw 'Could not launch $breederNumber';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(petData['name'] ?? 'Pet Details'), backgroundColor: Colors.orange),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: petData['imageUrls'] != null && petData['imageUrls'].isNotEmpty
                  ? Image.network(petData['imageUrls'][0], height: 200, fit: BoxFit.cover)
                  : Icon(Icons.pets, size: 150, color: Colors.orange),
            ),
            SizedBox(height: 20),
            Text("Name: ${petData['name'] ?? 'Unknown'}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Breed: ${petData['breedType'] ?? 'Unknown'}", style: TextStyle(fontSize: 16)),
            Text("Gender: ${petData['gender'] ?? 'Unknown'}", style: TextStyle(fontSize: 16)),
            Text("Age: ${petData['age'] ?? 'Unknown'}", style: TextStyle(fontSize: 16)),
            Text("Description: ${petData['description'] ?? ''}", style: TextStyle(fontSize: 14)),
            Text("Breeder Contact: $breederNumber", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
            Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: _callBreeder,
                icon: Icon(Icons.call),
                label: Text("Contact Breeder"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
