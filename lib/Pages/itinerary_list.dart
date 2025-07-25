// lib/views/list_itinerary_page.dart
import 'package:bbbb/Config/color.dart';
import 'package:bbbb/Pages/itinerary.dart';
import 'package:bbbb/Pages/itinerary_result.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart'; 

class ListItineraryPage extends StatefulWidget {
  const ListItineraryPage({Key? key}) : super(key: key);

  @override
  State<ListItineraryPage> createState() => _ListItineraryPageState();
}

class _ListItineraryPageState extends State<ListItineraryPage> {
  late DatabaseReference _itinerariesRef;
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (_user != null) {
      _itinerariesRef = FirebaseDatabase.instance.ref('itineraries/${_user!.uid}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Silakan login terlebih dahulu."),
        ),
      );
    }

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Daftar Itinerary",
            style: TextStyle(color: Colors.black, fontFamily: "Roboto"),
          ),
          backgroundColor: Colors.white,
        ),
        body: StreamBuilder<DatabaseEvent>(
          stream: _itinerariesRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
              return Center(
                child: Text(
                  "Belum ada itinerary.",
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                ),
              );
            }
            final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
            final entries = data.entries.toList()
              ..sort((a, b) => b.key.compareTo(a.key));

            return RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
                if (mounted) {
                  setState(() {});
                }
              },
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                itemCount: entries.length,
                itemBuilder: (itemContext, index) { 
                  final id = entries[index].key;
                  final item = Map<String, dynamic>.from(entries[index].value);
                  final name = item['name'] ?? 'Tanpa Nama';
                  final created = item['createdAt']?.split('T').first ?? '-';

                  return Card(
                    color: Colors.white,
                    margin: EdgeInsets.only(bottom: 12.h),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.only(left: 16.w, right: 8.w, top: 8.h, bottom: 8.h),
                      title: Text(
                        name,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16.sp),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          'Dibuat: $created',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                        ),
                      ),
                      // --- PERBAIKAN UTAMA: Mengganti PopupMenuButton dengan Row berisi IconButton ---
                      trailing: SizedBox(
                        width: 100.w, // Beri lebar agar tidak overflow
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: AppColor.componentColor),
                              onPressed: () {
                                _showEditDialog(itemContext, id, name);
                              },
                              tooltip: 'Edit Nama',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                _showDeleteConfirmationDialog(itemContext, id);
                              },
                              tooltip: 'Hapus',
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => ItineraryResultPage(
                              itineraryText: item['content'],
                              isFromSaved: true,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ItineraryInputPage()),
            );
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Buat Baru",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColor.componentColor,
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext dialogContext, String id, String oldName) {
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: dialogContext, 
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: const Text("Edit Nama Itinerary"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Masukkan nama baru",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.componentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await _itinerariesRef.child(id).update({'name': newName});
              }
              // Pengecekan mounted tetap aman dilakukan di sini
              if (mounted) {
                 Navigator.of(dialogCtx).pop();
              }
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
  
  void _showDeleteConfirmationDialog(BuildContext dialogContext, String id) {
    showDialog(
      context: dialogContext, 
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: const Text("Hapus Itinerary?"),
        content: const Text("Apakah Anda yakin ingin menghapus itinerary ini secara permanen?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () {
              _itinerariesRef.child(id).remove();
              Navigator.of(dialogCtx).pop();
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
