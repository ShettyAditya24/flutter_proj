import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class FoodSupplierSignupScreen extends StatelessWidget {
  const FoodSupplierSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Food Supplier Signup")),
      body: ZoomIn(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text("Register as a Food Supplier", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const TextField(decoration: InputDecoration(labelText: "Business Name")),
              const TextField(decoration: InputDecoration(labelText: "Email")),
              const TextField(decoration: InputDecoration(labelText: "Password"), obscureText: true),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () {}, child: const Text("Sign Up")),
            ],
          ),
        ),
      ),
    );
  }
}
