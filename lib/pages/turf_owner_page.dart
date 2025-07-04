import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'add_turf_page.dart';

class TurfOwnerPage extends StatelessWidget {
  final VoidCallback onBack;

  TurfOwnerPage({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Turf Owner Panel', style: GoogleFonts.poppins()),
        backgroundColor: Color(0xFF4CAF50),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AddTurfPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              ),
              icon: Icon(Icons.add),
              label: Text('Add New Turf', style: GoogleFonts.poppins(fontSize: 16)),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('turfs')
                    .where('ownerUid', isEqualTo: currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final turfs = snapshot.data!.docs;

                  if (turfs.isEmpty) {
                    return Center(
                      child: Text(
                        'No turfs listed yet.',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: turfs.length,
                    itemBuilder: (context, index) {
                      final turf = turfs[index].data() as Map<String, dynamic>;

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(turf['name'] ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            '${turf['sport']} • ₹${turf['pricePerHour']} per hour\n${turf['location']}',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                          isThreeLine: true,
                          trailing: Icon(Icons.sports),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            SizedBox(height: 16),

            // 🔁 Switch to Player Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Switch to Player Section', style: GoogleFonts.poppins()),
                Switch(
                  value: true,
                  activeColor: Color(0xFF4CAF50),
                  onChanged: (val) {
                    if (!val) onBack(); // Switch off => go back to player view
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
