import 'package:bbbb/Config/color.dart';
import 'package:bbbb/Pages/favorite.dart';
import 'package:bbbb/Pages/home.dart';
import 'package:bbbb/Pages/itinerary.dart';
import 'package:bbbb/Pages/itinerary_list.dart';
import 'package:bbbb/Pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class NavBarScreen extends StatelessWidget {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      Home(),
      Favorite(),
      ListItineraryPage(),
      Profile(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home),
        title: "Beranda",
        
        activeColorPrimary: AppColor.componentColor,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.favorite),
        title: "Favorit",
        
        activeColorPrimary: AppColor.componentColor,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.note),
        title: "Itinerary",
        
        activeColorPrimary: AppColor.componentColor,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person),
        title: "Profil",
        activeColorPrimary: AppColor.componentColor,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      navBarStyle: NavBarStyle.style3,
      stateManagement: true,
      backgroundColor: Colors.white, // Anda bisa mengganti dengan gaya lain.
    );
  }
}
