import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'booking_page.dart';
import 'review_page.dart';

class DetailsRoomPage extends StatefulWidget {
  final String roomId;
  final String collectionName;

  DetailsRoomPage({required this.roomId, required this.collectionName});

  @override
  _DetailsRoomPageState createState() => _DetailsRoomPageState();
}

class _DetailsRoomPageState extends State<DetailsRoomPage> {
  double averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateAverageRating();
  }

  Future<void> _calculateAverageRating() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('room_id', isEqualTo: widget.roomId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        double totalRating = 0.0;
        int numberOfReviews = snapshot.docs.length;

        snapshot.docs.forEach((doc) {
          totalRating += doc['rating'];
        });

        setState(() {
          averageRating = totalRating / numberOfReviews;
        });
      } else {
        setState(() {
          averageRating = 0.0;
        });
      }
    } catch (error) {
      print('Error calculating average rating: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insights'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection(widget.collectionName)
            .doc(widget.roomId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Room not found'));
          }

          var roomData = snapshot.data!.data() as Map<String, dynamic>;
          var imageList = List<String>.from(roomData['images'] ?? []);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room Images Carousel
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    itemCount: imageList.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          imageList[index],
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                // Room name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    roomData['name'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8),
                // Location and Price section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Location: ${roomData['location']}',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      Text(
                        'BDT ${roomData['price'].toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Reviews and Ratings card
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListTile(
                    title: Text('Reviews and Ratings'),
                    subtitle: Row(
                      children: List.generate(5, (index) {
                        return Icon(Icons.star,
                            color: index < averageRating ? Colors.amber : Colors.grey);
                      }),
                    ),
                    trailing: FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('reviews')
                          .where('room_id', isEqualTo: widget.roomId)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return SizedBox();
                        }
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            4,
                            (index) {
                              if (index < snapshot.data!.docs.length) {
                                return CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    snapshot.data!.docs[index]
                                        ['user_profile_image'],
                                  ),
                                  radius: 15,
                                );
                              } else {
                                return CircleAvatar(
                                  backgroundImage:
                                      AssetImage('assets/user_placeholder.jpg'),
                                  radius: 15,
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReviewsPage(roomId: widget.roomId)),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                // What We Offer section (example amenities)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('What We Offer',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: <Widget>[
                            _buildOfferIcon(Icons.bed, 'Twin Bed'),
                            _buildOfferIcon(Icons.local_parking, 'Parking'),
                            _buildOfferIcon(Icons.wifi, 'WiFi'),
                            _buildOfferIcon(Icons.pool, 'Pool'),
                            _buildOfferIcon(Icons.fastfood, 'Snack'),
                            _buildOfferIcon(Icons.free_breakfast, 'Breakfast'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Description section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        roomData['description'],
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                _makePhoneCall('tel:+8801623094662');
              },
              icon: Icon(Icons.call),
              label: Text('Call Now'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingPage(roomId: widget.roomId),
                  ),
                );
              },
              icon: Icon(Icons.book),
              label: Text('Book Now'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildOfferIcon(IconData icon, String label) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 30, color: Colors.cyan),
          SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DetailsRoomPage(
      roomId: 'abc123', // Replace with actual room ID from your Firestore
      collectionName: 'rooms', // Replace with actual collection name from your Firestore
    ),
  ));
}
