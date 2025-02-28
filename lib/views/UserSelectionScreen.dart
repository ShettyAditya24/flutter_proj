import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserSelectionScreen extends StatefulWidget {
  const UserSelectionScreen({super.key});

  @override
  _UserSelectionScreenState createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/userpet.json"), // Add a pet-related background
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.4), // Dark overlay for better visibility
          ),
          Center(
            child: AnimatedContainer(
              duration: Duration(seconds: 1),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(0, _opacity * -20, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Join Our Pet Community!",
                    style: GoogleFonts.pacifico(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),

                  _buildUserButton(
                    text: "Breeder",
                    icon: Icons.pets,
                    color: Colors.orange.shade700,
                    onPressed: () {
                      Navigator.pushNamed(context, '/breederLogin');
                    },
                  ),
                  SizedBox(height: 20),

                  _buildUserButton(
                    text: "Doctor / Pet Nursing",
                    icon: Icons.medical_services,
                    color: Colors.teal,
                    onPressed: () {
                      Navigator.pushNamed(context, '/doctorLogin');
                    },
                  ),
                  SizedBox(height: 20),

                  _buildUserButton(
                    text: "Food Supplier",
                    icon: Icons.fastfood,
                    color: Colors.red.shade400,
                    onPressed: () {
                      Navigator.pushNamed(context, '/foodSupplierLogin');
                    },
                  ),
                  SizedBox(height: 20),

                  _buildUserButton(
                    text: "Pet Owner",
                    icon: Icons.home,
                    color: Colors.blue.shade500,
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Button Widget
  Widget _buildUserButton({required String text, required IconData icon, required Color color, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 8,
        shadowColor: Colors.black26,
      ),
      icon: Icon(icon, color: Colors.white, size: 28),
      label: Text(
        text,
        style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      onPressed: onPressed,
    );
  }
}
