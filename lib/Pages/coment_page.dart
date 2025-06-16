import 'package:bbbb/Controller/commentController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CommentPage extends StatelessWidget {
  final String placeId;
  final CommentController controller = Get.put(CommentController());

  CommentPage({super.key, required this.placeId});

  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    controller.fetchComments(placeId);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Komentar', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Obx(() => Text(
                    '${controller.comments.length} Komentar',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  )),
            ),
            Expanded(
              child: Obx(() {
                if (controller.comments.isEmpty) {
                  return const Center(child: Text('Belum ada komentar.'));
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: controller.comments.length,
                  separatorBuilder: (context, index) => Divider(height: 16.h, color: Colors.grey[300]),
                  itemBuilder: (context, index) {
                    final comment = controller.comments[index];
                    final isCurrentUser = comment['uid'] == FirebaseAuth.instance.currentUser?.uid;
                    return Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${comment['uid']}'),
                            radius: 20.r,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(comment['name'] ?? '-',
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
                                    Text(
                                      DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(comment['time'])),
                                      style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(comment['comment'] ?? '', style: TextStyle(fontSize: 13.sp)),
                                if (isCurrentUser)
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: IconButton(
                                      icon: Icon(Icons.delete_outline, size: 18.sp, color: Colors.red),
                                      onPressed: () async {
                                        await controller.deleteComment(placeId, comment['id']);
                                      },
                                    ),
                                  )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4.r, offset: Offset(0, -2))
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?u=${FirebaseAuth.instance.currentUser?.uid}'),
                    radius: 18.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Tulis komentar...'
                              ,
                          border: InputBorder.none,
                        ),
                        onSubmitted: (text) async {
                          await controller.addComment(placeId, text);
                          _commentController.clear();
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue, size: 24.sp),
                    onPressed: () async {
                      await controller.addComment(placeId, _commentController.text);
                      _commentController.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
