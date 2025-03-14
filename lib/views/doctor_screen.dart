import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Doctors'), backgroundColor: Colors.orange),
    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('doctors').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        var doctors = snapshot.data!.docs;
        return ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            var doctor = doctors[index].data() as Map<String, dynamic>;
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: ListTile(
                title: Text(doctor['name'] ?? 'No Name', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(doctor['address'] ?? 'No Address'),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.orange),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DoctorDetailScreen(doctorId: doctors[index].id)),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}

class DoctorDetailScreen extends StatefulWidget {
  final String doctorId;
  DoctorDetailScreen({required this.doctorId});

  @override
  _DoctorDetailScreenState createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  String? bookedSlot;
  String? doctorNote;
  bool requiresFollowUp = false;
  Map<String, dynamic>? doctorDetails;
  String? currentUserId;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() => currentUserId = user.uid);
      _loadDoctorDetails();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to continue'), backgroundColor: Colors.red),
      );
    }
  }

  void _loadDoctorDetails() async {
    var doctorDoc = await FirebaseFirestore.instance.collection('doctors').doc(widget.doctorId).get();
    setState(() => doctorDetails = doctorDoc.data());
  }

  Future<List<String>> _getAvailableSlots(String date) async {
    var appointmentDocs = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: widget.doctorId)
        .where('date', isEqualTo: date)
        .get();

    List<String> allSlots = [];
    for (var doc in appointmentDocs.docs) {
      var data = doc.data();
      if (data.containsKey('openTime') && data.containsKey('closeTime')) {
        String openTimeStr = data['openTime'].toString();
        String closeTimeStr = data['closeTime'].toString();
        try {
          DateTime openTime = DateFormat.Hm().parse(openTimeStr);
          DateTime closeTime = DateFormat.Hm().parse(closeTimeStr);
          if (closeTime.isBefore(openTime)) closeTime = closeTime.add(Duration(days: 1));
          while (openTime.isBefore(closeTime)) {
            allSlots.add(DateFormat.Hm().format(openTime));
            openTime = openTime.add(Duration(minutes: 30));
          }
        } catch (e) {
          print('Error parsing time: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid time format: $e'), backgroundColor: Colors.red),
          );
          return [];
        }
      }
    }

    var bookedSlots = await FirebaseFirestore.instance
        .collection('bookings')
        .where('doctorId', isEqualTo: widget.doctorId)
        .where('date', isEqualTo: date)
        .get();

    List<String> bookedSlotsList = bookedSlots.docs.map((doc) => doc['slot'].toString()).toList();
    return allSlots.where((slot) => !bookedSlotsList.contains(slot)).toList();
  }

  void _bookSlot(String slot) async {
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in first!'), backgroundColor: Colors.red),
      );
      return;
    }
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'doctorId': widget.doctorId,
        'ownerId': currentUserId,
        'slot': slot,
        'date': formattedDate,
        'createdAt': FieldValue.serverTimestamp(),
        'note': '', // Default empty note
        'followUp': false, // Default follow-up false
      });
      setState(() => bookedSlot = "$formattedDate $slot");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Slot booked successfully!'), backgroundColor: Colors.orange),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Doctor Details'), backgroundColor: Colors.orange),
    body: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (doctorDetails != null)
            Card(
              color: Colors.orange.shade100,
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctorDetails!['name'] ?? 'No Name',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                    SizedBox(height: 8),
                    Text('📍 Address: ${doctorDetails!['address'] ?? 'No Address'}',
                        style: TextStyle(color: Colors.orange.shade800)),
                    Text('📞 Contact: ${doctorDetails!['phone'] ?? 'No Contact'}',
                        style: TextStyle(color: Colors.orange.shade800)),
                  ],
                ),
              ),
            ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select Date:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) setState(() => selectedDate = pickedDate);
                },
                child: Text(DateFormat('yyyy-MM-dd').format(selectedDate), style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ],
          ),
          SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bookings')
                .where('doctorId', isEqualTo: widget.doctorId)
                .where('ownerId', isEqualTo: currentUserId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return SizedBox.shrink();

              var booking = snapshot.data!.docs.first;
              var bookingData = booking.data() as Map<String, dynamic>?; // Explicit cast
              if (bookingData == null) return SizedBox.shrink(); // Handle null data

              bookedSlot = "${bookingData['date']} ${bookingData['slot']}";
              doctorNote = bookingData['note'] as String? ?? 'No notes from doctor';
              requiresFollowUp = bookingData['followUp'] as bool? ?? false;

              print('Booking Data: $bookingData'); // Debug print

              return Card(
                color: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Booked Slot',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                      SizedBox(height: 8),
                      Text(bookedSlot ?? 'No slot booked', style: TextStyle(color: Colors.orange.shade800)),
                      SizedBox(height: 4),
                      Text('Doctor Note: $doctorNote', style: TextStyle(color: Colors.orange.shade800)),
                      if (requiresFollowUp)
                        Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red, size: 20),
                            SizedBox(width: 4),
                            Text('Follow-up Required', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 16),
          Text('Available Slots',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
          SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('doctorId', isEqualTo: widget.doctorId)
                  .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
                  .snapshots(),
              builder: (context, appointmentSnapshot) {
                if (appointmentSnapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());
                if (!appointmentSnapshot.hasData || appointmentSnapshot.data!.docs.isEmpty)
                  return Center(
                      child: Text('No slots available for this date',
                          style: TextStyle(color: Colors.orange.shade800)));
                return FutureBuilder<List<String>>(
                  future: _getAvailableSlots(DateFormat('yyyy-MM-dd').format(selectedDate)),
                  builder: (context, slotSnapshot) {
                    if (slotSnapshot.connectionState == ConnectionState.waiting)
                      return Center(child: CircularProgressIndicator());
                    if (!slotSnapshot.hasData || slotSnapshot.data!.isEmpty) {
                      return Center(
                          child: Text('All slots booked for this date',
                              style: TextStyle(color: Colors.orange.shade800)));
                    }
                    List<String> availableSlots = slotSnapshot.data!;
                    return ListView.builder(
                      itemCount: availableSlots.length,
                      itemBuilder: (context, index) {
                        String slot = availableSlots[index];
                        return Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            title: Text(slot, style: TextStyle(color: Colors.orange.shade800)),
                            trailing: ElevatedButton(
                              onPressed: () => _bookSlot(slot),
                              child: Text('Book'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange, foregroundColor: Colors.white),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}