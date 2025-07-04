import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class TurfBookingPage extends StatefulWidget {
  final String turfId;
  final Map<String, dynamic> turfData;

  const TurfBookingPage({super.key, required this.turfId, required this.turfData});

  @override
  State<TurfBookingPage> createState() => _TurfBookingPageState();
}

class _TurfBookingPageState extends State<TurfBookingPage> {
  String? selectedSlot;
  bool isBooking = false;

  void bookSlot() async {
    if (selectedSlot == null) return;

    setState(() => isBooking = true);

    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'turfId': widget.turfId,
        'slot': selectedSlot,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Booking successful!', style: GoogleFonts.poppins()),
        backgroundColor: Colors.green,
      ));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Booking failed: $e', style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
      ));
    }

    setState(() => isBooking = false);
  }

  @override
  Widget build(BuildContext context) {
    final turf = widget.turfData;
    final slots = List<String>.from(turf['slots'] ?? []);

    return Scaffold(
      backgroundColor: Color(0xFFE8F5E8),
      appBar: AppBar(
        title: Text('Book Turf', style: GoogleFonts.poppins()),
        backgroundColor: Color(0xFF4CAF50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(turf['name'] ?? 'Turf', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(turf['location'] ?? '', style: GoogleFonts.poppins(fontSize: 16)),
            SizedBox(height: 16),
            Text('Select a Time Slot', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: slots.map((slot) {
                final isSelected = slot == selectedSlot;
                return ChoiceChip(
                  label: Text(slot, style: GoogleFonts.poppins()),
                  selected: isSelected,
                  selectedColor: Colors.green.shade300,
                  onSelected: (_) => setState(() => selectedSlot = slot),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isBooking ? null : bookSlot,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isBooking ? 'Booking...' : 'Confirm Booking',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
