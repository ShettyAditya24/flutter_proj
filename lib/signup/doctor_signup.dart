import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class DoctorSignupScreen extends StatelessWidget {
  const DoctorSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doctor Signup")),
      body: BounceInDown(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text("Register as a Doctor", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const TextField(decoration: InputDecoration(labelText: "Name")),
              const TextField(decoration: InputDecoration(labelText: "Email")),
              const TextField(decoration: InputDecoration(labelText: "Specialization")),
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
