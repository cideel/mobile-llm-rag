import 'dart:math'; // <-- PERBAIKAN: Import library dart:math untuk random
import 'package:bbbb/Config/color.dart';
import 'package:bbbb/Controller/commentController.dart';
import 'package:bbbb/Pages/add_admin.dart';
import 'package:bbbb/Pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bbbb/Controller/fetchingPlace.dart';
import 'package:bbbb/Pages/detail_place.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

// Menggunakan StatefulWidget untuk stabilitas context dan lifecycle
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TempatWisataController tempatController =
      Get.put(TempatWisataController());

      final CommentController controller = Get.put(CommentController());


  // --- PENAMBAHAN: Helper function untuk membuat ikon kategori yang bisa diklik ---
  Widget _buildCategoryIcon(BuildContext context, String asset, String label,
      int colorHex, String categoryFilter) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke SearchPage sambil mengirim kategori sebagai filter awal
        PersistentNavBarNavigator.pushNewScreen(
          context,
          // PENTING: Pastikan SearchPage Anda bisa menerima parameter `initialCategory`
          // Contoh: SearchPage(initialCategory: categoryFilter)
          screen: SearchPage(initialCategory: categoryFilter),
          withNavBar: true,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: _typeIcon(asset, label, colorHex),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ScreenUtilInit(
        designSize: const Size(375, 854),
        builder: (context, child) => Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Bagian Header (Sapaan & Foto Profil)
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Halo, Selamat Datang!",
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500)),
                          Text("Yuk, cari tempat seru~",
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.grey[600]))
                        ],
                      ),
                      CircleAvatar(
                        backgroundColor: AppColor.componentColor,
                        child: Icon(Icons.person, size: 30.h, color: Colors.white),
                        radius: 20.r,
                      )
                    ],
                  ),
                ),
                // Bagian Banner & Search Bar
                SizedBox(
                  height: 180.h,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 1.sw,
                        height: 150.h,
                        child: Image.asset(
                          "assets/Fonts/img/img-home.png",
                          fit: BoxFit.fill,
                        ),
                      ),
                      Positioned(
                        top: 120.h,
                        left: 16.w,
                        right: 16.w,
                        child: GestureDetector(
                          onTap: () => PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: const SearchPage(),
                            withNavBar: true,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(5.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const IgnorePointer(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Mau kemana hari ini...',
                                  prefixIcon: Icon(Icons.search),
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 14.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 35.h),
                // Bagian Ikon Kategori
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // --- PERBAIKAN: Menggunakan helper function yang baru dibuat ---
                      _buildCategoryIcon(
                          context,
                          "assets/Fonts/img/img-wisata-alam.png",
                          "Alam",
                          0xFF0AA210,
                          "Alam"),
                      _buildCategoryIcon(
                          context,
                          "assets/Fonts/img/img-wisata-bu.png",
                          "Budaya",
                          0xFF2485FE,
                          "Budaya"),
                      _buildCategoryIcon(
                          context,
                          "assets/Fonts/img/img-wisata-kuliner.png",
                          "Kuliner",
                          0xFFF7B809,
                          "Kuliner"),
                      _buildCategoryIcon(
                          context,
                          "assets/Fonts/img/img-wisata-lainnya.png",
                          "Hiburan",
                          0xFFC42D2D,
                          "Hiburan & Rekreasi"),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                // Bagian Tab "Lagi Rame" & "Lagi Sepi"
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: DefaultTabController(
                      length: 1,
                      child: Column(
                        children: [
                          Container(
                            height: 50.h,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(7.r),
                                topRight: Radius.circular(7.r),
                              ),
                            ),
                            child: const TabBar(
                              indicatorColor: Colors.blueAccent,
                              indicatorWeight: 3.0,
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.white,
                              tabs: [
                                Tab(text: "Lagi Rame"),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 300.h,
                            child: TabBarView(
                              children: [
                                Obx(() {
                                  final trending =
                                      tempatController.trendingPlaces;
                                  if (trending.isEmpty) {
                                    return const Center(
                                        child:
                                            Text("Belum ada tempat populer."));
                                  }
                                  return ListView.builder(
                                    padding: EdgeInsets.all(12.w),
                                    itemCount: trending.length,
                                    itemBuilder: (context, index) {
                                      final place = trending[index];
                                      return _buildTrendingItem(
                                        onTap: () {
                                          Get.put(AdminController());
                                          PersistentNavBarNavigator
                                              .pushNewScreen(
                                            context,
                                            screen: PlaceDetailPage(
                                                placeId: place.id),
                                            withNavBar: true,
                                            pageTransitionAnimation:
                                                PageTransitionAnimation
                                                    .cupertino,
                                          );
                                        },
                                        context: context,
                                        imageUrl: place.imageUrl,
                                        title: place.title,
                                        address: place.address,
                                        rank: place.uptrend,
                                        placeId: place.id,
                                      );
                                    },
                                  );
                                }),
                                const Center(
                                    child: Text("Belum ada tempat sepi 😌")),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 35.h),
                // Judul "Rekomendasi untuk kamu"
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Rekomendasi untuk kamu",
                      style: TextStyle(
                        fontFamily: "Shipori",
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                // --- BAGIAN REKOMENDASI ---
                SizedBox(
                  height: 230.h,
                  child: Obx(() {
                    if (tempatController.places.value.isEmpty) {
                      return const Center(child: Text("Memuat data..."));
                    }

                    final allPlaces = List.of(tempatController.places.value);
                    allPlaces.shuffle(Random());
                    final randomPlaces = allPlaces.take(8).toList();

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                      itemCount: randomPlaces.length,
                      itemBuilder: (context, index) {
                        final place = randomPlaces[index];
                        return wisataCard(
                          context: context,
                          onTap: () {
                            Get.put(AdminController());
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: PlaceDetailPage(placeId: place.id),
                              withNavBar: true,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          imageUrl: place.imageUrl,
                          title: place.title,
                          address: place.address,
                          like: place.uptrend,
                          comments: controller.comments.length,
                          rating: place.rating,
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget-widget helper di luar kelas
Widget _typeIcon(String asset, String label, int colorHex) {
  return Column(
    children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r),
          color: Color(colorHex),
        ),
        height: 55.h,
        width: 55.w,
        child: Center(
          child: Image.asset(height: 30.h, width: 30.w, asset),
        ),
      ),
      SizedBox(height: 4.h),
      Text(label, style: TextStyle(fontSize: 12.sp))
    ],
  );
}

Widget _buildTrendingItem({
  required BuildContext context,
  required String imageUrl,
  required String title,
  required String address,
  required int rank,
  required String placeId,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: ListTile(
      onTap: () => PersistentNavBarNavigator.pushNewScreen(context,
          screen: PlaceDetailPage(placeId: placeId)),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.network(
          imageUrl,
          width: 50.w,
          height: 50.h,
          fit: BoxFit.cover,
          errorBuilder: (context, e, s) =>
              const Icon(Icons.image_not_supported),
        ),
      ),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
      subtitle: Text(address,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12.sp)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_drop_up, color: Colors.green, size: 20.w),
          Text('+$rank',
              style: TextStyle(color: Colors.green, fontSize: 14.sp)),
        ],
      ),
    ),
  );
}

Widget wisataCard({
  required BuildContext context,
  required String imageUrl,
  required String title,
  required String address,
  required int like,
  required int comments,
  required double rating,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: 250.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: Image.network(
              imageUrl,
              height: 120.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120.h,
                color: Colors.grey[200],
                child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14.sp)),
                SizedBox(height: 4.h),
                Text(address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildStatIcon(
                        Icons.thumb_up, like.toString(), Colors.blueAccent),
                    SizedBox(width: 10.w),
                    _buildStatIcon(Icons.comment, comments.toString(),
                        Colors.grey.shade600),
                    SizedBox(width: 10.w),
                    _buildStatIcon(
                        Icons.star, rating.toStringAsFixed(1), Colors.orange),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}

Widget _buildStatIcon(IconData icon, String text, Color color) {
  return Row(
    children: [
      Icon(icon, size: 14.sp, color: color),
      SizedBox(width: 4.w),
      Text(text,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
    ],
  );
}
