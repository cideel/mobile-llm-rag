import 'package:bbbb/Config/color.dart';
import 'package:bbbb/Controller/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Login extends StatelessWidget {
  final emailC = TextEditingController();
  final passC = TextEditingController();

  final authC = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ScreenUtilInit(
        designSize: const Size(375, 854),
        builder: (context, child) => Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: AppColor.bgColor,
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.symmetric(vertical: 86.h)),
                    Center(
                        child: Text(
                      "Sign in now",
                      style: TextStyle(
                          fontFamily: 'Shipori',
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold),
                    )),
                    Padding(padding: EdgeInsets.symmetric(vertical: 5.h)),
                    Center(
                      child: Text(
                        "Please sign in to continue",
                        style: TextStyle(
                            fontFamily: 'Shipori',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w200),
                      ),
                    ),
                    SizedBox(
                      height: 45.h,
                    ),
                    Container(
                      child: TextField(
                        controller: emailC,
                        maxLines: 1,
                        decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r))),
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 15.h)),
                    Container(
                      child: TextField(
                        controller: passC,
                        maxLines: 1,
                        decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r))),
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Container(
                        alignment: Alignment.topRight,
                        child: Text(
                          "Forget password?",
                          style:
                              TextStyle(fontFamily: 'Roboto', fontSize: 13.sp),
                        )),
                    SizedBox(
                      height: 16.h,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(335.w, 55.h),
                            backgroundColor: AppColor.componentColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.r))),
                        onPressed: () {
                          authC.login(emailC.text.trim(), passC.text.trim());
                        },
                        child: Text(
                          "Sign in",
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                              color: Colors.white),
                        )),
                    SizedBox(
                      height: 15.h,
                    ),
                    Text(
                      "Dont have account?",
                      style: TextStyle(fontFamily: 'Roboto', fontSize: 13.sp),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      "Sign up",
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 13.sp,
                          color: Color(0xff0D6EFD)),
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
