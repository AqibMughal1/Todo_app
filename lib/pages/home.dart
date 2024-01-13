import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_app/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _noteController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  void openDialogBox({String? docId}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: docId == null ? Text('Add note') : Text('Edit note'),
              content: TextField(
                controller: _noteController,
                decoration: InputDecoration(hintText: 'Enter note'),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      if (docId != null) {
                        _firestoreService.updateNote(
                          docId,
                          _noteController.text,
                        );
                      } else {
                        _firestoreService.addNote(
                          _noteController.text,
                        );
                      }
                      _noteController.clear();
                      Navigator.pop(context);
                    },
                    child: docId == null ? Text('Add') : Text('Update')),
                ElevatedButton(
                    onPressed: () {
                      _noteController.clear();
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Notes')),
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            openDialogBox();
          },
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getNotes(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List notes = snapshot.data!.docs;

                  return ListView.builder(
                      itemBuilder: (context, index) {
                        // get individual note
                        DocumentSnapshot note = notes[index];
                        String docId = note.id;

                        Map<String, dynamic> noteData =
                            note.data() as Map<String, dynamic>;
                        String noteContent = noteData['note'];

                        return Container(
                          height: 70.0, // Adjust the height as needed
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.purple[50],
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.1), // Reduced shadow opacity
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  noteContent,
                                  style: TextStyle(
                                    fontSize: 18.0, // Increased text size
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width:
                                      16.0), // Add some spacing between icons
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _noteController.text = noteContent;
                                  openDialogBox(docId: docId);
                                },
                                color:
                                    Colors.purple, // Set button color to purple
                              ),
                              SizedBox(
                                  width: 8.0), // Adjust the gap between icons
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _firestoreService.deleteNote(docId);
                                },
                                color:
                                    Colors.purple, // Set button color to purple
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: notes.length);
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }

                return Center(child: CircularProgressIndicator());
              }),
        ));
  }
}
