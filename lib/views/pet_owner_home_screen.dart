import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'breeder_screen.dart';
import 'doctor_screen.dart';
import 'food_supplier_screen.dart';
import 'pet_owner_profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DoctorListScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FoodSupplierListScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BreederScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Pet Community"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Owned Pets",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddPetScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text("Add Pet", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            OwnedPetsSection(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: const Text(
                "Order History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            OrderHistorySection(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: "Doctor"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Food Supplier"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: "Breeders"),
        ],
      ),
    );
  }
}

class OwnedPetsSection extends StatelessWidget {
  const OwnedPetsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text("Please log in to view your pets."),
      );
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('owned_pets')
          .where("ownerId", isEqualTo: user.uid)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var pets = snapshot.data!.docs;
        return Column(
          children: [
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  var pet = pets[index].data() as Map<String, dynamic>?;
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    child: Column(
                      children: [
                        pet != null && pet.containsKey('imageUrl') && pet['imageUrl'] != null
                            ? Image.network(pet['imageUrl'], width: 100, height: 100, fit: BoxFit.cover)
                            : const Icon(Icons.pets, size: 80, color: Colors.orange),
                        Text(pet?['name'] ?? 'Unknown Pet'),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PetListScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("View Pets", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class OrderHistorySection extends StatelessWidget {
  const OrderHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text("Please log in to view your order history."),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("orders")
          .where("userId", isEqualTo: user.uid)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No orders found."));
        }

        var orders = snapshot.data!.docs;
        return SizedBox(
          height: 200, // Increased height for better visibility
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index].data() as Map<String, dynamic>;
              var timestamp = order['timestamp'] as Timestamp?;
              String formattedDate = timestamp != null
                  ? DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate())
                  : 'N/A';

              return SizedBox(
                width: 250, // Fixed width for each card
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order["productName"] ?? "Unknown Product",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis, // Truncate long text with "..."
                          maxLines: 1, // Limit to one line
                        ),
                        Text(
                          "Price: ₹${order["price"] ?? 'N/A'}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          "Store: ${order["businessName"] ?? 'Unknown Store'}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          "Order Date: $formattedDate",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class AddPetScreen extends StatefulWidget {
  @override
  _AddPetScreenState createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  String? _gender;

  Future<void> _addPet() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance.collection('owned_pets').add({
            'name': _nameController.text.trim(),
            'age': int.parse(_ageController.text.trim()),
            'breed': _breedController.text.trim(),
            'gender': _gender,
            'ownerId': user.uid,
            'timestamp': Timestamp.now(),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pet added successfully!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error adding pet: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Pet"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Pet Name"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter a pet name";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter the pet's age";
                  }
                  if (int.tryParse(value.trim()) == null || int.parse(value.trim()) <= 0) {
                    return "Please enter a valid age";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(labelText: "Breed"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter the pet's breed";
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: "Gender"),
                items: ['Male', 'Female'].map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return "Please select a gender";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addPet,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Add Pet", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _breedController.dispose();
    super.dispose();
  }
}

class PetListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("My Pets"),
          backgroundColor: Colors.orange,
          centerTitle: true,
        ),
        body: const Center(
          child: Text("Please log in to view your pets."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pets"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('owned_pets')
            .where("ownerId", isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pets found.", style: TextStyle(color: Colors.orange)));
          }

          var pets = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              var pet = pets[index].data() as Map<String, dynamic>;
              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: ListTile(
                  leading: pet.containsKey('imageUrl') && pet['imageUrl'] != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(pet['imageUrl'], width: 60, height: 60, fit: BoxFit.cover),
                  )
                      : const Icon(Icons.pets, size: 60, color: Colors.orange),
                  title: Text(
                    pet['name'] ?? 'Unknown Pet',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Age: ${pet['age'] ?? 'N/A'} | Breed: ${pet['breed'] ?? 'N/A'} | Gender: ${pet['gender'] ?? 'N/A'}",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}