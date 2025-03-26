import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodSupplierListScreen extends StatelessWidget {
  const FoodSupplierListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Food Suppliers"),
          backgroundColor: Colors.orange,
          centerTitle: true,
        ),
        body: const Center(
          child: Text("Please log in to view suppliers.", style: TextStyle(color: Colors.orange)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Food Suppliers"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("foodSuppliers").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No suppliers found.", style: TextStyle(color: Colors.orange)));
          }
          var suppliers = snapshot.data!.docs;
          return ListView.builder(
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              var supplier = suppliers[index].data() as Map<String, dynamic>;
              return Card(
                elevation: 5,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(
                    Icons.store,
                    size: 50,
                    color: Colors.orange,
                  ),
                  title: Text(
                    supplier["businessName"] ?? "Unknown Store",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  subtitle: Text(
                    supplier["address"] ?? "No Address",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FoodProductListScreen(supplierName: supplier["businessName"]),
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

class FoodProductListScreen extends StatelessWidget {
  final String supplierName;

  const FoodProductListScreen({required this.supplierName});

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("$supplierName - Products"),
          backgroundColor: Colors.orange,
          centerTitle: true,
        ),
        body: const Center(
          child: Text("Please log in to view products.", style: TextStyle(color: Colors.orange)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("$supplierName - Products"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("products").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No products available.", style: TextStyle(color: Colors.orange)),
            );
          }
          var products = snapshot.data!.docs;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index].data() as Map<String, dynamic>;
              List<dynamic> imageUrls = product["imageUrls"] ?? [];
              return Card(
                elevation: 5,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: imageUrls.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrls[0],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.fastfood,
                        size: 50,
                        color: Colors.orange,
                      ),
                    ),
                  )
                      : const Icon(
                    Icons.fastfood,
                    size: 50,
                    color: Colors.orange,
                  ),
                  title: Text(
                    product["name"] ?? "Unknown Product",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  subtitle: Text(
                    "₹${product["price"] ?? 'N/A'}\n${product["description"] ?? 'No description available'}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FoodProductDetailScreen(product: product),
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

class FoodProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const FoodProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    List<dynamic> imageUrls = product["imageUrls"] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text(product["name"] ?? "Product Details"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrls.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrls[0],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.fastfood,
                    size: 100,
                    color: Colors.orange,
                  ),
                ),
              ),
            )
                : Container(
              height: 200,
              color: Colors.grey[300],
              child: const Icon(
                Icons.fastfood,
                size: 100,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product["name"] ?? "Unknown Product",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              "Price: ₹${product["price"] ?? 'N/A'}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              product["description"] ?? "No description available",
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _buyProduct(context, product),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Buy Now", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _buyProduct(BuildContext context, Map<String, dynamic> product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User is not logged in.  Redirect to login or show an error.
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to make a purchase.')));
      return; // Stop the purchase process
    }

    //Get Supplier name
    // Assuming the food supplier's name is stored within the product data.
    String supplierName = product['supplierName'] ?? 'Unknown Supplier';


    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'productName': product['name'] ?? 'Unknown Product',
        'price': product['price'] ?? 'N/A',
        'storeName': supplierName,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Success"),
            content: Text("Successfully purchased ${product["name"] ?? 'this product'}!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to product list
                },
                child: const Text("OK", style: TextStyle(color: Colors.orange)),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error adding order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')));
    }
  }
}