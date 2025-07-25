import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommentController extends GetxController {
  final _db = FirebaseDatabase.instance.ref();
    final RxBool isLoading = true.obs;

  final RxList<Map<String, dynamic>> comments = <Map<String, dynamic>>[].obs;

  // Mengambil username dari database
  Future<String> _getUsername(String uid) async {
  final snap = await _db.child("users/$uid/username").get(); 
  print("DEBUG SNAP VALUE: ${snap.value}");
  print("DEBUG UID: $uid");


  if (snap.exists && snap.value != null) {
    return snap.value.toString();
  }
  return "Anonim";
}




  // Ambil semua komentar untuk suatu tempat
  Future<void> fetchComments(String placeId) async {
    final snapshot = await _db.child("comments/$placeId").get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final result = data.entries.map((e) {
        final item = Map<String, dynamic>.from(e.value);
        return {
          'id': e.key,
          'name': item['name'],
          'comment': item['comment'],
          'time': item['time'],
          'uid': item['uid'],
        };
      }).toList();
      comments.assignAll(result.reversed.toList());
    } else {
      comments.clear();
    }
  }

  // Menambahkan komentar baru
  Future<void> addComment(String placeId, String commentText) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null || commentText.trim().isEmpty) return;

  final username = await _getUsername(uid);
  print('DEBUG USERNAME: $username'); // ✅ cek hasilnya

  final newCommentRef = _db.child("comments/$placeId").push();
  await newCommentRef.set({
    'uid': uid,
    'name': username,
    'comment': commentText,
    'time': DateTime.now().toIso8601String(),
  });

  await fetchComments(placeId);
}

Future<void> updateComment(String placeId, String commentId, String newText) async {
     try {
       await _db.child('comments').child(placeId).child(commentId).update({
         'comment': newText,
         // Anda bisa menambahkan timestamp 'updatedAt' jika perlu
       });
       // Refresh komentar setelah update
       fetchComments(placeId);
       Get.snackbar("Sukses", "Komentar berhasil diperbarui.", backgroundColor: Colors.green, colorText: Colors.white);
     } catch (e) {
       Get.snackbar("Error", "Gagal memperbarui komentar: ${e.toString()}");
     }
  }

  // Menghapus komentar
  Future<void> deleteComment(String placeId, String commentId) async {
    await _db.child("comments/$placeId/$commentId").remove();
    await fetchComments(placeId);
  }
}
