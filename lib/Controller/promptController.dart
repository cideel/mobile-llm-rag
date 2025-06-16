import 'dart:convert';
import 'package:bbbb/Model/place.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

Future<String?> fetchItineraryFromOpenRouter(String prompt) async {
  final url = Uri.parse("https://openrouter.ai/api/v1/chat/completions");

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer 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',
      'Content-Type': 'application/json',
      'OpenRouter-Referer': 'yourdomain.com',
    },
    body: jsonEncode({
      "model": "deepseek/deepseek-chat:free",
      "messages": [
        {"role": "system", "content": "Kamu adalah asisten perjalanan."},
        {"role": "user", "content": prompt}
      ]
    }),
  );

  print("[DEBUG] Status Code: ${response.statusCode}");
  print("[DEBUG] Body: ${response.body}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final choices = data['choices'];
    if (choices != null && choices.isNotEmpty) {
      return choices[0]['message']['content'];
    } else {
      return "Tidak ada balasan dari model.";
    }
  } else {
    return "Error ${response.statusCode}: ${response.body}";
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

String buildPromptFromPlaces(List<PlaceModel> places, int durasi, String waktu, List<String> kategori) {
  final buffer = StringBuffer();
  buffer.writeln("Berikut data tempat wisata:");
  for (var p in places) {
    buffer.writeln("- ${p.title} (${p.category}) di ${p.address}, buka ${p.openHour}, tiket ${p.ticketPrice}, rating ${p.rating}, imageUrl ${p.imageUrl}");
  }

  buffer.writeln("\nBuatkan itinerary wisata Bandung selama $durasi hari, kategori: ${kategori.join(', ')}, mulai dari jam $waktu. Gunakan hanya data yang diberikan di atas.Formatkan hasilnya dalam bentuk JSON array dengan strutkur seperti ini {'title' =....,'address' = ....,'time_activity(bukan openHour anda yang membuat bukan dari database)'= ....,'activity' = ....,'price' = ..., 'imageUrl' = ....,'day' = ....} ");
  return buffer.toString();
}

Future<String?> generateItineraryWithRAG({
  required int durasi,
  required String waktuBerangkat,
  required List<String> kategori,
}) async {
  final places = await getFilteredPlaces(kategori);
  final prompt = buildPromptFromPlaces(places, durasi, waktuBerangkat, kategori);

  return await fetchItineraryFromOpenRouter(prompt); // function kirim ke LLM
}
