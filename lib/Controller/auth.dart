import 'package:bbbb/Config/router.dart';
import 'package:bbbb/Model/user.dart';
import 'package:firebase_core/firebase_core.dart';
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
      // By default new user role is 'user'
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

  void logout() async {
    await _auth.signOut();
  }
}
