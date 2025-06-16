// lib/views/list_itinerary_page.dart
import 'package:bbbb/Config/color.dart';
import 'package:bbbb/Pages/itinerary.dart';
import 'package:bbbb/Pages/itinerary_result.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ListItineraryPage extends StatelessWidget {
  const ListItineraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final ref = FirebaseDatabase.instance
        .ref('itineraries/${user!.uid}');

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Daftar Itinerary",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
        ),
        body: StreamBuilder<DatabaseEvent>(
          stream: ref.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final value = snapshot.data?.snapshot.value;
            if (value == null) {
              return Center(
                child: Text(
                  "Belum ada itinerary.",
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                ),
              );
            }
            final data = Map<String, dynamic>.from(value as Map);
            final entries = data.entries.toList().reversed.toList();

            return RefreshIndicator(
              onRefresh: () async {
                // pull-to-refresh triggers UI update
                await Future.delayed(const Duration(milliseconds: 300));
              },
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final id = entries[index].key;
                  final item = Map<String, dynamic>.from(entries[index].value);
                  final name = item['name'] ?? 'Tanpa Nama';
                  final created = item['createdAt']?.split('T').first ?? '-';

                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      title: Text(
                        name,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16.sp),
                      ),
                      subtitle: Text(
                        'Dibuat: $created',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                      ),
                      trailing: PopupMenuButton<String>(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditDialog(context, ref, id, name);
                          } else if (value == 'delete') {
                            ref.child(id).remove();
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(

                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18.sp, color: AppColor.componentColor),
                                SizedBox(width: 8.w),
                                const Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18.sp, color: Colors.redAccent),
                                SizedBox(width: 8.w),
                                const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ItineraryResultPage(
                                    itineraryText: item['content'],
                                    isFromSaved: true,
                                  )));
                        });
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
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ItineraryInputPage()));
            });
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

  void _showEditDialog(
      BuildContext context, DatabaseReference ref, String id, String oldName) {
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
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
                await ref.child(id).update({'name': newName});
              }
              Navigator.of(dialogCtx).pop();
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
