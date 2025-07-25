import 'package:bbbb/Config/color.dart';
import 'package:bbbb/Controller/auth.dart';
import 'package:bbbb/Pages/register.dart'; // Menggunakan nama file yang sesuai
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final authC = Get.find<AuthController>();

  bool _isPasswordObscured = true;
  // --- PENAMBAHAN: State untuk mengelola status loading ---
  bool _isLoading = false;
  
  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  // --- PENAMBAHAN: Metode baru untuk menangani logika login ---
  void _performLogin() async {
    final email = emailC.text.trim();
    final password = passC.text.trim();

    // Validasi 1: Cek apakah field kosong
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Input Tidak Lengkap',
        'Mohon isi email dan password Anda.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[800],
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
      );
      return; // Hentikan eksekusi jika ada field yang kosong
    }

    // Mulai proses loading
    setState(() {
      _isLoading = true;
    });

    // Panggil fungsi login di controller
    // Asumsi: authC.login akan menangani notifikasi untuk error dari Firebase 
    // (misalnya password salah, user tidak ditemukan)
    try {
      await authC.login(email, password);
    } finally {
      // Hentikan proses loading setelah selesai, baik berhasil maupun gagal
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 854),
      builder: (context, child) => Scaffold(
        backgroundColor: Colors.white, // Mengubah warna latar agar bersih
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 180.h),
                
                SizedBox(height: 20.h),
                Text(
                  "Selamat Datang Kembali!",
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Silakan masuk untuk melanjutkan petualanganmu",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 40.h),
                
                // Form Email
                _buildEmailField(),
                
                SizedBox(height: 20.h),
                
                // Form Password
                _buildPasswordField(),

                SizedBox(height: 12.h),

                // Lupa Password
                

                SizedBox(height: 24.h),

                // Tombol Sign In
                _buildSignInButton(),
                
                SizedBox(height: 30.h),

                // Routing ke halaman Sign Up
                _buildSignUpRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: emailC,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: "Email",
        prefixIcon: const Icon(Icons.email_outlined),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: passC,
      obscureText: _isPasswordObscured, // Menggunakan state
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _isPasswordObscured = !_isPasswordObscured;
            });
          },
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
         enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
  // --- PERBAIKAN: Logika tombol diperbarui ---
  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 55.h),
          backgroundColor: AppColor.componentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          elevation: 5,
          shadowColor: AppColor.componentColor.withOpacity(0.4),
        ),
        // Menonaktifkan tombol saat loading
        onPressed: _isLoading ? null : _performLogin,
        child: _isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              )
            : Text(
                "Masuk",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildSignUpRow() {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.black,
        ),
        children: [
          const TextSpan(text: "Belum punya akun? "),
          TextSpan(
            text: "Daftar",
            style: TextStyle(
              color: AppColor.componentColor,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Get.to(() =>  Register()); // Navigasi ke halaman registrasi
              },
          ),
        ],
      ),
    );
  }
}
