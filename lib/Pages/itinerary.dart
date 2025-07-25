import 'package:bbbb/Config/color.dart';
import 'package:bbbb/Controller/promptController.dart';
import 'package:bbbb/Pages/itinerary_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ItineraryInputPage extends StatefulWidget {
  const ItineraryInputPage({super.key});

  @override
  State<ItineraryInputPage> createState() => _ItineraryInputPageState();
}

class _ItineraryInputPageState extends State<ItineraryInputPage> {
  // --- KONTROLER LAMA ---
  final TextEditingController durationController = TextEditingController();
  final TextEditingController departureTimeController = TextEditingController();
  final List<String> selectedCategories = [];

  // --- KONTROLER BARU ---
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController participantsController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  String? selectedTransportation; // Menggunakan String untuk single choice

  // --- DATA UNTUK PILIHAN ---
  final List<String> categories = [
    "Alam",
    "Kuliner",
    "Daya Tarik Wisata",
    "Hiburan & Rekreasi"
  ];

  final List<String> transportationModes = [
    "Mobil Pribadi",
    "Motor",
    "Transportasi Umum",
    "Jalan Kaki"
  ];


  // --- LOGIKA UNTUK PILIHAN KATEGORI ---
  void toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        if (selectedCategories.length < 3) {
          selectedCategories.add(category);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Maksimal memilih 3 kategori")),
          );
        }
      }
    });
  }

  // --- LOGIKA BARU UNTUK PILIHAN TRANSPORTASI (SINGLE CHOICE) ---
  void selectTransportation(String mode) {
    setState(() {
      selectedTransportation = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Helper widget untuk membuat input field agar tidak duplikasi kode
    Widget _buildTextField({
      required TextEditingController controller,
      required String label,
      required String hint,
      required TextInputType keyboardType,
      List<TextInputFormatter>? formatters,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          SizedBox(height: 6.h),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: formatters,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r)),
              hintText: hint,
            ),
          ),
        ],
      );
    }

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Buat Itinerary",
              style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        // Menggunakan SingleChildScrollView agar form bisa di-scroll
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: durationController,
                  label: "Durasi (hari)",
                  hint: "Contoh: 2",
                  keyboardType: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly]
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: departureTimeController,
                  label: "Waktu Berangkat",
                  hint: "Contoh: 07:00",
                  keyboardType: TextInputType.datetime,
                ),

                // --- INPUT BARU DITAMBAHKAN DI SINI ---
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: budgetController,
                  label: "Budget Perkiraan (Rp)",
                  hint: "Contoh: 500000",
                  keyboardType: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly]
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: participantsController,
                  label: "Jumlah Peserta",
                  hint: "Contoh: 2",
                  keyboardType: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly]
                ),

                SizedBox(height: 16.h),
                Text("Mode Transportasi",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: transportationModes.map((mode) {
                    final selected = selectedTransportation == mode;
                    return ChoiceChip(
                      label: Text(mode),
                      selected: selected,
                      onSelected: (_) => selectTransportation(mode),
                      selectedColor: Colors.blueAccent,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
                // --- AKHIR DARI INPUT BARU ---


                SizedBox(height: 16.h),
                Text("Kategori Wisata (maks 3)",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: categories.map((cat) {
                    final selected = selectedCategories.contains(cat);
                    return ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      onSelected: (_) => toggleCategory(cat),
                      selectedColor: Colors.blueAccent,
                       labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
                ),

                // --- INPUT CATATAN TAMBAHAN ---
                 SizedBox(height: 16.h),
                _buildTextField(
                  controller: notesController,
                  label: "Catatan Tambahan (Opsional)",
                  hint: "Contoh: Suka tempat yang sepi, tidak suka pedas, cari tempat foto-foto...",
                  keyboardType: TextInputType.multiline,
                ),


                SizedBox(height: 40.h), // Menggantikan Spacer
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final duration = durationController.text.trim();
                      final time = departureTimeController.text.trim();
                      
                      // Mengambil data dari field baru
                      final budget = budgetController.text.trim();
                      final participants = participantsController.text.trim();
                      final notes = notesController.text.trim();

                      if (duration.isEmpty ||
                          time.isEmpty ||
                          selectedCategories.isEmpty ||
                          budget.isEmpty ||
                          participants.isEmpty ||
                          selectedTransportation == null
                          ) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Lengkapi semua input (kecuali catatan)!")),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                        barrierDismissible: false,
                      );

                      // --- Memanggil fungsi RAG dengan parameter baru ---
                      final result = await generateItineraryWithRAG(
                        durasi: int.tryParse(duration) ?? 1,
                        waktuBerangkat: time,
                        kategori: selectedCategories,
                        budget: int.tryParse(budget) ?? 0,
                        transportasi: selectedTransportation ?? 'Mobil Pribadi',
                        jumlahPeserta: int.tryParse(participants) ?? 1,
                        catatan: notes,
                      );

                      Navigator.pop(context); // tutup loading

                      if (result != null) {
                        Get.to(() => ItineraryResultPage(itineraryText: result));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Gagal mendapatkan itinerary")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      backgroundColor: AppColor.componentColor,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text("Buat Itinerary",
                        style: TextStyle(fontSize: 15.sp, color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
