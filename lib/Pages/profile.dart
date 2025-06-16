import 'package:bbbb/Config/color.dart';
import 'package:bbbb/Controller/auth.dart';
import 'package:bbbb/Controller/tourismController.dart';
import 'package:bbbb/Pages/add_admin.dart';
import 'package:bbbb/Pages/itinearis_admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();

    return Obx(() {
      final user = authC.userModel.value;
      if (user == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return ScreenUtilInit(
        designSize: const Size(375, 854),
        builder: (context, child) => SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              leading: const SizedBox(),
              title: const Text(
                'Profil',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 25.h),
                    CircleAvatar(
                      radius: 50.h,
                      backgroundImage: user.img.isNotEmpty
                          ? NetworkImage(user.img)
                          : null,
                      child: user.img.isEmpty
                          ? Icon(Icons.person, size: 50.h, color: AppColor.componentColor)
                          : null,
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      user.username,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 24.sp,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 50.h),
  if (user.role == 'officer') ...[
                      ListTile(
                        leading: Icon(Icons.add_business, color: AppColor.componentColor),
                        title: Text(
                          'Semua Itinerary',
                          style: TextStyle(fontFamily: 'Roboto', fontSize: 18.sp),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right_outlined),
                         onTap: () {
                          Get.put(TourismController(), permanent: true);
                          
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: AllItinerariesPage(),
                                  withNavBar:
                                      true, 
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                      ),
                      Divider(),
                    ],
                    

                    if (user.role == 'admin') ...[
                      ListTile(
                        leading: Icon(Icons.add_business, color: AppColor.componentColor),
                        title: Text(
                          'Tambah Tempat Wisata',
                          style: TextStyle(fontFamily: 'Roboto', fontSize: 18.sp),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right_outlined),
                         onTap: () {
                          Get.put(AdminController(), permanent: true);

                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: AdminAddPlacePage(),
                                  withNavBar:
                                      true, 
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                      ),
                      Divider(),
                    ],

                    ListTile(
                      leading: Icon(Icons.person, color: AppColor.componentColor),
                      title: Text(
                        'Ubah Profil',
                        style: TextStyle(fontFamily: 'Roboto', fontSize: 18.sp),
                      ),
                      trailing: Icon(Icons.keyboard_arrow_right_outlined),
                      onTap: () {
                        // TODO: implement edit profile
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.favorite, color: AppColor.componentColor),
                      title: Text(
                        'Tempat Favorit',
                        style: TextStyle(fontFamily: 'Roboto', fontSize: 18.sp),
                      ),
                      trailing: Icon(Icons.keyboard_arrow_right_outlined),
                      onTap: () {
                        // TODO: navigate to favorites
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.logout, color: AppColor.componentColor),
                      title: Text(
                        'Keluar',
                        style: TextStyle(fontFamily: 'Roboto', fontSize: 18.sp),
                      ),
                      trailing: Icon(Icons.keyboard_arrow_right_outlined),
                      onTap: () => authC.logout(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
