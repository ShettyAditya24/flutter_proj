// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
//
// class FoodSupplierDashboard extends StatefulWidget {
//   const FoodSupplierDashboard({super.key});
//
//   @override
//   State<FoodSupplierDashboard> createState() => _FoodSupplierDashboardState();
// }
//
// class _FoodSupplierDashboardState extends State<FoodSupplierDashboard> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   User? _user;
//   Map<String, dynamic>? _supplierData;
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentUser();
//   }
//
//   Future<void> _getCurrentUser() async {
//     _user = _auth.currentUser;
//     if (_user != null) {
//       DocumentSnapshot doc = await _firestore.collection('food_suppliers').doc(_user!.uid).get();
//       if (doc.exists) {
//         setState(() {
//           _supplierData = doc.data() as Map<String, dynamic>?;
//         });
//       }
//     }
//   }
//
//   Future<void> _logout() async {
//     await _auth.signOut();
//     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FoodSupplierLoginScreen()));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Food Supplier Dashboard"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: _logout,
//           )
//         ],
//       ),
//       body: _supplierData == null
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Card(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//               elevation: 5,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("👤 Name: ${_supplierData!['name']}", style: _infoTextStyle()),
//                     Text("🏢 Business: ${_supplierData!['businessName']}", style: _infoTextStyle()),
//                     Text("📧 Email: ${_supplierData!['email']}", style: _infoTextStyle()),
//                     Text("📍 Address: ${_supplierData!['address']}", style: _infoTextStyle()),
//                     Text("📞 Contact: ${_supplierData!['phone']}", style: _infoTextStyle()),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen()));
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orangeAccent,
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               child: const Text("➕ Add New Product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             ),
//             const SizedBox(height: 20),
//             const Text("📦 Your Products:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             Expanded(child: _buildProductList()),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProductList() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _firestore.collection('food_suppliers').doc(_user!.uid).collection('products').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text("No products added yet."));
//         }
//
//         return ListView(
//           children: snapshot.data!.docs.map((doc) {
//             var product = doc.data() as Map<String, dynamic>;
//             return Card(
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               elevation: 3,
//               child: ListTile(
//                 leading: product['imageUrl'] != null
//                     ? Image.network(product['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
//                     : const Icon(Icons.fastfood, size: 50),
//                 title: Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
//                 subtitle: Text("Price: ₹${product['price']}"),
//                 trailing: IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   onPressed: () async {
//                     await _firestore.collection('food_suppliers').doc(_user!.uid).collection('products').doc(doc.id).delete();
//                   },
//                 ),
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
//
//   TextStyle _infoTextStyle() {
//     return const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
//   }
// }
