import 'package:bbbb/Config/color.dart';
import 'package:bbbb/Controller/auth.dart';
import 'package:bbbb/Controller/commentController.dart';
import 'package:bbbb/Controller/ratingController.dart';
import 'package:bbbb/Controller/uptrendController.dart';
import 'package:bbbb/Controller/favoriteController.dart';
import 'package:bbbb/Model/place.dart';
import 'package:bbbb/Pages/add_admin.dart';
import 'package:bbbb/Pages/coment_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PlaceDetailPage extends StatelessWidget {
   PlaceDetailPage({super.key, required this.placeId});

  final String placeId;
  final Rx<PlaceModel?> currentPlace = Rx<PlaceModel?>(null);

  final UptrendController uptrendC = Get.put(UptrendController());
  final RatingService ratingService = RatingService();
  final FavoriteController favoriteController = Get.put(FavoriteController());
  final AuthController authC            = Get.find<AuthController>();
  final AdminController adminC          = Get.find<AdminController>();
    final CommentController controller = Get.put(CommentController());

  Future<PlaceModel?> fetchPlace(String id) async {
    final snapshot = await FirebaseDatabase.instance.ref('tempat_wisata/$id').get();
    if (snapshot.exists) {
      return PlaceModel.fromMap(snapshot.value as Map, id);
    }
    return null;
  }

  // Di dalam class _PlaceDetailPageState atau di dalam sebuah controller

