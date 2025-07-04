// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class BookTurfPage extends StatefulWidget {
//   final String turfId;
//   final String turfName;
//
//   BookTurfPage({required this.turfId, required this.turfName});
//
//   @override
//   _BookTurfPageState createState() => _BookTurfPageState();
// }
//
// class _BookTurfPageState extends State<BookTurfPage> {
//   DateTime? selectedDate;
//   String? selectedSlot;
//
//   List<String> timeSlots = [
//     '6:00 AM - 7:00 AM',
//     '7:00 AM - 8:00 AM',
//     '5:00 PM - 6:00 PM',
//     '6:00 PM - 7:00 PM',
//     '7:00 PM - 8:00 PM'
//   ];
//
//   final user = FirebaseAuth.instance.currentUser;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Book ${widget.turfName}"),
//         backgroundColor: Color(0xFF4CAF50),
//       ),
//       backgroundColor: Color(0xFFE8F5E8),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             // Date Picker
//             TextFormField(
//               readOnly: true,
//               decoration: InputDecoration(labelText: 'Select Date'),
//               onTap: () async {
//                 final picked = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime.now(),
//                   lastDate: DateTime(2100),
//                 );
//                 if (picked != null) setState(() => selectedDate = picked);
//               },
//               controller: TextEditingController(
//                 text: selectedDate == null
//                     ? ''
//                     : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
//               ),
//             ),
//             SizedBox(height: 16),
//
//             // Time slot dropdown
//             DropdownButtonFormField<String>(
//               value: selectedSlot,
//               decoration: InputDecoration(labelText: 'Select Time Slot'),
//               items: timeSlots.map((slot) {
//                 return DropdownMenuItem(value: slot, child: Text(slot));
//               }).toList(),
//               onChanged: (value) => setState(() => selectedSlot = value),
//             ),
//             SizedBox(height: 32),
//
//             ElevatedButton(
//               onPressed: () async {
//                 if (selectedDate == null || selectedSlot == null || user == null) {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content: Text("Please select date and time."),
//                   ));
//                   return;
//                 }
//
//                 final formattedDate =
//                     '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
//
//                 final bookingData = {
//                   'turfId': widget.turfId,
//                   'turfName': widget.turfName,
//                   'userId': user.uid,
//                   'userEmail': user.email,
//                   'date': formattedDate,
//                   'timeSlot': selectedSlot,
//                   'timestamp': Timestamp.now(),
//                 };
//
//                 // Save to Firestore
//                 await FirebaseFirestore.instance
//                     .collection('bookings')
//                     .add(bookingData);
//
//                 ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Booking Confirmed!")));
//
//                 Navigator.pop(context);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xFF4CAF50),
//                 padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
//               ),
//               child: Text("Confirm Booking"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
