import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  Future<void> addNote(String note) {
    return notes.add({
      'note': note,
      'created': Timestamp.now(),
      'updated': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getNotes() {
    return notes.orderBy('created', descending: true).snapshots();
  }

  Future<void> updateNote(
    String id,
    String note,
  ) {
    return notes.doc(id).update({
      'note': note,
      'updated': Timestamp.now(),
    });
  }

  Future<void> deleteNote(
    String id,
  ) {
    return notes.doc(id).delete();
  }
}
