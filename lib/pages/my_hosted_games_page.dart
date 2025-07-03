import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'game_details_page.dart';
import 'chat_page.dart';

class MyHostedGamesPage extends StatefulWidget {
  @override
  State<MyHostedGamesPage> createState() => _MyHostedGamesPageState();
}

class _MyHostedGamesPageState extends State<MyHostedGamesPage> {
  User? user;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? currentUser) {
      setState(() {
        user = currentUser;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: Color(0xFFE8F5E8),
        appBar: AppBar(title: Text("My Hosted Games")),
        body: Center(child: Text("You are not logged in.")),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFE8F5E8), // Light green background
      appBar: AppBar(
        title: Text('My Hosted Games'),
        backgroundColor: Color(0xFF4CAF50), // Green theme
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('games')
            .where('hostUid', isEqualTo: user!.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "⚠️ Firestore error: ${snapshot.error}\n\n"
                      "Please ensure indexes exist.",
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final hostedGames = snapshot.data?.docs ?? [];

          if (hostedGames.isEmpty) {
            return Center(
              child: Text(
                "You haven’t hosted any games.",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            );
          }

          return ListView.builder(
            itemCount: hostedGames.length,
            itemBuilder: (context, index) {
              final gameDoc = hostedGames[index];
              final game = gameDoc.data() as Map<String, dynamic>;

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
                    // Game info row
                    Row(
                      children: [
                        Icon(Icons.sports_soccer, color: Color(0xFF4CAF50)),
                        SizedBox(width: 8),
                        Text(
                          game['sport'] ?? '',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(game['location'] ?? '', style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                        SizedBox(width: 6),
                        Text(game['date'] ?? ''),
                        SizedBox(width: 16),
                        Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                        SizedBox(width: 6),
                        Text(game['time'] ?? ''),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Players Joined: ${game['joinedPlayers']?.length ?? 0}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chat_bubble, color: Colors.blue),
                          tooltip: 'Open Chat',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatPage(gameId: gameDoc.id),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete Game',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text("Delete Game"),
                                content: Text("Are you sure you want to delete this game?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text("Delete", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await gameDoc.reference.delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Game deleted")),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GameDetailsPage(gameDoc: gameDoc),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
