import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'host_game_page.dart';
import 'join_game_page.dart';
import 'add_turf_page.dart';
import '../auth/login_page.dart';
import 'joined_games_page.dart';
import 'my_hosted_games_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = 'Player';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? user.email?.split('@')[0] ?? 'Player';
      });
    }
  }

  void _logout(BuildContext context) async {
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout', style: GoogleFonts.poppins()),
          content: Text('Are you sure you want to logout?', style: GoogleFonts.poppins()),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel', style: GoogleFonts.poppins())),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Logout', style: GoogleFonts.poppins(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
            (route) => false,
      );
    }
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.notifications, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Text('Notifications', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNotificationItem('New game invitation received', '2 min ago'),
              _buildNotificationItem('Game reminder: Football at 6 PM', '1 hour ago'),
              _buildNotificationItem('Your hosted game is full!', '3 hours ago'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Close', style: GoogleFonts.poppins())),
          ],
        );
      },
    );
  }

  Widget _buildNotificationItem(String message, String time) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF0F8F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
          SizedBox(height: 4),
          Text(time, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Color(0xFFE8F5E8),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TurfTogether',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text('Connect. Play. Enjoy.', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 16)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _logout(context),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.logout, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('games').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Column(
                            children: [
                              _buildStatCard('Games Joined', '-', Icons.sports_soccer_outlined),
                              SizedBox(height: 16),
                              _buildStatCard('Games Hosted', '-', Icons.emoji_events_outlined),
                            ],
                          );
                        }

                        final allGames = snapshot.data!.docs;
                        int gamesJoined = 0;
                        int gamesHosted = 0;

                        for (var doc in allGames) {
                          final data = doc.data() as Map<String, dynamic>;
                          final joined = List.from(data['joinedPlayers'] ?? []);
                          if (joined.any((p) => p['uid'] == currentUser?.uid)) {
                            gamesJoined++;
                          }
                          if (data['hostUid'] == currentUser?.uid) {
                            gamesHosted++;
                          }
                        }

                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => JoinedGamesPage()));
                              },
                              child: _buildStatCard('Games Joined', '$gamesJoined', Icons.sports_soccer_outlined),
                            ),
                            SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => MyHostedGamesPage()));
                              },
                              child: _buildStatCard('Games Hosted', '$gamesHosted', Icons.emoji_events_outlined),
                            ),
                          ],
                        );
                      },
                    ),

                    SizedBox(height: 32),

                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _buildActionButton('Join Games', Icons.search, () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => JoinGamePage()));
                        }),
                        _buildActionButton('Host Game', Icons.add, () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => HostGamePage()));
                        }),
                        _buildActionButton('View Profile', Icons.person_outline, () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                        }),
                        _buildActionButton('Turf Listings', Icons.list_alt, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AddTurfPage()));
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                Text(value, style: GoogleFonts.poppins(color: Color(0xFF1F2937), fontSize: 32, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Color(0xFF4CAF50), size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF0F8F0),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Color(0xFF4CAF50), size: 24),
            ),
            SizedBox(height: 12),
            Text(title, style: GoogleFonts.poppins(color: Color(0xFF1F2937), fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}