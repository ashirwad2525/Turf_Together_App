import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_page.dart';

class JoinGamePage extends StatefulWidget {
  @override
  _JoinGamePageState createState() => _JoinGamePageState();
}

class _JoinGamePageState extends State<JoinGamePage> {
  String? selectedSport;
  DateTime? selectedDate;

  List<String> sportsList = ['All', 'Cricket', 'Football', 'Pickleball', 'Badminton'];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Color(0xFFE8F5E8),
      appBar: AppBar(
        title: Text('Join a Game', style: GoogleFonts.poppins()),
        backgroundColor: Color(0xFF4CAF50),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSport ?? 'All',
                    decoration: InputDecoration(
                      labelText: 'Sport',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: sportsList.map((sport) {
                      return DropdownMenuItem(
                        value: sport,
                        child: Text(sport, style: GoogleFonts.poppins()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSport = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(Duration(days: 1)),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        selectedDate == null
                            ? 'Any'
                            : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('games')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final games = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final joinedPlayers = List.from(data['joinedPlayers'] ?? []);
                  bool sportMatch = selectedSport == null || selectedSport == 'All' || data['sport'] == selectedSport;
                  bool dateMatch = selectedDate == null || data['date'] == '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
                  return sportMatch && dateMatch;
                }).toList();

                return ListView.builder(
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final doc = games[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final joinedPlayers = List.from(data['joinedPlayers'] ?? []);
                    final alreadyJoined = user != null && joinedPlayers.any((p) => p['uid'] == user.uid);
                    final maxPlayers = data['maxPlayers'] ?? 0;

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      padding: EdgeInsets.all(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.sports_soccer, color: Color(0xFF4CAF50)),
                              SizedBox(width: 8),
                              Text(
                                data['sport'],
                                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              Text('at ${data['location']}',
                                  style: GoogleFonts.poppins(color: Colors.grey[700])),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                              SizedBox(width: 6),
                              Text(data['date'], style: GoogleFonts.poppins()),
                              SizedBox(width: 20),
                              Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                              SizedBox(width: 6),
                              Text(data['time'], style: GoogleFonts.poppins()),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text('Host: ${data['hostName'] ?? 'Unknown'}', style: GoogleFonts.poppins()),
                          SizedBox(height: 4),
                          Text('Joined: ${joinedPlayers.length} / $maxPlayers', style: GoogleFonts.poppins()),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatPage(gameId: doc.id),
                                    ),
                                  );
                                },
                                child: Text("Chat", style: GoogleFonts.poppins()),
                              ),
                              SizedBox(width: 8),
                              alreadyJoined
                                  ? Text("Joined",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ))
                                  : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF4CAF50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  if (user == null) return;

                                  if (joinedPlayers.length >= maxPlayers) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('This game is full.', style: GoogleFonts.poppins())),
                                    );
                                    return;
                                  }

                                  try {
                                    await doc.reference.update({
                                      'joinedPlayers': FieldValue.arrayUnion([
                                        {
                                          'uid': user.uid,
                                          'email': user.email ?? '',
                                        }
                                      ])
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('You’ve joined the game!', style: GoogleFonts.poppins())),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: \$e', style: GoogleFonts.poppins())),
                                    );
                                  }
                                },
                                child: Text("Join", style: GoogleFonts.poppins()),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
