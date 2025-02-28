// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:lottie/lottie.dart';
// import 'package:flutter_proj/services/auth_service.dart';
// import 'home.dart';
//
// class BreederLoginPage extends StatefulWidget {
//   const BreederLoginPage({super.key});
//
//   @override
//   State<BreederLoginPage> createState() => _BreederLoginPageState();
// }
//
// class _BreederLoginPageState extends State<BreederLoginPage> {
//   final formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return buildLoginScreen(
//       context,
//       "Breeder Login",
//       "assets/images/breeder_background.jpg",
//       "assets/images/breeder_logo.png",
//       "assets/animations/breeder_animation.json",
//     );
//   }
// }
//
// class DoctorLoginPage extends StatefulWidget {
//   const DoctorLoginPage({super.key});
//
//   @override
//   State<DoctorLoginPage> createState() => _DoctorLoginPageState();
// }
//
// class _DoctorLoginPageState extends State<DoctorLoginPage> {
//   final formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return buildLoginScreen(
//       context,
//       "Doctor Login",
//       "assets/images/doctor_background.jpg",
//       "assets/images/doctor_logo.png",
//       "assets/animations/doctor_animation.json",
//     );
//   }
// }
//
// class FoodSupplierLoginPage extends StatefulWidget {
//   const FoodSupplierLoginPage({super.key});
//
//   @override
//   State<FoodSupplierLoginPage> createState() => _FoodSupplierLoginPageState();
// }
//
// class _FoodSupplierLoginPageState extends State<FoodSupplierLoginPage> {
//   final formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return buildLoginScreen(
//       context,
//       "Food Supplier Login",
//       "assets/images/food_supplier_background.jpg",
//       "assets/images/food_supplier_logo.png",
//       "assets/animations/food_supplier_animation.json",
//     );
//   }
// }
//
// // Common Login UI Function
// Widget buildLoginScreen(BuildContext context, String title, String backgroundPath, String logoPath, String animationPath) {
//   final formKey = GlobalKey<FormState>();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//
//   return Scaffold(
//     backgroundColor: Colors.white,
//     body: Stack(
//       children: [
//         Positioned.fill(
//           child: Image.asset(
//             backgroundPath,
//             fit: BoxFit.cover,
//           ),
//         ),
//         Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 30),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   logoPath,
//                   width: 100,
//                   height: 100,
//                 ).animate().fadeIn(duration: 800.ms).scale(delay: 300.ms, duration: 600.ms),
//                 const SizedBox(height: 10),
//                 Lottie.asset(
//                   animationPath,
//                   width: 200,
//                   height: 200,
//                 ),
//                 const SizedBox(height: 20),
//                 Form(
//                   key: formKey,
//                   child: Column(
//                     children: [
//                       TextFormField(
//                         controller: emailController,
//                         validator: (value) => value!.isEmpty ? "Email cannot be empty." : null,
//                         decoration: InputDecoration(
//                           prefixIcon: const Icon(Icons.email, color: Colors.orange),
//                           hintText: "Email",
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(30),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ).animate().fadeIn(duration: 800.ms),
//                       const SizedBox(height: 10),
//                       TextFormField(
//                         controller: passwordController,
//                         validator: (value) => value!.length < 8 ? "Password should have at least 8 characters." : null,
//                         obscureText: true,
//                         decoration: InputDecoration(
//                           prefixIcon: const Icon(Icons.lock, color: Colors.orange),
//                           hintText: "Password",
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(30),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ).animate().fadeIn(duration: 800.ms),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: () {},
//                     child: const Text("Forgot Password?", style: TextStyle(color: Colors.orange)),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (formKey.currentState!.validate()) {
//                       AuthService().loginWithEmail(emailController.text, passwordController.text).then((value) {
//                         if (value == "Login Successful") {
//                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Successful")));
//                           Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(value, style: const TextStyle(color: Colors.white)),
//                               backgroundColor: Colors.red.shade400,
//                             ),
//                           );
//                         }
//                       });
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orangeAccent,
//                     padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   child: const Text(
//                     "Login",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
//                   ),
//                 ).animate().fadeIn(duration: 800.ms).scale(delay: 300.ms, duration: 600.ms),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Don't have an account?"),
//                     TextButton(
//                       onPressed: () {
//                         if (title.contains("Breeder")) {
//                           Navigator.pushNamed(context, "/breeder_signup");
//                         } else if (title.contains("Doctor")) {
//                           Navigator.pushNamed(context, "/doctor_signup");
//                         } else if (title.contains("Food Supplier")) {
//                           Navigator.pushNamed(context, "/food_supplier_signup");
//                         }
//                       },
//                       child: const Text("Sign Up", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
