import 'package:flutter/material.dart';
import '../services/breeder_auth.dart';

class BreederSignupScreen extends StatefulWidget {
  const BreederSignupScreen({super.key});

  @override
  _BreederSignupScreenState createState() => _BreederSignupScreenState();
}

class _BreederSignupScreenState extends State<BreederSignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dogNameController = TextEditingController();
  final TextEditingController _breedTypeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      String? error = await BreederAuth().signUp(
        _nameController.text.trim(),
        _dogNameController.text.trim(),
        _breedTypeController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Signup successful! Redirecting to login..."),
            backgroundColor: Colors.green,
          ),
        );

        // Delay before navigation to show message properly
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, "/breederLogin");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Breeder Signup")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Register as a Breeder", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Your Name"),
                validator: (value) => value!.isEmpty ? "Enter your name" : null,
              ),
              TextFormField(
                controller: _dogNameController,
                decoration: const InputDecoration(labelText: "Dog Name"),
                validator: (value) => value!.isEmpty ? "Enter dog name" : null,
              ),
              TextFormField(
                controller: _breedTypeController,
                decoration: const InputDecoration(labelText: "Breed Type"),
                validator: (value) => value!.isEmpty ? "Enter breed type" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty || !value.contains('@') ? "Enter valid email" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) => value!.length < 6 ? "Password too short" : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _signUp,
                child: const Text("Sign Up"),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/breederLogin");
                },
                child: const Text("Already have an account? Log in here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
