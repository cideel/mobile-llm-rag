import 'dart:convert';
import 'package:bbbb/Config/color.dart';
import 'package:bbbb/Controller/auth.dart';
import 'package:bbbb/Controller/itineraryController.dart';
import 'package:bbbb/Pages/add_admin.dart';
import 'package:bbbb/Pages/detail_place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

// --- DATA MODEL UNTUK MENAMPUNG HASIL PARSING JSON ---
class ItineraryResponse {
  final String summary;
  final String estimatedBudget;
  final List<Map<String, dynamic>> itinerary;

  ItineraryResponse({
    required this.summary,
    required this.estimatedBudget,
    required this.itinerary,
  });

  factory ItineraryResponse.empty() {
    return ItineraryResponse(
        summary: "Tidak ada ringkasan.",
        estimatedBudget: "Tidak ada estimasi.",
        itinerary: []);
  }
}

class ItineraryResultPage extends StatelessWidget {
  final String itineraryText;
  final bool isFromSaved;

  const ItineraryResultPage({
    Key? key,
    required this.itineraryText,
    this.isFromSaved = false,
  }) : super(key: key);

  // --- FUNGSI PARSING JSON YANG ROBUST ---
  ItineraryResponse parseItineraryResponse(String fullResponse) {
    try {
      String cleanedResponse =
          fullResponse.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> data = jsonDecode(cleanedResponse);

      return ItineraryResponse(
        summary: data['summary'] ?? "Ringkasan tidak tersedia.",
        estimatedBudget:
            data['estimated_budget']?.toString() ?? "Budget tidak tersedia.",
        itinerary: List<Map<String, dynamic>>.from(data['itinerary'] ?? []),
      );
    } catch (e) {
      debugPrint('JSON Parsing error: $e');
      return ItineraryResponse.empty();
    }
  }

