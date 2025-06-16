// lib/controllers/tourism_controller.dart
import 'package:bbbb/Model/itinerary.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';

class TourismController extends GetxController {
  /// List semua itinerary
  final itineraries = <ItineraryModel>[].obs;
  final isLoading   = false.obs;

  /// Pastikan path ini sama dengan node di RTDB milikmu
  final _dbRef = FirebaseDatabase.instance.ref().child('itineraries');
  @override
  void onInit() {
    super.onInit();
    fetchAllItineraries();
  }

  /// Load semua itinerary
  Future<void> fetchAllItineraries() async {
    try {
      isLoading(true);
      final rootSnap = await _dbRef.get();

      if (!rootSnap.exists) {
        itineraries.clear();
        return;
      }

      final List<ItineraryModel> buffer = [];

      // Untuk tiap user
      for (final userSnap in rootSnap.children) {
        // Untuk tiap itinerary milik user itu
        for (final itSnap in userSnap.children) {
          final data = itSnap.value as Map<dynamic,dynamic>;
          // Map<dynamic,dynamic> → Map<String,dynamic>
          final map = Map<String, dynamic>.from(data);
          buffer.add(
            ItineraryModel.fromMap(map, itSnap.key!)
          );
        }
      }

      // Update obs list di satu panggil
      itineraries.assignAll(buffer);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal load itinerary: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

}
