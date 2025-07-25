import 'package:bbbb/Config/router.dart';
import 'package:bbbb/Model/user.dart';
import 'package:bbbb/Pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Rxn<User> firebaseUser = Rxn<User>();
  Rxn<UserModel> userModel = Rxn<UserModel>();

  final db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://bingung-di-bandung-v2-1-default-rtdb.asia-southeast1.firebasedatabase.app',
  );
  final DatabaseReference _dbRef = FirebaseDatabase
      .instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://bingung-di-bandung-v2-1-default-rtdb.asia-southeast1.firebasedatabase.app',
      )
      .ref('users');

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, handleAuthChanged);
  }

  void handleAuthChanged(User? user) async {
    if (user != null) {
      // Load user data including role
      final snapshot = await _dbRef.child(user.uid).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        userModel.value = UserModel.fromMap(data);
      }
    } else {
      userModel.value = null;
    }
  }

  Future<void> updateUsername(String newUsername) async {
    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) {
        throw ("Pengguna tidak ditemukan, silakan login ulang.");
      }

      // 1. Update username di Firebase Realtime Database
      await _dbRef.child('users').child(uid).update({
        'username': newUsername,
      });

      // 2. Update username di local state (userModel) agar UI langsung berubah
      if (userModel.value != null) {
        userModel.value!.username = newUsername;
        userModel.refresh(); // Memberi tahu GetX bahwa ada perubahan
      }

      // 3. Tampilkan notifikasi sukses
      Get.snackbar(
        'Berhasil',
        'Username berhasil diperbarui.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui username: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      // Mengarahkan ke halaman login dan menghapus semua halaman sebelumnya dari stack
      Get.offAll(() => const Login()); 
    } catch (e) {
       Get.snackbar(
        'Error',
        'Gagal melakukan logout: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
    String img = '',
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = cred.user!;
      UserModel newUser = UserModel(
        uid: user.uid,
        username: username,
        email: email,
        img: img,
        role: 'user',
      );
      await _dbRef.child(user.uid).set(newUser.toMap());
      userModel.value = newUser;
      Get.snackbar('Success', 'Akun berhasil dibuat!');
      Get.offNamed(MyPage.navBar);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      Get.snackbar('Success', 'Login berhasil!');
      Get.offNamed(MyPage.navBar);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  
}