  // --- FUNGSI UNTUK MENGELOMPOKKAN ITINERARY BERDASARKAN HARI ---
  Map<int, List<Map<String, dynamic>>> groupByDay(
      List<Map<String, dynamic>> items) {
    final Map<int, List<Map<String, dynamic>>> grouped = {};
    for (final item in items) {
      final day = item['day'] is int
          ? item['day'] as int
          : int.tryParse('${item['day']}') ?? 1;
      grouped.putIfAbsent(day, () => []).add(item);
    }
    return Map.fromEntries(
        grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();
    final service = Get.put(ItineraryService());

    final itineraryData = parseItineraryResponse(itineraryText);
    final groupedItinerary = groupByDay(itineraryData.itinerary);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              
              centerTitle: true,
              title: const Text('Hasil Itinerary',
                  style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.black),
              pinned: true,
              floating: true,
            ),
            if (itineraryData.itinerary.isEmpty)
              const SliverFillRemaining(
                child: Center(
                    child:
                        Text('Gagal memuat atau mem-parsing data itinerary.')),
              )
            else ...[
              SliverToBoxAdapter(
                child: _buildSummaryCard(itineraryData),
              ),
              ...groupedItinerary.entries.map((entry) {
                final day = entry.key;
                final places = entry.value;
                return SliverMainAxisGroup(
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyDayHeaderDelegate('Hari ke-$day'),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final place = places[index];
                          final isLastInDay = index == places.length - 1;
                          return _buildTimelineTile(context,place, isLastInDay);
                        },
                        childCount: places.length,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ],
        ),
        floatingActionButton: isFromSaved || itineraryData.itinerary.isEmpty
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _showSaveDialog(context, service, authC),
                icon: const Icon(Icons.save,color: Colors.white,),
                label: const Text('Simpan',style: TextStyle(color: Colors.white),),
                backgroundColor: AppColor.componentColor,
              ),
      ),
    );
  }

  Widget _buildSummaryCard(ItineraryResponse data) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
          side: BorderSide(color: Colors.grey)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ringkasan Perjalanan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              data.summary,
              style: TextStyle(
                  fontSize: 14.sp, color: Colors.grey[700], height: 1.5),
            ),
            const Divider(height: 24, thickness: 1),
            Row(
              children: [
                Icon(Icons.wallet, color: AppColor.componentColor, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  "Estimasi Budget:",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                const Spacer(),
                Text(
                  NumberFormat.currency(
                          locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                      .format(double.tryParse(data.estimatedBudget
                              .replaceAll(RegExp(r'[^0-9]'), '')) ??
                          0),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                    color: AppColor.componentColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTile(
      BuildContext context, Map<String, dynamic> place, bool isLast) {
    return Padding(
      padding: EdgeInsets.only(left: 12.w, right: 12.w),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 40.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.componentColor,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2.w,
                        color: AppColor.componentColor.withOpacity(0.3),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 16.h : 24.h, top: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place['time_activity'] ?? 'Waktu tidak tersedia',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildActivityCard(context, place),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, Map<String, dynamic> place) {
    List<String> tags = (place['category_tags'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final priceValue = place['price'];
    String priceText = 'Gratis';
    if (priceValue is num && priceValue > 0) {
      priceText = NumberFormat.currency(
              locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
          .format(priceValue);
    } else if (priceValue is String &&
        double.tryParse(priceValue.replaceAll(RegExp(r'[^0-9]'), '')) != null) {
      double parsedPrice =
          double.tryParse(priceValue.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (parsedPrice > 0) {
        priceText = NumberFormat.currency(
                locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
            .format(parsedPrice);
      }
    }

    return InkWell(
      // Menggunakan InkWell untuk efek ripple saat diklik
      onTap: () {
        final String? placeId = place['uid'];
        if (placeId != null && placeId.isNotEmpty) {
          Get.put(AdminController(), permanent: true);

          // --- NAVIGASI KE HALAMAN DETAIL ---
          // Pastikan Anda sudah membuat DetailPlacePage yang menerima placeId

          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: PlaceDetailPage(placeId: placeId),
            withNavBar: true,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        } else {
          Get.put(AdminController(), permanent: true);

          Get.snackbar(
              'Error Navigasi', 'ID tempat tidak tersedia untuk dibuka.',
              snackPosition: SnackPosition.BOTTOM);
        }
      },
      borderRadius: BorderRadius.circular(12.r), // Menyesuaikan bentuk ripple
      child: Card(
        color: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.9),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((place['imageUrl'] ?? '').isNotEmpty)
              Image.network(
                place['imageUrl'],
                height: 150.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150.h,
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported,
                      color: Colors.grey[400], size: 40.sp),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place['title'] ?? 'Tanpa Judul',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Colors.black87),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    place['address'] ?? 'Alamat tidak tersedia',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Divider(height: 20, thickness: 1),
                  _buildStatsRow(
                    // --- MENAMPILKAN STATS ---
                    rating: (place['rating'] as num?)?.toDouble() ?? 0.0,
                    likes: (place['likes'] as num?)?.toInt() ?? 0,
                    comments: (place['commentCount'] as num?)?.toInt() ?? 0,
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Text(
                    'Aktivitas: ${place['activity'] ?? '-'}',
                    style: TextStyle(fontSize: 13.sp, height: 1.4),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Biaya: $priceText',
                    style:
                        TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                  if (tags.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: tags
                          .map((tag) => Chip(
                                label: Text(tag,
                                    style: TextStyle(
                                        fontSize: 11.sp,
                                        color: AppColor.componentColor,
                                        fontWeight: FontWeight.w500)),
                                backgroundColor:
                                    AppColor.componentColor.withOpacity(0.1),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 4.h),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                side: BorderSide(
                                    color: AppColor.componentColor
                                        .withOpacity(0.2)),
                              ))
                          .toList(),
                    )
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER BARU UNTUK STATS ---
  Widget _buildStatsRow(
      {required double rating, required int likes, required int comments}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildStatItem(
            Icons.star_rounded, rating.toStringAsFixed(1), Colors.orange),
        SizedBox(
          width: 20.w,
        ),
        _buildStatItem(Icons.thumb_up_alt_rounded, likes.toString(),
            AppColor.componentColor),
        SizedBox(
          width: 20.w,
        ),
        _buildStatItem(
            Icons.comment_rounded, comments.toString(), Colors.grey.shade600),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18.sp),
        SizedBox(width: 5.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showSaveDialog(
      BuildContext context, ItineraryService service, AuthController authC) {
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
                user?.username ?? 'unknown_uid',
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

class _StickyDayHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;

  _StickyDayHeaderDelegate(this.title);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(Icons.calendar_today,
              color: AppColor.componentColor, size: 16.sp),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.componentColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48.h;

  @override
  double get minExtent => 48.h;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
