import 'package:bbbb/Pages/coment_page.dart';
import 'package:bbbb/Pages/detail_place.dart';
import 'package:bbbb/Pages/favorite.dart';
import 'package:bbbb/Pages/home.dart';
import 'package:bbbb/Pages/login.dart';
import 'package:bbbb/Pages/navbar.dart';
import 'package:bbbb/Pages/profile.dart';
import 'package:bbbb/Pages/register.dart';
import 'package:bbbb/Pages/search_page.dart';
import 'package:get/get.dart';

class MyPage {
  static final pages = [
    GetPage(name: login, page: () => Login()),
    GetPage(name: register, page: () => Register()),
    GetPage(name: home, page: () => Home()),
GetPage(
  name: detailPlace,
  page: () {
    final args = Get.arguments as String; // atau PlaceModel jika yang dikirim objek
    return PlaceDetailPage(placeId: args);
  },
),
    GetPage(name: favoritePage, page: () => Favorite()),
    GetPage(name: profile, page: () => Profile()),
    GetPage(name: searchPage, page: () => SearchPage()),
    GetPage(name: navBar, page: () => NavBarScreen()),
  ];

  static getLogin() => Login();
  static getRegister() => Register();
  static getHome() => Home();
  static getFavoritePage() => Favorite();
  static getProfile() => Profile();
  static getSearchPage() => SearchPage();
  static getNavbar() => NavBarScreen();


  static String login = '/login';
  static String register = '/register';
  static String home = '/home';
  static String detailPlace = '/detailPlace';
  static String favoritePage = '/favorite';
  static String profile = '/profile';
  static String searchPage = '/searchPage';
  static String navBar = '/navBar';
}
