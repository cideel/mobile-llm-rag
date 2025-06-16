import 'package:bbbb/Controller/fetchingPlace.dart';
import 'package:bbbb/Model/place.dart';
import 'package:bbbb/Pages/detail_place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final tempatController = Get.put(TempatWisataController());
  String _searchQuery = '';
  String? _selectedCategory;

  List<PlaceModel> get _filteredPlaces {
    return tempatController.places.where((place) {
      final matchesSearch = place.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null || place.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Pilih Kategori", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              Divider(),
              Wrap(
                spacing: 12.w,
                children: ['Alam', 'Kuliner', 'Buatan', 'Hiburan & Rekreasi']
                    .map((category) => ChoiceChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (_) {
                            setState(() => _selectedCategory = category);
                            Navigator.pop(context);
                          },
                        ))
                    .toList(),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () {
                  setState(() => _selectedCategory = null);
                  Navigator.pop(context);
                },
                child: Text("Hapus Filter"),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: const BackButton(color: Colors.black),
          title: const Text("Hasil Pencarian", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Wisata Di Bandung',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: _showFilterModal,
                    child: Container(
                      height: 48.h,
                      width: 48.h,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: const Icon(Icons.filter_alt, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: Obx(() {
                  final filtered = _filteredPlaces;
                  if (filtered.isEmpty) {
                    return Center(child: Text("Tidak ada tempat yang ditemukan."));
                  }
                  return GridView.builder(
                    itemCount: filtered.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      final place = filtered[index];
                      return _placeCard(place);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeCard(PlaceModel place) {    

  return InkWell(                         
  onTap: () => PersistentNavBarNavigator.pushNewScreen(
  context,
  screen: PlaceDetailPage(placeId: place.id),
  withNavBar: true, // jika ingin tanpa bottom nav bar
  pageTransitionAnimation: PageTransitionAnimation.cupertino,
),

    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 5.r, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
            child: Image.network(
              place.imageUrl,
              height: 100.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.title,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 2.h),
                Text(place.address,
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _iconLabel(Icons.trending_up, place.uptrend.toString(), Colors.green),
                    _iconLabel(Icons.star, place.rating.toString(), Colors.orange),
                    _iconLabel(Icons.comment, place.comments.toString(), Colors.red),
                    _iconLabel(Icons.location_on, "${place.distanceKm} km", Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _iconLabel(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 12.sp),
        SizedBox(width: 2.w),
        Text(value, style: TextStyle(fontSize: 10.sp)),
      ],
    );
  }
}
