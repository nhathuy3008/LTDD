import 'package:flutter/material.dart';
import '../Services/verify_service.dart'; // Nhập file verify_service.dart
import './login_page.dart';
class VerifyScreen extends StatefulWidget {
  final String email; // Nhận email từ RegisterPage

  VerifyScreen({required this.email});

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
      appBar: AppBar(title: Text('Xác Thực Tài Khoản')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _codeController,
              decoration: InputDecoration(labelText: 'Mã Xác Thực'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verify,
              child: Text('Xác Thực'),
            ),
            SizedBox(height: 20),
            Text(_message),
          ],
        ),
      ),
    );
  }
}