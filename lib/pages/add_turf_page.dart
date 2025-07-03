import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTurfPage extends StatefulWidget {
  @override
  _AddTurfPageState createState() => _AddTurfPageState();
}

class _AddTurfPageState extends State<AddTurfPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();
  final List<String> slots = [];
  String? selectedSport;

  final List<String> sportList = ['Cricket', 'Football', 'Badminton', 'Pickleball'];

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('turfs').add({
      'name': nameController.text,
      'location': locationController.text,
      'sport': selectedSport,
      'pricePerHour': int.parse(priceController.text),
      'availableSlots': slots,
      'ownerUid': user.uid,
      'createdAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Turf added successfully')));
    Navigator.pop(context);
  }

  void _addSlot(String slot) {
    if (slot.isNotEmpty && !slots.contains(slot)) {
      setState(() => slots.add(slot));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Turf'), backgroundColor: Color(0xFF4CAF50)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Turf Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedSport,
                items: sportList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => selectedSport = v),
                decoration: InputDecoration(labelText: 'Sport'),
                validator: (value) => value == null ? 'Select sport' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Price Per Hour'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20),
              Text('Available Time Slots (e.g. 6AM - 8AM):'),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: slots.map((slot) => Chip(label: Text(slot), onDeleted: () => setState(() => slots.remove(slot)))).toList(),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Add Time Slot'),
                onFieldSubmitted: _addSlot,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Submit Turf'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
