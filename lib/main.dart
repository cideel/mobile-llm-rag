import 'package:bbbb/Config/color.dart';
import 'package:bbbb/Config/router.dart';
import 'package:bbbb/Controller/auth.dart';
import 'package:bbbb/Pages/detail_place.dart';
import 'package:bbbb/Pages/home.dart';
import 'package:bbbb/Pages/login.dart';
import 'package:bbbb/Pages/navbar.dart';
import 'package:bbbb/Pages/register.dart';
import 'package:bbbb/Pages/search_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // <- harus duluan

  // Inisialisasi Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      name: "bingung-di-bandung-v2-1",
      options: FirebaseOptions(
        apiKey: 'AIzaSyAqo9mtiLaHtczhz7yj-EecRoEk-OApo88',
        appId: '1:313394947073:android:ce140ee0c7186c4e2f8c00',
        messagingSenderId: '313394947073',
        projectId: 'bingung-di-bandung-v2-1',
        databaseURL:
            'https://bingung-di-bandung-v2-1-default-rtdb.asia-southeast1.firebasedatabase.app', 
      ),
    );
  }

  // Baru taruh setelah Firebase siap
  Get.put(AuthController());

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 854),
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system, // Bisa diubah ke ThemeMode.dark jika ingin paksa dark
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColor.componentColor,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColor.componentColor,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.black,
          ),
          home: Login(),
          getPages: MyPage.pages,
        );
      },
    );
  }
}

