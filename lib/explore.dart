import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'details_room_page.dart'; // Import the details page

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String searchLocation = ''; // To store user's search location

  // Function to format search location
  String formatSearchLocation(String location) {
    if (location.isEmpty) return '';
    return location.substring(0, 1).toUpperCase() +
        location.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inspect Rooms'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter location...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Format and set search location
                    setState(() {});
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchLocation = value.trim();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collectionGroup('rooms')
                  .where('status', isEqualTo: false) // Fetch rooms where status is false
                  .where('location', isEqualTo: formatSearchLocation(searchLocation)) // Filter by searchLocation
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No rooms available'));
                }

                return ListView(
                  children: snapshot.data!.docs.map((room) {
                    List<String> images = List<String>.from(room['images'] ?? []);
                    String imageUrl = images.isNotEmpty ? images[0] : ''; // Use the first image as the list tile image

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsRoomPage(
                              roomId: room.id,
                              collectionName: room.reference.parent!.id,
                              // Assuming room reference contains collection name
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(room['name']),
                        subtitle: Text(room['location']),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(imageUrl),
                        ),
                        trailing: Text('BDT ${room['price']}'), // Display price directly in BDT
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
