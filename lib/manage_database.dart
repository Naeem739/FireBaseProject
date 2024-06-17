import 'package:flutter/material.dart';
import 'manage_database_page.dart';

class ManageDatabase extends StatelessWidget {
  final List<Map<String, dynamic>> sections = [
    {
      'title': 'Insert Rooms', // Renamed from 'Featured Room'
      'collection': 'rooms', // Updated collection name
      'fields': ['name', 'location','price', 'description', 'image','status'],
      'color': Colors.blueAccent,
    },
    {
      'title': 'User List',
      'collection': 'users_profile',
      'fields': ['name', 'email', 'phone', 'image'],
      'color': Color.fromARGB(255, 167, 20, 212),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Database'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: sections.length,
          itemBuilder: (context, index) {
            var section = sections[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManageDatabasePage(
                        title: section['title'],
                        collection: section['collection'],
                        fields: section['fields'],
                      ),
                    ),
                  );
                },
                child: Card(
                  color: section['color'],
                  child: Container(
                    width: 200,
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          section['title'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}