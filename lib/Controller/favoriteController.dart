import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import '../Model/place.dart';

class FavoriteController extends GetxController {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final RxList<PlaceModel> favoriteList = <PlaceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await _dbRef.child('favorites/${user.uid}').get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final loaded = data.entries.map((e) {
        final map = Map<String, dynamic>.from(e.value);
        return PlaceModel.fromMap(map, e.key);
      }).toList();

      favoriteList.assignAll(loaded);
    } else {
      favoriteList.clear();
    }
  }

  Future<void> addFavorite(PlaceModel place) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = _dbRef.child('favorites/${user.uid}/${place.id}');
    await ref.set(place.toJson());
    _loadFavorites();
  }

  Future<void> removeFavorite(String placeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = _dbRef.child('favorites/${user.uid}/$placeId');
    await ref.remove();
    _loadFavorites();
  }

  Future<bool> isFavorite(String placeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final snapshot = await _dbRef.child('favorites/${user.uid}/$placeId').get();
    return snapshot.exists;
  }
}
