import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageDatabasePage extends StatefulWidget {
  final String title;
  final String collection;
  final List<String> fields;

  ManageDatabasePage({
    required this.title,
    required this.collection,
    required this.fields,
  });

  @override
  _ManageDatabasePageState createState() => _ManageDatabasePageState();
}

class _ManageDatabasePageState extends State<ManageDatabasePage> {
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    for (String field in widget.fields) {
      controllers[field] = TextEditingController();
    }
    // Initialize controller for Status field
    controllers['status'] = TextEditingController();
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showDialog({DocumentSnapshot? doc, required bool isEditing}) {
    if (isEditing && doc != null) {
      for (String field in widget.fields) {
        controllers[field]!.text = doc[field].toString();
      }
      controllers['status']!.text = doc['status'].toString();
    } else {
      controllers.forEach((key, controller) {
        controller.clear();
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${isEditing ? 'Edit' : 'Add'} ${widget.title}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...widget.fields.map((field) {
                  return TextFormField(
                    controller: controllers[field],
                    decoration: InputDecoration(labelText: field.capitalize()),
                    keyboardType: field == 'price' || field == 'phone'
                        ? TextInputType.number
                        : TextInputType.text,
                  );
                }).toList(),
                // Add TextFormField for Status field
                
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> data = {};
                widget.fields.forEach((field) {
                  if (field == 'price' || field == 'phone') {
                    data[field] = int.tryParse(controllers[field]!.text) ?? 0;
                  } else {
                    data[field] = controllers[field]!.text;
                  }
                });
                // Add Status field to data map
                data['status'] = controllers['status']!.text == 'true';

                if (isEditing && doc != null) {
                  FirebaseFirestore.instance
                      .collection(widget.collection)
                      .doc(doc.id)
                      .update(data)
                      .then((_) {
                    Navigator.pop(context);
                  });
                } else {
                  FirebaseFirestore.instance.collection(widget.collection).add(data).then((docRef) {
                    // Update the document with the room_id
                    FirebaseFirestore.instance
                        .collection(widget.collection)
                        .doc(docRef.id)
                        .update({'room_id': docRef.id}).then((_) {
                      Navigator.pop(context);
                    });
                  });
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection(widget.collection).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var documents = snapshot.data!.docs;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Room ID')),
                        ...widget.fields.map((field) => DataColumn(label: Text(field.capitalize()))),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: documents.map((doc) {
                        return DataRow(cells: [
                          DataCell(Text(doc.id)), // Display room_id
                          ...widget.fields.map((field) => DataCell(Text(doc[field]?.toString() ?? ''))).toList(),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _showDialog(doc: doc, isEditing: true);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  FirebaseFirestore.instance.collection(widget.collection).doc(doc.id).delete();
                                },
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialog(isEditing: false);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}