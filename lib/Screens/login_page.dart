import 'package:flutter/material.dart';
import 'home_page.dart';
import 'register_page.dart'; // Nhập trang RegisterPage
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/account_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AccountService _accountService = AccountService();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Email và mật khẩu không được để trống.');
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(_emailController.text)) {
      _showErrorDialog('Địa chỉ email không hợp lệ.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _accountService.login(
        _emailController.text,
        _passwordController.text,
      );

      final userId = response['id'] ?? '';
      final fullName = response['fullName'] ?? 'Người dùng không xác định';
      final image = response['image'] ?? ''; // Lấy URL ảnh từ phản hồi

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
      await prefs.setString('fullName', fullName);
      await prefs.setString('image', image); // Lưu URL ảnh vào SharedPreferences

      // Kiểm tra và in ra console
      print('User ID: $userId');
      print('Full Name: $fullName');
      print('Image URL: $image'); // In ra URL ảnh

      // Chuyển hướng về trang HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _login,
              child: Text('Đăng nhập'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Chuyển hướng đến trang đăng ký
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text('Chưa có tài khoản? Đăng ký'),
            ),
          ],
        ),
      ),
    );
  }
}