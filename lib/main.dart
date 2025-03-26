import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_proj/dashboard/breeder_dashboard.dart';
import 'package:flutter_proj/dashboard/doctor_dashboard.dart';
import 'package:flutter_proj/services/auth_service.dart';
import 'package:flutter_proj/signup/breeder_signup.dart';
import 'package:flutter_proj/signup/doctor_signup.dart';
import 'package:flutter_proj/signup/food_supplier_signup.dart';
import 'package:flutter_proj/views/UserSelectionScreen.dart';
import 'package:flutter_proj/views/WelcomePage.dart';
import 'package:flutter_proj/views/doctor_screen.dart';
import 'package:flutter_proj/views/food_supplier_screen.dart';
import 'package:flutter_proj/signup/signup.dart';
import 'package:flutter_proj/views/pet_owner_home_screen.dart';
import 'package:flutter_proj/views/pet_owner_profile.dart';
import 'package:flutter_proj/views/upload_area.dart';

import 'dashboard/fsdashboard.dart';
import 'firebase_options.dart';
import 'login/breeder_login.dart';
import 'login/doctor_login.dart';
import 'login/food_supplier_login.dart';
import 'login/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Drive',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {

        "/": (context) => WelcomePage(),
        "/userSelection": (context) => UserSelectionScreen(),
        "/breederSignup": (context) => BreederSignupScreen(),
        "/doctorSignup": (context) => DoctorSignupScreen(),
        "/foodSupplierSignup": (context) => FoodSupplierSignupScreen(),
        "/breederLogin": (context) => BreederLoginScreen(),
        "/doctorLogin": (context) => DoctorLoginScreen(),
        "/foodSupplierLogin": (context) => FoodSupplierLoginScreen(),
        "/fsdash": (context) => FoodSupplierDashboard(),
        "/breeder_dashboard": (context) => BreederDashboard(),
        "/doctor_dashboard": (context) => DoctorDashboard(),
        "/doctor_screen": (context) => DoctorListScreen(),
        "/food_supplier_list": (context) => FoodSupplierListScreen(),
        "/owner_profile":(context)=>ProfileScreen(),// List of food suppliers
        "/home": (context) => HomeScreen(),
        "/login": (context) => LoginPage(),
        "/signup": (context) => SignupPage(),
        "/upload": (context) => UploadArea(),



      },
    );
  }
}

class CheckUser extends StatefulWidget {
  const CheckUser({super.key});

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  @override
  void initState() {
    AuthService().isLoggedIn().then((value) {
      if (value) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        Navigator.pushReplacementNamed(context, "/login");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}