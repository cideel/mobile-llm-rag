import 'dart:convert';
import 'package:bbbb/Controller/auth.dart';
import 'package:bbbb/Controller/itineraryController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ItineraryResultPage extends StatelessWidget {
  final String itineraryText;
  final bool isFromSaved;

  const ItineraryResultPage({
    Key? key,
    required this.itineraryText,
    this.isFromSaved = false,
  }) : super(key: key);

  List<Map<String, dynamic>> extractItineraryJson(String fullResponse) {
    final jsonStart = fullResponse.indexOf('[');
    final jsonEnd = fullResponse.lastIndexOf(']') + 1;
    if (jsonStart == -1 || jsonEnd == 0) return [];
    final jsonString = fullResponse.substring(jsonStart, jsonEnd);
    try {
      final List<dynamic> data = jsonDecode(jsonString);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Parsing error: $e');
      return [];
    }
  }

  Map<int, List<Map<String, dynamic>>> groupByDay(List<Map<String, dynamic>> items) {
    final Map<int, List<Map<String, dynamic>>> grouped = {};
    for (final item in items) {
      final day = item['day'] is int ? item['day'] as int : int.tryParse('${item['day']}') ?? 1;
      grouped.putIfAbsent(day, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();
    final service = Get.put(ItineraryService());
    final itineraryList = extractItineraryJson(itineraryText);
    final grouped = groupByDay(itineraryList);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Hasil Itinerary', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: grouped.isEmpty
            ? const Center(child: Text('Gagal memuat data itinerary.'))
            : ListView(
                padding: EdgeInsets.all(16.w),
                children: grouped.entries.expand((entry) {
                  final day = entry.key;
                  final places = entry.value;
                  return [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 12.h),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.blueAccent, size: 16.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Hari ke-$day',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...List.generate(places.length, (index) {
                      final place = places[index];
                      final isLast = index == places.length - 1;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 12.w,
                                height: 12.w,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              if (!isLast)
                                Container(
                                  width: 2.w,
                                  height: 180.h,
                                  color: Colors.blueAccent.withOpacity(0.3),
                                ),
                            ],
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  place['time_activity'] ?? '',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                placeCard(place),
                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ];
                }).toList(),
              ),
        floatingActionButton: isFromSaved
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _showSaveDialog(context, service, authC),
                icon: const Icon(Icons.save),
                label: const Text('Simpan'),
                backgroundColor: Colors.blueAccent,
              ),
      ),
    );
  }

  Widget placeCard(Map<String, dynamic> place) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((place['imageUrl'] ?? '').isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                place['imageUrl'],
                height: 140.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place['title'] ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  place['address'] ?? '',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                ),
                SizedBox(height: 8.h),
                Text('Aktivitas: ${place['activity'] ?? '-'}', style: TextStyle(fontSize: 12.sp)),
                Text('Biaya: ${place['price'] ?? '-'}', style: TextStyle(fontSize: 12.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog(BuildContext context, ItineraryService service, AuthController authC) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Simpan Itinerary'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Nama itinerary'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final user = authC.userModel.value;
              await service.saveItinerary(
                name,
                itineraryText,
                user?.username ?? 'Unknown',
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Itinerary disimpan!')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
