import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot gameDoc;

  GameDetailsPage({required this.gameDoc});

  @override
  Widget build(BuildContext context) {
    final game = gameDoc.data() as Map<String, dynamic>;
    final joinedPlayers = List<Map<String, dynamic>>.from(game['joinedPlayers'] ?? []);

    return Scaffold(
      backgroundColor: Color(0xFFE8F5E8),
      appBar: AppBar(
        backgroundColor: Color(0xFF4CAF50),
        elevation: 2,
        title: Text(
          'Game Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // Game Info Card
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(Icons.sports_soccer, 'Sport', game['sport']),
                  _infoRow(Icons.calendar_today_outlined, 'Date', game['date']),
                  _infoRow(Icons.access_time, 'Time', game['time']),
                  _infoRow(Icons.location_on_outlined, 'Location', game['location']),
                  _infoRow(Icons.group_outlined, 'Max Players', game['maxPlayers'].toString()),
                  _infoRow(Icons.email_outlined, 'Host Email', game['hostEmail']),
                ],
              ),
            ),
            SizedBox(height: 28),

            // Joined Players Section
            Text(
              'Joined Players (${joinedPlayers.length})',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
            SizedBox(height: 12),

            ...joinedPlayers.map((player) {
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFF4CAF50),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    player['name'] ?? player['email'] ?? 'Unknown Player',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'UID: ${player['uid']}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF4CAF50)),
          SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
