import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageDatabase extends StatefulWidget {
  @override
  _ManageDatabaseState createState() => _ManageDatabaseState();
}

class _ManageDatabaseState extends State<ManageDatabase> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController typeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Database'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            TextFormField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: imageController,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
            TextFormField(
              controller: typeController,
              decoration: InputDecoration(labelText: 'Type'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Example: Add a room to Firestore
                FirebaseFirestore.instance.collection('rooms').add({
                  'name': nameController.text,
                  'location': locationController.text,
                  'price': int.tryParse(priceController.text) ?? 0,
                  'image': imageController.text,
                  'type': typeController.text,
                }).then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Room added successfully'),
                    ),
                  );
                  // Clear the text fields after successful submission
                  nameController.clear();
                  locationController.clear();
                  priceController.clear();
                  imageController.clear();
                  typeController.clear();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add room: $error'),
                    ),
                  );
                });
              },
              child: Text('Add Room to Database'),
            ),
          ],
        ),
      ),
    );
  }
}
