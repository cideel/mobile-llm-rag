import 'package:bbbb/Pages/add_admin.dart';
import 'package:bbbb/Pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bbbb/Controller/fetchingPlace.dart';
import 'package:bbbb/Pages/detail_place.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class Home extends StatelessWidget {
  final tempatController = Get.put(TempatWisataController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ScreenUtilInit(
        designSize: Size(375, 854),
        builder: (context, child) => Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: SingleChildScrollView(
              child: Column(
                children: [
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
                          backgroundImage: NetworkImage(
                              "https://i.pravatar.cc/150?u=default"),
                          radius: 20.r,
                        )
                      ],
                    ),
                  ),
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
  screen: SearchPage(),
  withNavBar: true, // jika ingin tanpa bottom nav bar
  pageTransitionAnimation: PageTransitionAnimation.cupertino,
),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(5.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: IgnorePointer(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Mau kemana hari ini...',
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.r),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 14.h),
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _typeIcon("assets/Fonts/img/img-wisata-alam.png",
                            "Alam", 0xFF0AA210),
                        _typeIcon("assets/Fonts/img/img-wisata-bu.png",
                            "Budaya", 0xFF2485FE),
                        _typeIcon("assets/Fonts/img/img-wisata-kuliner.png",
                            "Kuliner", 0xFFF7B809),
                        _typeIcon("assets/Fonts/img/img-wisata-lainnya.png",
                            "Lainnya", 0xFFC42D2D),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            Container(
                              constraints: BoxConstraints.expand(height: 50.h),
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4.r),
                                  topRight: Radius.circular(4.r),
                                ),
                              ),
                              child: const TabBar(
                                indicatorColor: Colors.transparent,
                                labelColor: Colors.black,
                                unselectedLabelColor: Colors.grey,
                                tabs: [
                                  Tab(text: "Lagi Rame"),
                                  Tab(text: "Lagi Sepi"),
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
                                      return Center(
                                          child: Text(
                                              "Belum ada tempat populer."));
                                    }
                                    return ListView.builder(
                                      padding: EdgeInsets.all(12.w),
                                      itemCount: trending.length,
                                      itemBuilder: (context, index) {
                                        final place = trending[index];
                                        return _buildTrendingItem(
                                          imageUrl: place.imageUrl,
                                          title: place.title,
                                          address: place.address,
                                          rank: place.uptrend,
                                        );
                                      },
                                    );
                                  }),
                                  Center(
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Rekomendasi untuk kamu",
                        style: TextStyle(
                          fontFamily: "Shipori",
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Obx(() {
                      if (tempatController.places.isEmpty) {
                        return Text("Memuat data...");
                      }
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: tempatController.places.map((place) {
                            return wisataCard(
                              onTap: () {
                                Get.put(AdminController(), permanent: true);

                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: PlaceDetailPage(placeId: place.id),
                                  withNavBar:
                                      true, 
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                              imageUrl: place.imageUrl,
                              title: place.title,
                              address: place.address,
                              like: place.like,
                              comments: place.comments,
                              rating: place.rating,
                              distanceKm: place.distanceKm,
                            );
                          }).toList(),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
  required String imageUrl,
  required String title,
  required String address,
  required int rank,
}) {
  final validImageUrl = (imageUrl.isNotEmpty)
      ? imageUrl
      : "https://via.placeholder.com/100"; // fallback aman
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.network(
          imageUrl,
          width: 50.w,
          height: 50.w,
          fit: BoxFit.cover,
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
  required String imageUrl,
  required String title,
  required String address,
  required int like,
  required int comments,
  required double rating,
  required double distanceKm,
  required VoidCallback onTap,
}) {
  final validImageUrl = (imageUrl.isNotEmpty)
      ? imageUrl
      : "https://via.placeholder.com/250"; // fallback default
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.h),
      child: Container(
        width: 250,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 3,
              offset: Offset(0, 1),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    child: Icon(Icons.favorite_border, color: Colors.grey),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 4),
                  Text(address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(Icons.arrow_drop_up,
                            color: Colors.green, size: 18),
                        Text('$like', style: TextStyle(color: Colors.green)),
                      ]),
                      Row(children: [
                        Icon(Icons.comment, size: 16, color: Colors.grey),
                        SizedBox(width: 2),
                        Text('$comments'),
                      ]),
                      Row(children: [
                        Icon(Icons.star, size: 16, color: Colors.orange),
                        SizedBox(width: 2),
                        Text('$rating'),
                      ]),
                      Row(children: [
                        Icon(Icons.location_on, size: 16, color: Colors.red),
                        SizedBox(width: 2),
                        Text('${distanceKm.toStringAsFixed(1)} km'),
                      ]),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}