Future<int> getCommentCount(String placeId) async {
  final ref = FirebaseDatabase.instance.ref('comments/$placeId');
  final snapshot = await ref.get();
  if (snapshot.exists && snapshot.value != null) {
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return data.length; // Menghitung jumlah key (komentar)
  }
  return 0; // Jika tidak ada komentar, kembalikan 0
}

  @override
  Widget build(BuildContext context) {
    final RxBool hasUpvoted = false.obs;
    final RxBool isFavorite = false.obs;
              final user  = authC.userModel.value;


    Future.microtask(() async {
      currentPlace.value = await fetchPlace(placeId);
      hasUpvoted.value = await uptrendC.checkUpvoted(placeId);
      isFavorite.value = await favoriteController.isFavorite(placeId);
    });

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: const BackButton(color: Colors.black),
          title: Obx(() => Text(
                currentPlace.value?.title ?? '',
                style: const TextStyle(color: Colors.black),
              )),
          backgroundColor: Colors.white,
          actions: [
            
if (user?.role == 'admin')
  IconButton(
    icon: Icon(Icons.delete, color: Colors.red, size: 24.sp),
    onPressed: () {
      Get.defaultDialog(
        buttonColor: AppColor.componentColor,
        title: 'Konfirmasi Hapus',
        middleText: 'Anda yakin ingin menghapus tempat wisata ini?',
        textConfirm: 'Ya',
        textCancel: 'Tidak',
        onConfirm: () async {
          await adminC.deletePlace(placeId);
        },
        onCancel: () => Get.back(),
      );
    },
  ),

          ],
        ),
        body: Obx(() {
          final place = currentPlace.value;

          if (place == null) return const Center(child: CircularProgressIndicator());

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.network(
                        place.imageUrl,
                        height: 250.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 12.h,
                        right: 12.w,
                        child: Obx(() => GestureDetector(
                              onTap: () async {
                                if (isFavorite.value) {
                                  await favoriteController.removeFavorite(place.id);
                                } else {
                                  await favoriteController.addFavorite(place);
                                }
                                isFavorite.value = await favoriteController.isFavorite(place.id);
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(
                                  isFavorite.value ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.red,
                                ),
                              ),
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(place.title, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 4.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(place.address, style: TextStyle(fontSize: 13.sp, color: Colors.grey[700])),
                  ),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoStat(
                          Icons.star,
                          '${place.rating}',
                          'Rating',
                          Colors.orange.withOpacity(0.2),
                          iconColor: Colors.orange,
                          onTap: () {
                            final RxDouble tempRating = 3.0.obs;
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                                child: Padding(
                                  padding: EdgeInsets.all(16.w),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("Beri Rating Tempat Ini", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                                      SizedBox(height: 12.h),
                                      Text("Geser untuk memilih rating", style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
                                      SizedBox(height: 12.h),
                                      RatingBar.builder(
                                        initialRating: tempRating.value,
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        allowHalfRating: false,
                                        itemCount: 5,
                                        itemSize: 30.sp,
                                        itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                                        onRatingUpdate: (newRating) => tempRating.value = newRating,
                                      ),
                                      SizedBox(height: 10.h),
                                      ElevatedButton(
                                        onPressed: () async {
                                          await ratingService.submitRating(place.id, tempRating.value);
                                          currentPlace.value = await fetchPlace(place.id);
                                          Get.back();
                                        },
                                        child: Text("Kirim"),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        _infoStat(
                          Icons.location_on,
                          'Maps',
                          'Lokasi',
                          Colors.blue.withOpacity(0.2),
                          iconColor: Colors.blue,
                          onTap: () async {
                            final url = place.mapUrl.trim();
                            final success = await launchUrlString(url, mode: LaunchMode.externalApplication);
                            if (!success) {
                              Get.snackbar('Gagal Membuka Maps', 'URL tidak valid atau emulator tidak mendukung.');
                            }
                          },
                        ),
                        Obx(() => _infoStat(
                              hasUpvoted.value ? Icons.trending_up : Icons.trending_flat,
                              '${place.uptrend}',
                              'Uptrend',
                              Colors.green.withOpacity(0.2),
                              iconColor: hasUpvoted.value ? Colors.green : Colors.grey,
                              onTap: () async {
                                await uptrendC.toggleUpvote(place.id);
                                hasUpvoted.value = await uptrendC.checkUpvoted(place.id);
                                currentPlace.value = await fetchPlace(place.id);
                              },
                            )),
                        _infoStat(
                          
                          Icons.comment,
                          
                          '${controller.comments.length}',
                          'Komentar',
                          Colors.purple.withOpacity(0.2),
                          iconColor: Colors.purple,
                          onTap: () {
                            Get.to(() => CommentPage(placeId: place.id));
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _sectionTitle('Deskripsi Tempat'),
                  _sectionContent(
                    place.description.isNotEmpty ? place.description : "Deskripsi tempat belum tersedia.",
                  ),
                  SizedBox(height: 24.h),
                  _sectionTitle('Informasi Tambahan'),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        _infoTile(Icons.confirmation_number, 'Tiket Masuk atau Harga Menu', place.ticketPrice),
                        _infoTile(Icons.place, 'Alamat', place.address),
                        _infoTile(Icons.phone, 'Telepon', place.noPhone),
                        _infoTile(Icons.camera_alt, 'Instagram', place.socialMedia),
                        _infoTile(Icons.schedule, 'Jam Operasional', place.openHour),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _infoStat(
    IconData icon,
    String value,
    String label,
    Color iconBgColor, {
    VoidCallback? onTap,
    Color iconColor = Colors.black,
  }) {
    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
          child: Icon(icon, size: 20.sp, color: iconColor),
        ),
        SizedBox(height: 6.h),
        Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(width: 70.w, alignment: Alignment.center, child: content),
    );
  }

  Widget _infoTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 3.r, offset: Offset(0, 1))
              ],
            ),
            child: Icon(icon, size: 20.sp, color: Colors.blueAccent),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(fontSize: 13.sp, color: Colors.grey[700])),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(text, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
    );
  }

  Widget _sectionContent(String text) {
    final paragraphs = text.split('\n\n');
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: paragraphs.map((p) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Text(
            p.trim(),
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 13.sp, height: 1.6, color: Colors.grey[800]),
          ),
        )).toList(),
      ),
    );
  }
}