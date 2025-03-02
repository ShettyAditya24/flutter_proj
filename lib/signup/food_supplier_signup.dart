import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FoodSupplierSignupScreen extends StatefulWidget {
  const FoodSupplierSignupScreen({super.key});

  @override
  State<FoodSupplierSignupScreen> createState() => _FoodSupplierSignupScreenState();
}

class _FoodSupplierSignupScreenState extends State<FoodSupplierSignupScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _supplierNameController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _signup() async {
    if (!formKey.currentState!.validate()) return;

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('foodSuppliers').doc(uid).set({
        'uid': uid,
        'supplierName': _supplierNameController.text.trim(),
        'businessName': _businessNameController.text.trim(),
        'address': _addressController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog(e);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("🎉 Success!", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Your account has been created successfully. Please login to continue."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, "/foodSupplierLogin");
              },
              child: const Text("Go to Login", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(dynamic e) {
    String errorMessage = "Something went wrong. Please try again.";
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = "This email is already registered. Try logging in.";
          break;
        case 'weak-password':
          errorMessage = "Your password is too weak. Choose a stronger password.";
          break;
        case 'invalid-email':
          errorMessage = "Please enter a valid email address.";
          break;
        default:
          errorMessage = "Signup failed: ${e.message}";
          break;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("⚠️ Oops!", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/fs.jpg"),  // Ensure this image exists
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ZoomIn(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),

                    Animate(
                      effects: [FadeEffect(duration: 800.ms), ScaleEffect(delay: 300.ms, duration: 600.ms)],
                      child: Lottie.asset(
                        'assets/images/foodsign.json', // Ensure the path is correct
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Text(
                      "Register as a Food Supplier",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          _buildTextField("Supplier Name", Icons.person, _supplierNameController),
                          const SizedBox(height: 10),
                          _buildTextField("Business Name", Icons.business, _businessNameController),
                          const SizedBox(height: 10),
                          _buildTextField("Address", Icons.location_on, _addressController),
                          const SizedBox(height: 10),
                          _buildTextField("Mobile Number", Icons.phone, _mobileController, isPhone: true),
                          const SizedBox(height: 10),
                          _buildTextField("Email", Icons.email, _emailController, isEmail: true),
                          const SizedBox(height: 10),
                          _buildPasswordField(),
                          const SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: _signup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ).animate().fadeIn(duration: 800.ms).scale(delay: 300.ms, duration: 600.ms),

                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account?"),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hintText, IconData icon, TextEditingController controller,
      {bool isPhone = false, bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.orange),
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ).animate().fadeIn(duration: 800.ms);
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: Colors.orange),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        hintText: "Password",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ).animate().fadeIn(duration: 800.ms);
  }
}
