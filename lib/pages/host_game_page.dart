import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class HostGamePage extends StatefulWidget {
  @override
  _HostGamePageState createState() => _HostGamePageState();
}

class _HostGamePageState extends State<HostGamePage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedSport;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  TextEditingController locationController = TextEditingController();
  TextEditingController maxPlayersController = TextEditingController();

  List<String> sportsList = ['Cricket', 'Football', 'Pickleball', 'Badminton'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F5E8),
      appBar: AppBar(
        title: Text('Host a Game', style: GoogleFonts.poppins()),
        backgroundColor: Color(0xFF4CAF50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedSport,
                  decoration: InputDecoration(
                    labelText: 'Select Sport',
                    labelStyle: GoogleFonts.poppins(),
                  ),
                  items: sportsList.map((sport) {
                    return DropdownMenuItem(
                      value: sport,
                      child: Text(sport, style: GoogleFonts.poppins()),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedSport = value),
                  validator: (value) => value == null ? 'Please select a sport' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Select Date',
                    labelStyle: GoogleFonts.poppins(),
                  ),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  controller: TextEditingController(
                    text: selectedDate == null
                        ? ''
                        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please select a date' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Select Time',
                    labelStyle: GoogleFonts.poppins(),
                  ),
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                  controller: TextEditingController(
                    text: selectedTime == null ? '' : selectedTime!.format(context),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please select a time' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Enter Location',
                    labelStyle: GoogleFonts.poppins(),
                  ),
                  style: GoogleFonts.poppins(),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Location required' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: maxPlayersController,
                  decoration: InputDecoration(
                    labelText: 'Max Players',
                    labelStyle: GoogleFonts.poppins(),
                  ),
                  style: GoogleFonts.poppins(),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter player limit' : null,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    elevation: 4,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) throw Exception("User not logged in");

                        final userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .get();

                        final userName = userDoc.data()?['name'] ?? user.email;

                        final gameData = {
                          'sport': selectedSport,
                          'date':
                          '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                          'time': selectedTime!.format(context),
                          'location': locationController.text,
                          'maxPlayers': int.tryParse(maxPlayersController.text),
                          'hostEmail': user.email ?? '',
                          'hostUid': user.uid,
                          'hostName': userName,
                          'createdAt': Timestamp.now(),
                        };

                        await FirebaseFirestore.instance
                            .collection('games')
                            .add(gameData);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Game Hosted!', style: GoogleFonts.poppins())),
                        );

                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: \${e.toString()}', style: GoogleFonts.poppins())),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Submit',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
