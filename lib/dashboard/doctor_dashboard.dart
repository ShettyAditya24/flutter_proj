import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoctorDashboard extends StatefulWidget {
  @override
  _DoctorDashboardState createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _openTimeController = TextEditingController();
  TextEditingController _closeTimeController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    var doc = await FirebaseFirestore.instance.collection('doctors').doc(FirebaseAuth.instance.currentUser!.uid).get();
    var data = doc.data();
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _addressController.text = data['address'] ?? '';
      _phoneController.text = data['phone'] ?? '';
    }
  }

  Future<void> _saveProfile() async {
    await FirebaseFirestore.instance.collection('doctors').doc(FirebaseAuth.instance.currentUser!.uid).update({
      'name': _nameController.text,
      'address': _addressController.text,
      'phone': _phoneController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated"), backgroundColor: Colors.green));
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _dateController.text = DateFormat('yyyy-MM-dd').format(picked));
  }

  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => controller.text = picked.format(context));
  }

  Future<void> _addAppointment() async {
    if (_dateController.text.isNotEmpty && _openTimeController.text.isNotEmpty && _closeTimeController.text.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        await FirebaseFirestore.instance.collection('appointments').add({
          'doctorId': FirebaseAuth.instance.currentUser!.uid,
          'date': _dateController.text,
          'openTime': _openTimeController.text,
          'closeTime': _closeTimeController.text,
          'createdAt': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Appointment slots added successfully!"), backgroundColor: Colors.green));
        _dateController.clear();
        _openTimeController.clear();
        _closeTimeController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add appointment: $e"), backgroundColor: Colors.red));
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill in all fields!"), backgroundColor: Colors.orange));
    }
  }

  Future<void> _updateFollowUp(String id, bool value, String ownerId) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(id).update({'followUp': value});
      if (value) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': ownerId,
          'message': 'Doctor has requested a follow-up for your appointment.',
          'timestamp': Timestamp.now(),
          'read': false,
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Follow-up updated'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update follow-up: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _updateNotes(String id, String notes) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(id).update({'note': notes});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Notes updated'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update notes: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _deleteBooking(String id) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking deleted successfully'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete booking: $e'), backgroundColor: Colors.red));
    }
  }

  Future<String> _getOwnerName(String ownerId) async {
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(ownerId).get();
    return userDoc.data()?['name'] ?? 'Unknown User';
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Widget _buildDashboard() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(controller: _dateController, decoration: InputDecoration(labelText: "Select Date", border: OutlineInputBorder()), readOnly: true, onTap: _selectDate),
              SizedBox(height: 10),
              TextField(controller: _openTimeController, decoration: InputDecoration(labelText: "Open Time", border: OutlineInputBorder()), readOnly: true, onTap: () => _selectTime(_openTimeController)),
              SizedBox(height: 10),
              TextField(controller: _closeTimeController, decoration: InputDecoration(labelText: "Close Time", border: OutlineInputBorder()), readOnly: true, onTap: () => _selectTime(_closeTimeController)),
              SizedBox(height: 10),
              ElevatedButton(onPressed: _isLoading ? null : _addAppointment, child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Add Appointment"), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange)),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('bookings').where('doctorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text('No bookings found'));

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  var data = doc.data() as Map<String, dynamic>;
                  String ownerId = data['ownerId'] ?? 'Unknown';
                  TextEditingController noteController = TextEditingController(text: data['note'] ?? '');

                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text("${data['date'] ?? 'No date'} - ${data['slot'] ?? 'No time'}", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<String>(
                            future: _getOwnerName(ownerId),
                            builder: (context, snapshot) => Text("Owner: ${snapshot.data ?? 'Loading...'}", style: TextStyle(color: Colors.grey[700])),
                          ),
                          Row(
                            children: [
                              Text("Follow-up: "),
                              Checkbox(value: data['followUp'] as bool? ?? false, onChanged: (bool? value) => _updateFollowUp(doc.id, value ?? false, ownerId), activeColor: Colors.orange),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(child: TextField(controller: noteController, decoration: InputDecoration(labelText: "Notes"))),
                              SizedBox(width: 10),
                              ElevatedButton(onPressed: () => _updateNotes(doc.id, noteController.text), child: Text("Save"), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange)),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () async {
                        bool? confirm = await showDialog(context: context, builder: (context) => AlertDialog(title: Text('Confirm Delete'), content: Text('Are you sure?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete'))]));
                        if (confirm == true) _deleteBooking(doc.id);
                      }),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfile() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(controller: _nameController, decoration: InputDecoration(labelText: "Name", border: OutlineInputBorder())),
          SizedBox(height: 10),
          TextField(controller: _addressController, decoration: InputDecoration(labelText: "Address", border: OutlineInputBorder())),
          SizedBox(height: 10),
          TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: "Phone", border: OutlineInputBorder())),
          SizedBox(height: 10),
          ElevatedButton(onPressed: _saveProfile, child: Text("Save"), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange)),
          SizedBox(height: 10),
          ElevatedButton(onPressed: _logout, child: Text("Logout"), style: ElevatedButton.styleFrom(backgroundColor: Colors.red)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_currentIndex == 0 ? "Doctor Dashboard" : "Profile"), backgroundColor: Colors.orange),
        body: _currentIndex == 0 ? _buildDashboard() : _buildProfile(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: Colors.orange,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
