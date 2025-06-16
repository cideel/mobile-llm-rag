import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RatingService {
  final _db = FirebaseDatabase.instance.ref();
  final _uid = FirebaseAuth.instance.currentUser?.uid;

  Future<void> submitRating(String placeId, double rating) async {
    if (_uid == null) return;

    // Simpan rating user
    await _db.child("ratings/$placeId/$_uid").set(rating);

    // Ambil semua rating user
    final snap = await _db.child("ratings/$placeId").get();
    if (snap.exists) {
      final data = Map<String, dynamic>.from(snap.value as Map);
      final values = data.values.map((v) => (v as num).toDouble()).toList();

      final total = values.reduce((a, b) => a + b);
      final average = total / values.length;

      // Update rata-rata rating ke tempat_wisata
      await _db
          .child("tempat_wisata/$placeId/rating")
          .set(double.parse(average.toStringAsFixed(1))); // maksimal 1 desimal
    }
  }
}

