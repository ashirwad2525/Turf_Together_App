import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TurfDetailsPage extends StatelessWidget {
  final DocumentSnapshot turfDoc;

  TurfDetailsPage({required this.turfDoc});

  @override
  Widget build(BuildContext context) {
    final turf = turfDoc.data() as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      appBar: AppBar(
        title: Text(turf['name'] ?? 'Turf Details', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Turf Image
            if (turf['imageUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  turf['imageUrl'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                ),
              ),
            const SizedBox(height: 20),

            _detailRow("Location", turf['location']),
            _detailRow("Sport", turf['sport']),
            _detailRow("Price/Hour", "₹${turf['pricePerHour']}"),
            _detailRow("Size", turf['size'] ?? 'N/A'), // Optional
            _detailRow("Owner UID", turf['ownerUid']),
            _detailRow("Created At", turf['createdAt']?.toDate().toString() ?? "Unknown"),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: Colors.green[700]),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(color: Colors.black87, fontSize: 16),
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
