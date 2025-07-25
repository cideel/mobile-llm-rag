import 'package:bbbb/Controller/fetchingPlace.dart';
import 'package:bbbb/Model/place.dart';
import 'package:bbbb/Pages/add_admin.dart';
import 'package:bbbb/Pages/detail_place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class SearchPage extends StatefulWidget {
  // --- PERBAIKAN 1: Menambahkan parameter opsional untuk filter awal ---
  final String? initialCategory;

  const SearchPage({Key? key, this.initialCategory}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final tempatController = Get.put(TempatWisataController());
  String _searchQuery = '';
  String? _selectedCategory;

  // --- PERBAIKAN 2: Menggunakan initState untuk menetapkan filter awal ---
  @override
  void initState() {
    super.initState();
    // Jika ada kategori yang dikirim dari halaman Home, langsung set sebagai filter
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
    }
  }

  List<PlaceModel> get _filteredPlaces {
    
    return tempatController.places.where((place) {
      final matchesSearch =
          place.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == null || place.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        // Membuat sudut atas modal melengkung
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Pilih Kategori",
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 4.h,
                children: [
                  'Alam',
                  'Kuliner',
                  'Budaya',
                  'Hiburan & Rekreasi'
                ] // 'Buatan' diganti 'Budaya' agar konsisten
                    .map((category) => ChoiceChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          selectedColor: Colors.blueAccent,
                          labelStyle: TextStyle(
                            color: _selectedCategory == category
                                ? Colors.white
                                : Colors.black,
                          ),
                          onSelected: (_) {
                            setState(() => _selectedCategory = category);
                            Navigator.pop(context);
                          },
                        ))
                    .toList(),
              ),
              SizedBox(height: 8.h),
              // Tombol untuk menghapus filter
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() => _selectedCategory = null);
                    Navigator.pop(context);
                  },
                  child: const Text("Hapus Filter",
                      style: TextStyle(color: Colors.redAccent)),
                ),
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
          title: const Text("Pencarian",
              style: TextStyle(color: Colors.black)), 
          backgroundColor: Colors.white,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus:
                          true, // Langsung fokus ke search bar saat halaman dibuka
                      decoration: InputDecoration(
                        hintText: 'Cari tempat wisata di Bandung...',
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 4.h, horizontal: 16.w),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
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
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: const Icon(Icons.filter_list, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: Obx(() {
                  // Kita perlu memanggil _filteredPlaces di dalam setState agar UI ter-update
                  // saat state berubah. Obx akan memantaunya.
                  final filtered = _filteredPlaces;
                  if (tempatController.places.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (filtered.isEmpty) {
                    return Center(
                        child: Text("Tidak ada tempat yang ditemukan."));
                  }
                  return GridView.builder(
                    itemCount: filtered.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio:
                          0.7, // Disesuaikan agar kartu lebih proporsional
                    ),
                    itemBuilder: (context, index) {
                      final place = filtered[index];
                      return _placeCard(context, place);
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

  Widget _placeCard(BuildContext context, PlaceModel place) {
    return InkWell(
      onTap: () => PersistentNavBarNavigator.pushNewScreen(
        
        context,
        screen: PlaceDetailPage(placeId: place.id),
        withNavBar: true,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      ),
      child: Card(

        color: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        shadowColor: Colors.grey.withOpacity(0.9),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              place.imageUrl,
              height: 120.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, e, s) => Container(
                height: 80.h,
                color: Colors.cyan,
                child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4.h),
                  Text(place.address,
                      style:
                          TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _iconLabel(Icons.thumb_up, place.uptrend.toString(),
                          Colors.blue),
                      SizedBox(
                        width: 10.w,
                      ),
                      _iconLabel(Icons.star, place.rating.toStringAsFixed(1),
                          Colors.orange),
                      SizedBox(
                        width: 10.w,
                      ),
                      _iconLabel(Icons.comment, place.comments.toString(),
                          Colors.grey),
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
        SizedBox(width: 4.w),
        Text(value,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
