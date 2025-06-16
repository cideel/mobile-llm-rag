// lib/views/all_itineraries_page.dart
import 'package:bbbb/Config/color.dart';
import 'package:bbbb/Controller/tourismController.dart';
import 'package:bbbb/Model/itinerary.dart';
import 'package:bbbb/Pages/itinerary_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AllItinerariesPage extends StatelessWidget {
  final TourismController ctrl = Get.find<TourismController>();

  /// Formats a DateTime or ISO8601 string to "15 Juni 2025"
  String _formatTanggal(dynamic dateValue) {
    DateTime dt;
    if (dateValue is DateTime) {
      dt = dateValue;
    } else if (dateValue is String) {
      try {
        dt = DateTime.parse(dateValue);
      } catch (_) {
        return dateValue.split('T').first;
      }
    } else {
      return dateValue.toString();
    }
    try {
      return DateFormat('d MMMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return dt.toIso8601String().split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Semua Itinerary',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.itineraries.isEmpty) {
          return Center(
            child: Text(
              'Belum ada itinerary.',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ctrl.fetchAllItineraries(),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
            itemCount: ctrl.itineraries.length,
            itemBuilder: (context, index) {
              final ItineraryModel it = ctrl.itineraries[index];
              return Container(
                
                child: Card(  
                
                  color: Colors.white,
                  
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: const Color.fromARGB(255, 180, 180, 180)),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 12.h),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () => Get.to(
                      () => ItineraryResultPage(
                        itineraryText: it.content,
                        isFromSaved: true,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24.r,
                            backgroundColor: Colors.blueAccent,
                            child: Text(
                              it.username.isNotEmpty
                                  ? it.username[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  it.name,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Dari: ${it.username}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  _formatTanggal(it.createdAt),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
