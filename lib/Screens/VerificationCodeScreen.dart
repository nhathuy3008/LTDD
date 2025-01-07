import 'package:flutter/material.dart';
import 'login_page.dart'; // Import LoginPage
import '../Services/account_service.dart'; // Import AccountService

class VerificationCodeScreen extends StatelessWidget {
  final String email;
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final AccountService _accountService = AccountService(); // Tạo instance của AccountService

  VerificationCodeScreen({required this.email});

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
                  "assets/images/vector-3.png", // Thay đổi đường dẫn đến hình ảnh nếu cần
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.4,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Thay Đổi Mật Khẩu',
                style: TextStyle(
                  color: Color(0xFF755DC1),
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  labelText: 'Mã Xác Minh',
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
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'Mật Khẩu Mới',
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
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      String verificationCode = codeController.text;
                      String newPassword = newPasswordController.text;

                      if (verificationCode.isEmpty || newPassword.isEmpty) {
                        _showErrorDialog(context, 'Bạn cần nhập mã xác minh và mật khẩu mới.');
                        return;
                      }

                      try {
                        // Gọi phương thức xác minh mã xác minh
                        final verifyResponse = await _accountService.verifyCode(email, verificationCode);

                        // Kiểm tra nếu mã xác minh hợp lệ
                        if (verifyResponse['status'] == 'thành công') {
                          // Nếu xác minh thành công, gọi phương thức đặt mật khẩu mới
                          await _accountService.resetPassword(email, verificationCode, newPassword);

                          // Hiển thị thông báo thành công
                          _showSuccessDialog(context, 'Thay đổi mật khẩu thành công. Bạn có thể đăng nhập lại.');

                          // Điều hướng về trang đăng nhập
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                                (route) => false,
                          );
                        } else {
                          _showErrorDialog(context, 'Mã xác minh không hợp lệ.');
                        }
                      } catch (e) {
                        // In ra lỗi trong console
                        print('Error occurred while processing: $e');
                        // Hiển thị thông báo lỗi cho người dùng
                        _showErrorDialog(context, 'Đã xảy ra lỗi: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9F7BFF),
                    ),
                    child: const Text(
                      'Thay Đổi Mật Khẩu',
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Một mã xác thực đã được gửi đến ',
                      style: TextStyle(
                        color: Color(0xFF837E93),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 2.5),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Color(0xFF755DC1),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thành Công'),
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