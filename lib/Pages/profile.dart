import 'package:bbbb/Config/color.dart';
import 'package:bbbb/Controller/auth.dart';
import 'package:bbbb/Controller/tourismController.dart'; // Pastikan import ini ada jika digunakan
import 'package:bbbb/Pages/add_admin.dart';
import 'package:bbbb/Pages/itinearis_admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  // Metode untuk menampilkan dialog edit username
  void _showEditUsernameDialog(BuildContext context, AuthController authC) {
    final usernameController = TextEditingController(text: authC.userModel.value?.username ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: const Text("Ubah Username"),
        content: TextField(
          controller: usernameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Masukkan username baru"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              final newUsername = usernameController.text.trim();
              if (newUsername.isNotEmpty) {
                // Memanggil metode updateUsername dari AuthController
                authC.updateUsername(newUsername);
                Navigator.pop(dialogContext); // Tutup dialog setelah update
              } else {
                 Get.snackbar(
                    'Error', 'Username tidak boleh kosong.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // Metode untuk menampilkan dialog konfirmasi logout
  void _showLogoutConfirmationDialog(BuildContext context, AuthController authC) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: const Text("Konfirmasi Keluar"),
        content: const Text("Apakah Anda yakin ingin keluar dari akun ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              // Memanggil metode logout dari AuthController
              authC.logout();
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan Get.find() di dalam build method untuk memastikan controller sudah siap
    final AuthController authC = Get.find<AuthController>();

    return Obx(() {
      final user = authC.userModel.value;
      // Menampilkan loading indicator jika data user belum tersedia
      if (user == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return ScreenUtilInit(
        designSize: const Size(375, 854),
        builder: (context, child) => Scaffold(
          backgroundColor: Colors.white, // Warna latar yang lebih lembut
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            title: const Text(
              'Profil Saya',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  SizedBox(height: 24.h),
                  // Bagian Info Pengguna dengan UI yang ditingkatkan
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 55.r,
                        backgroundColor: Colors.grey.shade300,
                        child: CircleAvatar(
                          radius: 52.r,
                          backgroundImage: user.img.isNotEmpty
                              ? NetworkImage(user.img)
                              : null,
                          child: user.img.isEmpty
                              ? Icon(Icons.person, size: 60.h, color: Colors.white)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                           onTap: () {
                            // TODO: Tambahkan logika untuk mengganti foto profil
                           },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColor.componentColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(Icons.edit, color: Colors.white, size: 18.sp),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // Username dengan ikon edit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        user.username,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showEditUsernameDialog(context, authC),
                        icon: Icon(Icons.edit, size: 20.sp, color: Colors.grey[600]),
                        splashRadius: 20,
                      )
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Menu Opsi dalam Card
                  Card(
                    color: Colors.white,
                    shadowColor: Colors.grey.withOpacity(0.9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Column(
                        children: [
                          // Opsi khusus untuk role 'officer'
                          if (user.role == 'officer')
                            _buildProfileMenu(
                              title: 'Semua Itinerary',
                              icon: Icons.article_rounded,
                              onTap: () {
                                Get.put(TourismController(), permanent: true);
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: AllItinerariesPage(),
                                  withNavBar: true,
                                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                );
                              }
                            ),
                          // Opsi khusus untuk role 'admin'
                          if (user.role == 'admin')
                            _buildProfileMenu(
                              title: 'Tambah Tempat Wisata',
                              icon: Icons.add_business_rounded,
                              onTap: () {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: AdminAddPlacePage(),
                                  withNavBar: true,
                                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                );
                              }
                            ),
                          
                          // Opsi umum untuk semua user
                          _buildProfileMenu(
                            title: 'Tempat Favorit',
                            icon: Icons.favorite_rounded,
                            onTap: () {
                              // TODO: Arahkan ke Halaman Favorit
                            }
                          ),
                          _buildProfileMenu(
                            title: 'Keluar',
                            icon: Icons.logout_rounded,
                            isLogout: true,
                            onTap: () => _showLogoutConfirmationDialog(context, authC),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
  });
    }
  }

  // Helper widget untuk membuat item menu agar kode lebih rapi
  Widget _buildProfileMenu({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      tileColor: Colors.white,
      leading: Icon(icon, color: isLogout ? Colors.redAccent : AppColor.componentColor),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16.sp,
          color: isLogout ? Colors.redAccent : Colors.black,
          fontWeight: isLogout ? FontWeight.w600 : FontWeight.normal
        ),
      ),
      trailing: isLogout ? null : Icon(Icons.keyboard_arrow_right_outlined, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

