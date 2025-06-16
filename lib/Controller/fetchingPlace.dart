import 'package:bbbb/Model/place.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';

class TempatWisataController extends GetxController {
  var places = <PlaceModel>[].obs;

  final _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://bingung-di-bandung-v2-1-default-rtdb.asia-southeast1.firebasedatabase.app',
  );
  
  @override
  void onInit() {
    fetchPlaces();
    super.onInit();
  }

  List<PlaceModel> get trendingPlaces {
  final sorted = [...places];
  sorted.sort((a, b) => b.uptrend.compareTo(a.uptrend));
  return sorted.take(3).toList(); // Top 3
}

  void fetchPlaces() async {
    final ref = FirebaseDatabase.instance.ref('tempat_wisata');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final result = data.entries.map((entry) {
        return PlaceModel.fromMap(entry.value, entry.key);
      }).toList();
      places.assignAll(result);
    }
  }

  void updateUptrendLocally(String id, int newUptrend) {
  final index = places.indexWhere((place) => place.id == id);
  if (index != -1) {
    final updatedPlace = places[index].copyWith(uptrend: newUptrend);
    places[index] = updatedPlace;
  }
}

PlaceModel? getPlaceById(String id) {
  return places.firstWhereOrNull((p) => p.id == id);
}

Future<void> refreshPlaceById(String id) async {
  final snapshot = await _db.ref('tempat_wisata/$id').get();
  if (snapshot.exists) {
    final updated = PlaceModel.fromMap(snapshot.value as Map, id);
    updateUptrendLocally(id, updated.uptrend);
  }
}


}
