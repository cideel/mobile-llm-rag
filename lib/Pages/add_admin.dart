import 'package:bbbb/Config/color.dart';
import 'package:bbbb/Model/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';



class AdminController extends GetxController {
  // TextEditingControllers for form inputs
  final titleC       = TextEditingController();
  final addressC     = TextEditingController();
  final imageUrlC    = TextEditingController();
  final ticketPriceC = TextEditingController();
  final noPhoneC     = TextEditingController();
  final socialMediaC = TextEditingController();
  final openHourC    = TextEditingController();
  final categoryC    = TextEditingController();
  final descriptionC = TextEditingController();
  final mapUrlC      = TextEditingController();

  // Loading state
  final isLoading = false.obs;

  // Reference to 'tempat_wisata' node
  final dbRef = FirebaseDatabase.instance.ref().child('tempat_wisata');

  /// Add new place to Realtime Database
  Future<void> addPlace(PlaceModel place) async {
    try {
      isLoading(true);
      await dbRef.push().set(place.toJson());
      Get.back();
      Get.snackbar('Sukses', 'Tempat wisata berhasil ditambahkan', snackPosition: SnackPosition.BOTTOM);
      clearFields();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  /// Hapus tempat wisata berdasarkan ID
Future<void> deletePlace(String id) async {
  try {
    isLoading(true); // obs<bool> isLoading di controller
    // hapus node 'tempat_wisata/{id}' di Realtime Database
    await FirebaseDatabase.instance
        .ref('tempat_wisata/$id')
        .remove();
    // setelah sukses, tutup dialog & halaman detail
    Get.back(); // tutup dialog konfirmasi
    Get.back(); // kembali ke halaman sebelumnya
    Get.snackbar(
      'Sukses',
      'Tempat wisata berhasil dihapus',
      snackPosition: SnackPosition.BOTTOM,
    );
  } catch (e) {
    Get.snackbar(
      'Error',
      'Gagal menghapus tempat: $e',
      snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isLoading(false);
  }
}


  /// Clear all form fields
  void clearFields() {
    titleC.clear();
    addressC.clear();
    imageUrlC.clear();
    ticketPriceC.clear();
    noPhoneC.clear();
    socialMediaC.clear();
    openHourC.clear();
    categoryC.clear();
    descriptionC.clear();
    mapUrlC.clear();
  }
}




class AdminAddPlacePage extends StatelessWidget {
  final AdminController ctrl = Get.find();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        
        title: Text('Tambah Tempat Wisata', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.black),
      ),
      body: Obx(() {
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildField('Judul', ctrl.titleC, icon: Icons.title, validator: (v) => v!.isEmpty ? 'Judul wajib diisi' : null),
                    _buildField('Alamat', ctrl.addressC, icon: Icons.location_on, validator: (v) => v!.isEmpty ? 'Alamat wajib diisi' : null),
                    _buildField('Image URL', ctrl.imageUrlC, icon: Icons.image, validator: (v) => v!.isEmpty ? 'Image URL wajib diisi' : null),
                    _buildField('Harga Tiket', ctrl.ticketPriceC, icon: Icons.attach_money, validator: (v) => v!.isEmpty ? 'Harga tiket wajib diisi' : null),
                    _buildField('Nomor Telepon', ctrl.noPhoneC, icon: Icons.phone, validator: (v) => v!.isEmpty ? 'Nomor telepon wajib diisi' : null),
                    _buildField('Sosial Media', ctrl.socialMediaC, icon: Icons.share, validator: (v) => v!.isEmpty ? 'Sosial media wajib diisi' : null),
                    _buildField('Jam Operasi', ctrl.openHourC, icon: Icons.access_time, validator: (v) => v!.isEmpty ? 'Jam operasi wajib diisi' : null),
                    _buildField('Kategori', ctrl.categoryC, icon: Icons.category, validator: (v) => v!.isEmpty ? 'Kategori wajib diisi' : null),
                    _buildField('Deskripsi', ctrl.descriptionC, icon: Icons.description, maxLines: 4, validator: (v) => v!.isEmpty ? 'Deskripsi wajib diisi' : null),
                    _buildField('Map URL', ctrl.mapUrlC, icon: Icons.map, validator: (v) => v!.isEmpty ? 'Map URL wajib diisi' : null),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () => _onSubmit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.componentColor,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: Text('Simpan', style: TextStyle(fontSize: 16.sp,color: Colors.white,fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            if (ctrl.isLoading.value)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
        style: TextStyle(fontSize: 14.sp),
      ),
    );
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      Get.defaultDialog(
        buttonColor: AppColor.componentColor,
        backgroundColor: Colors.white,
        title: 'Konfirmasi',
        middleText: 'Apakah Anda yakin ingin menambahkan tempat wisata?',
        textConfirm: 'Ya',
        textCancel: 'Tidak',
        onConfirm: () {
          final place = PlaceModel(
            id: '',
            title: ctrl.titleC.text,
            address: ctrl.addressC.text,
            imageUrl: ctrl.imageUrlC.text,
            like: 0,
            comments: 0,
            rating: 0.0,
            distanceKm: 0.0,
            openHour: ctrl.openHourC.text,
            socialMedia: ctrl.socialMediaC.text,
            uptrend: 0,
            noPhone: ctrl.noPhoneC.text,
            ticketPrice: ctrl.ticketPriceC.text,
            category: ctrl.categoryC.text,
            description: ctrl.descriptionC.text,
            mapUrl: ctrl.mapUrlC.text,
          );
          ctrl.addPlace(place);
          Get.back();
        },
      );
    } else {
      Get.snackbar('Error', 'Harap lengkapi semua form', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
