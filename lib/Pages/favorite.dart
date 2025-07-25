import 'package:bbbb/Controller/favoriteController.dart';
import 'package:bbbb/Model/place.dart';
import 'package:bbbb/Pages/detail_place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class Favorite extends StatelessWidget {
  final FavoriteController favoriteController = Get.put(FavoriteController());

  Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 854),
      builder: (context, child) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text(
                'Daftar Tempat Favorit',
                style: TextStyle( fontFamily: "Roboto"),
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
            body: Obx(() {
              if (favoriteController.favoriteList.isEmpty) {
                return const Center(child: Text("Belum ada tempat favorit."));
              }
              return ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: favoriteController.favoriteList.length,
                itemBuilder: (context, index) {
                  final place = favoriteController.favoriteList[index];
                  return _buildPlaceCard(context,place);
                },
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildPlaceCard(BuildContext context, PlaceModel place) {
    return GestureDetector(
      onTap: () {
  PersistentNavBarNavigator.pushNewScreen(
    context,
    screen: PlaceDetailPage(placeId: place.id),
    withNavBar: true,
    pageTransitionAnimation: PageTransitionAnimation.cupertino,
  );
},

      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                  child: Image.network(
                    place.imageUrl,
                    width: double.infinity,
                    height: 150.h,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () async {
                      await favoriteController.removeFavorite(place.id);
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.favorite, color: Colors.red),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.title,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4.h),
                  Text(
                    place.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700], fontSize: 12.sp),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.green, size: 18.sp),
                      SizedBox(width: 4.w),
                      Text('${place.uptrend}', style: TextStyle(fontSize: 12.sp)),
                      SizedBox(width: 12.w),
                      Icon(Icons.comment, color: Colors.grey[700], size: 18.sp),
                      SizedBox(width: 4.w),
                      Text('${place.comments}', style: TextStyle(fontSize: 12.sp)),
                      SizedBox(width: 12.w),
                      Icon(Icons.star, color: Colors.amber, size: 18.sp),
                      SizedBox(width: 4.w),
                      Text('${place.rating}', style: TextStyle(fontSize: 12.sp)),
                      SizedBox(width: 12.w),
                      Icon(Icons.location_on, color: Colors.red, size: 18.sp),
                      SizedBox(width: 4.w),
                      Text('${place.distanceKm.toStringAsFixed(1)} km',
                          style: TextStyle(fontSize: 12.sp)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
