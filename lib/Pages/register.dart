import 'package:bbbb/Config/color.dart';
import 'package:bbbb/Controller/auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final usernameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final confirmPassC = TextEditingController(); // Controller baru
  final authC = Get.find<AuthController>();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    usernameC.dispose();
    emailC.dispose();
    passC.dispose();
    confirmPassC.dispose();
    super.dispose();
  }

  // Metode baru untuk validasi dan registrasi
  void _performRegister() async {
    final username = usernameC.text.trim();
    final email = emailC.text.trim();
    final password = passC.text.trim();
    final confirmPassword = confirmPassC.text.trim();

    // Validasi 1: Cek field kosong
    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Input Tidak Lengkap', 'Mohon lengkapi semua data.',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange[800], colorText: Colors.white,
      );
      return;
    }
    
    // Validasi 2: Cek panjang password
    if (password.length < 8) {
      Get.snackbar(
        'Password Terlalu Pendek', 'Password minimal harus 8 karakter.',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange[800], colorText: Colors.white,
      );
      return;
    }
    
    // Validasi 3: Cek konfirmasi password
    if (password != confirmPassword) {
      Get.snackbar(
        'Password Tidak Cocok', 'Konfirmasi password tidak sesuai dengan password Anda.',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange[800], colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await authC.register(
        email: email,
        password: password,
        username: username,
      );
      // Jika berhasil, notifikasi sukses mungkin akan ditangani di dalam controller
    } finally {
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
        backgroundColor: Colors.white,
        appBar: AppBar( // Menambahkan AppBar agar ada tombol kembali
          backgroundColor: Colors.white,
          leading: const BackButton(color: Colors.black),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                Text(
                  "Buat Akun Baru",
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Lengkapi data dirimu untuk memulai petualangan",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 40.h),
                
                _buildTextField(
                  controller: usernameC,
                  labelText: "Username",
                  prefixIcon: Icons.person_outline_rounded,
                ),
                SizedBox(height: 20.h),
                _buildTextField(
                  controller: emailC,
                  labelText: "Email",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20.h),
                _buildPasswordField(
                  controller: passC,
                  labelText: "Password",
                  isObscured: _isPasswordObscured,
                  onToggle: () {
                    setState(() {
                      _isPasswordObscured = !_isPasswordObscured;
                    });
                  },
                ),
                SizedBox(height: 20.h),
                _buildPasswordField(
                  controller: confirmPassC,
                  labelText: "Konfirmasi Password",
                  isObscured: _isConfirmPasswordObscured,
                  onToggle: () {
                    setState(() {
                      _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                    });
                  },
                ),
                SizedBox(height: 40.h),
                _buildSignUpButton(),
                SizedBox(height: 30.h),
                _buildSignInRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget Helper untuk konsistensi ---

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool isObscured,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscured,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
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

  Widget _buildSignUpButton() {
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
        onPressed: _isLoading ? null : _performRegister,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
            : Text(
                "Daftar",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildSignInRow() {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 14.sp, color: Colors.black),
        children: [
          const TextSpan(text: "Sudah punya akun? "),
          TextSpan(
            text: "Masuk",
            style: TextStyle(
              color: AppColor.componentColor,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = () => Get.back(),
          ),
        ],
      ),
    );
  }
}
