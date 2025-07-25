import 'dart:convert';
import 'package:bbbb/Model/place.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

Future<String?> fetchItineraryFromOpenRouter(String prompt) async {
  final url = Uri.parse("https://openrouter.ai/api/v1/chat/completions");

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization':
            'Bearer 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',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "deepseek/deepseek-chat",
        "messages": [
          {
            "role": "system",
            "content":
                "Kamu adalah asisten perjalanan ahli untuk wilayah Bandung. Tugasmu adalah membuat rencana perjalanan yang detail, logis, dan relevan berdasarkan data dan instruksi yang diberikan. Selalu berikan jawaban dalam format JSON yang valid."
          },
          {"role": "user", "content": prompt}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final choices = data['choices'];
      if (choices != null && choices.isNotEmpty) {
        return choices[0]['message']['content'];
      }
    }
    return null;
  } catch (e) {
    print("Exception when calling LLM API: $e");
    return null;
  }
}

Future<List<PlaceModel>> getFilteredPlaces(List<String> kategori) async {
  final snapshot = await FirebaseDatabase.instance.ref("tempat_wisata").get();
  List<PlaceModel> places = [];

  if (snapshot.exists) {
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    data.forEach((key, value) {
      final map = Map<String, dynamic>.from(value);
      final place = PlaceModel.fromMap(map, key);
      if (kategori.contains(place.category)) {
        places.add(place);
      }
    });
  }
  return places;
}

String buildPromptFromPlaces({
  required List<PlaceModel> places,
  required int durasi,
  required String waktuBerangkat,
  required List<String> kategori,
  required int budget,
  required String transportasi,
  required int jumlahPeserta,
  String? catatan,
}) {
  final buffer = StringBuffer();
  buffer.writeln(
      "Saya ingin membuat rencana perjalanan (itinerary) di Bandung dengan detail sebagai berikut:");
  buffer.writeln("- Durasi Perjalanan: $durasi hari.");
  buffer.writeln("- Waktu Berangkat Setiap Hari: Sekitar jam $waktuBerangkat.");
  buffer.writeln("- Jumlah Peserta: $jumlahPeserta orang.");
  buffer.writeln("- Perkiraan Total Budget: Rp $budget.");
  buffer.writeln("- Mode Transportasi Utama: $transportasi.");
  buffer.writeln("- Kategori Wisata yang Diminati: ${kategori.join(', ')}.");
  if (catatan != null && catatan.isNotEmpty) {
    buffer.writeln("- Catatan Tambahan dari Saya: $catatan");
  }
  buffer.writeln("\n");

  buffer.writeln(
      "Gunakan HANYA data tempat wisata berikut sebagai sumber informasi utama Anda. Sertakan 'uid', 'imageUrl', 'rating', 'likes', dan 'commentCount' di setiap item dalam JSON final:");
  for (var p in places) {
    // --- PERBAIKAN: Memastikan semua data dikirim sebagai konteks untuk RAG ---
    buffer.writeln(
        "- uid: ${p.id}, Nama: ${p.title}, Kategori: ${p.category}, Alamat: ${p.address}, Jam Buka: ${p.openHour}, Harga Tiket: Rp ${p.ticketPrice}, imageUrl: ${p.imageUrl}, rating: ${p.rating}, likes: ${p.uptrend}, commentCount: ${p.comments}");
  }
  buffer.writeln("\n");

  buffer.writeln(
      "Berdasarkan semua informasi di atas, buatkan itinerary dalam format JSON yang valid. JSON harus memiliki struktur sebagai berikut:");
  buffer.writeln('''
{
  "summary": "Buatkan ringkasan singkat perjalanan di sini.",
  "estimated_budget": "Buatkan perkiraan total biaya perjalanan berdasarkan harga tiket dan aktivitas.",
  "itinerary": [
    {
      "uid": "id_unik_dari_tempat_yang_diberikan",
      "day": 1,
      "time_activity": "09:00 - 12:00",
      "title": "Nama Tempat Wisata",
      "address": "Alamat Lengkap",
      "activity": "Deskripsi singkat aktivitas yang bisa dilakukan di sini.",
      "category_tags": ["Alam", "Fotogenik"],
      "price": 30000,
      "imageUrl": "URL gambar tempat",
      "rating": 4.5,
      "likes": 123,
      "commentCount": 45
    }
  ]
}
''');
  buffer.writeln(
      "PENTING: Pastikan semua nilai untuk 'uid', 'title', 'address', 'imageUrl', 'rating', 'likes', dan 'commentCount' diambil persis dari data yang saya berikan di atas. Buat jadwal yang logis. Pastikan output adalah JSON yang valid tanpa teks tambahan.");

  return buffer.toString();
}

Future<String?> generateItineraryWithRAG({
  required int durasi,
  required String waktuBerangkat,
  required List<String> kategori,
  required int budget,
  required String transportasi,
  required int jumlahPeserta,
  String? catatan,
}) async {
  final places = await getFilteredPlaces(kategori);
  if (places.isEmpty) {
      return null;
  }
  final prompt = buildPromptFromPlaces(
    places: places,
    durasi: durasi,
    waktuBerangkat: waktuBerangkat,
    kategori: kategori,
    budget: budget,
    transportasi: transportasi,
    jumlahPeserta: jumlahPeserta,
    catatan: catatan,
  );
  return await fetchItineraryFromOpenRouter(prompt);
}
