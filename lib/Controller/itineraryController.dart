import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ItineraryService {
  final db = FirebaseDatabase.instance;
  final auth = FirebaseAuth.instance;

  Future<void> saveItinerary(String name, String content,String username) async {
    final user = auth.currentUser;
    if (user == null) return;

    final ref = db.ref('itineraries/${user.uid}').push();
    await ref.set({
      'name': name,
      'content': content,
      'createdAt': DateTime.now().toIso8601String(),
      'username' : username
    });
  }

  Future<void> updateName(String id, String name) async {
    final user = auth.currentUser;
    if (user == null) return;
    await db.ref('itineraries/${user.uid}/$id/name').set(name);
  }

  Future<void> deleteItinerary(String id) async {
    final user = auth.currentUser;
    if (user == null) return;
    await db.ref('itineraries/${user.uid}/$id').remove();
  }
}