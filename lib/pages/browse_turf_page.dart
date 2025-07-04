import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playnation/pages/turf_details.dart';
import 'turf_details.dart'; // Ensure this file is created

class BrowseTurfsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      appBar: AppBar(
        title: Text(
          "Available Turfs",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('turfs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final turfDocs = snapshot.data!.docs;

          if (turfDocs.isEmpty) {
            return Center(
              child: Text(
                "No turfs available",
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: turfDocs.length,
            itemBuilder: (context, index) {
              final turf = turfDocs[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    turf['name'] ?? 'No Name',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        turf['location'] ?? 'No location',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sport: ${turf['sport'] ?? 'N/A'}',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      Text(
                        '₹${turf['pricePerHour']}/hr',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TurfDetailsPage(turfDoc: turfDocs[index]),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
