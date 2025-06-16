import 'package:bbbb/Model/place.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class UptrendController extends GetxController {
  final _db = FirebaseDatabase.instance.ref();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<bool> hasUpvoted(String placeId) async {
    if (_uid == null) {
      print("⚠️ User belum login saat cek upvote");
      return false;
    }

    final ref = _db.child("upvotes/$placeId/$_uid");
    final snap = await ref.get();

    print("🔍 Cek upvote: ${ref.path} → exists: ${snap.exists}, value: ${snap.value}");

    return snap.exists && snap.value == true;
  }

  Future<void> toggleUpvote(String placeId) async {
    if (_uid == null) {
      print("❌ Tidak bisa upvote, user belum login");
      return;
    }

    final placeRef = _db.child("tempat_wisata/$placeId");
    final voteRef = _db.child("upvotes/$placeId/$_uid");

    final voted = await hasUpvoted(placeId);

    if (voted) {
      print("🗑️ Menghapus upvote...");
      await voteRef.remove();
      await placeRef.runTransaction((data) {
        if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          final current = (map['uptrend'] ?? 0) as int;
          map['uptrend'] = (current > 0) ? current - 1 : 0;
          return Transaction.success(map);
        }
        return Transaction.abort();
      });
    } else {
      print("➕ Menambahkan upvote...");
      await voteRef.set(true);
      await placeRef.runTransaction((data) {
        if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          final current = (map['uptrend'] ?? 0) as int;
          map['uptrend'] = current + 1;
          return Transaction.success(map);
        }
        return Transaction.abort();
      });
    }
  }

  Future<PlaceModel?> getPlaceSnapshot(String placeId) async {
    final snapshot = await _db.child('tempat_wisata/$placeId').get();
    if (snapshot.exists) {
      return PlaceModel.fromMap(snapshot.value as Map, placeId);
    }
    return null;
  }

  Future<bool> checkUpvoted(String placeId) => hasUpvoted(placeId);
}
