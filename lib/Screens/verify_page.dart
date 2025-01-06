import 'package:flutter/material.dart';
import '../Services/verify_service.dart'; // Nhập file verify_service.dart
import './login_page.dart';

class VerifyScreen extends StatefulWidget {
  final String email; // Nhận email từ RegisterPage

  const VerifyScreen({super.key, required this.email});

  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController _codeController = TextEditingController();
  String _message = '';

  final VerifyService _verifyService = VerifyService();

  void _verify() async {
    final code = _codeController.text;
    final email = widget.email; // Sử dụng email được truyền vào

    try {
      bool success = await _verifyService.verifyAccount(code, email);
      setState(() {
        _message = success ? 'Xác thực thành công!' : 'Xác thực thất bại!';
      });

      if (success) {
        // Chuyển sang trang đăng nhập nếu xác thực thành công
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()), // Điều hướng đến LoginPage
        );
      }
    } catch (e) {
      setState(() {
        _message = 'Lỗi xác thực: $e';
      });
      print('Lỗi: $e');
    }
  }

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
                  "assets/images/vector-3.png",
                  width: MediaQuery.of(context).size.width * 0.8, // Responsive width
                  height: MediaQuery.of(context).size.width * 0.4, // Responsive height
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Xác Thực Mã',
                style: TextStyle(
                  color: Color(0xFF755DC1),
                  fontSize: 24, // Giảm kích thước chữ cho màn hình nhỏ
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Mã Xác Thực',
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
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9F7BFF),
                    ),
                    child: const Text(
                      'Xác Thực',
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
              Text(
                _message,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
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
                      widget.email,
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
}