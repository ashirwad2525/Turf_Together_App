import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';

class AddTurfPage extends StatefulWidget {
  @override
  _AddTurfPageState createState() => _AddTurfPageState();
}

class _AddTurfPageState extends State<AddTurfPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final slotController = TextEditingController();
  final List<String> slots = [];
  List<File> selectedImages = [];
  String? selectedSport;
  bool isLoading = false;

  final List<String> sportList = ['Cricket', 'Football', 'Badminton', 'Pickleball'];

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        selectedImages = pickedFiles.map((e) => File(e.path)).toList();
      });
    }
  }

  Future<List<String>> _uploadImages(String turfId) async {
    List<String> imageUrls = [];
    for (int i = 0; i < selectedImages.length; i++) {
      final file = selectedImages[i];
      final ref = FirebaseStorage.instance.ref().child('turf_images/$turfId/image_$i.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      imageUrls.add(url);
    }
    return imageUrls;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select images')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isLoading = true);

    try {
      // 1. Create turf document without images
      final docRef = await FirebaseFirestore.instance.collection('turfs').add({
        'name': nameController.text.trim(),
        'location': locationController.text.trim(),
        'sport': selectedSport,
        'pricePerHour': int.parse(priceController.text),
        'description': descriptionController.text.trim(),
        'availableSlots': slots,
        'ownerUid': user.uid,
        'createdAt': Timestamp.now(),
      });

      // 2. Upload images to Firebase Storage
      final imageUrls = await _uploadImages(docRef.id);

      // 3. Update turf document with image URLs
      await docRef.update({'images': imageUrls});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Turf added successfully')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _addSlot(String slot) {
    if (slot.isNotEmpty && !slots.contains(slot)) {
      setState(() => slots.add(slot));
      slotController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Turf", style: GoogleFonts.poppins()),
        backgroundColor: Color(0xFF4CAF50),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(nameController, 'Turf Name', Icons.title),
              _buildTextField(locationController, 'Location', Icons.location_on),
              _buildDropdown(),
              _buildTextField(priceController, 'Price Per Hour', Icons.currency_rupee, isNumber: true),
              _buildTextField(descriptionController, 'Turf Description', Icons.description, maxLines: 3),

              SizedBox(height: 16),
              Text('Available Time Slots', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: slots
                    .map((slot) => Chip(
                  label: Text(slot),
                  onDeleted: () => setState(() => slots.remove(slot)),
                ))
                    .toList(),
              ),
              TextFormField(
                controller: slotController,
                decoration: InputDecoration(labelText: 'Add Time Slot (e.g. 6AM - 8AM)'),
                onFieldSubmitted: _addSlot,
              ),

              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: Icon(Icons.image),
                label: Text('Select Turf Images'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              if (selectedImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text("${selectedImages.length} image(s) selected", style: GoogleFonts.poppins()),
                ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text("Submit Turf", style: GoogleFonts.poppins(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedSport,
      items: sportList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (v) => setState(() => selectedSport = v),
      decoration: InputDecoration(
        labelText: 'Select Sport',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => value == null ? 'Please select a sport' : null,
    );
  }
}
