import 'package:bbbb/Config/color.dart';
import 'package:bbbb/Controller/promptController.dart';
import 'package:bbbb/Pages/itinerary_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ItineraryInputPage extends StatefulWidget {
  const ItineraryInputPage({super.key});

  @override
  State<ItineraryInputPage> createState() => _ItineraryInputPageState();
}

class _ItineraryInputPageState extends State<ItineraryInputPage> {
  final TextEditingController durationController = TextEditingController();
  final TextEditingController departureTimeController = TextEditingController();
  final List<String> selectedCategories = [];

  final List<String> categories = [
    "Alam",
    "Kuliner",
    "Daya Tarik Wisata",
    "Hiburan & Rekreasi"
  ];

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

  @override
  Widget build(BuildContext context) {
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
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Durasi (hari)",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              SizedBox(height: 6.h),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  hintText: "Contoh: 2",
                ),
              ),
              SizedBox(height: 16.h),
              Text("Waktu Berangkat",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              SizedBox(height: 6.h),
              TextField(
                controller: departureTimeController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  hintText: "Contoh: 07:00",
                ),
              ),
              SizedBox(height: 16.h),
              Text("Kategori Wisata (maks 3)",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: categories.map((cat) {
                  final selected = selectedCategories.contains(cat);
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) => toggleCategory(cat),
                    selectedColor: Colors.blueAccent,
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final duration = durationController.text.trim();
                    final time = departureTimeController.text.trim();

                    if (duration.isEmpty ||
                        time.isEmpty ||
                        selectedCategories.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Lengkapi semua input!")),
                      );
                      return;
                    }

                    showDialog(
                      context: context,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );

                    final result = await generateItineraryWithRAG(
                      durasi: int.tryParse(duration) ?? 1,
                      waktuBerangkat: time,
                      kategori: selectedCategories,
                    );

                    Navigator.pop(context); // tutup loading

                    if (result != null) {
                      Get.off(() => ItineraryResultPage(itineraryText: result));
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
    );
  }
}
