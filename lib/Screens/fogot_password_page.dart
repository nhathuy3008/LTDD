import 'package:flutter/material.dart';
import 'VerificationCodeScreen.dart';
import '../Services/account_service.dart'; // Import AccountService

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final AccountService _accountService = AccountService(); // Tạo instance của AccountService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Cho phép cuộn cho các màn hình nhỏ
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  "assets/images/vector-3.png", // Đường dẫn đến hình ảnh
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.4,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Quên Mật Khẩu',
                style: TextStyle(
                  color: Color(0xFF755DC1),
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(
                    color: Color(0xFF755DC1),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 1,
                      color: Color(0xFF9F7BFF),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 1,
                      color: Color(0xFF9F7BFF),
                    ),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      String email = emailController.text;
                      if (email.isEmpty) {
                        _showErrorDialog(context, 'Email không được để trống.');
                        return;
                      }

                      try {
                        // Gọi phương thức gửi mã xác nhận
                        await _accountService.forgotPassword(email);

                        // Nếu mã xác nhận đã được gửi thành công, điều hướng đến VerificationCodeScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VerificationCodeScreen(email: email),
                          ),
                        );
                      } catch (e) {
                        // In ra lỗi trong console
                        print('Error occurred while sending verification code: $e');
                        // Hiển thị thông báo lỗi cho người dùng
                        _showErrorDialog(context, 'Đã xảy ra lỗi: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9F7BFF),
                    ),
                    child: const Text(
                      'Gửi Mã Xác Nhận',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }
}