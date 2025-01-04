import 'package:flutter/material.dart';
import '../Services/account_service.dart';
import '../Screens/verify_page.dart'; // Nhập trang VerifyScreen

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AccountService _accountService = AccountService();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';

  void _register() async {
    final fullName = _fullNameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    final accountData = {
      'fullName': fullName,
      'email': email,
      'password': password,
    };

    print('Dữ liệu gửi đến API: $accountData');

    try {
      // Gọi phương thức createAccount và lưu kết quả
      final response = await _accountService.createAccount(accountData);
      print('Phản hồi từ API: $response'); // In ra phản hồi

      // Kiểm tra trường 'status' trong phản hồi
      if (response['status'] == 'thành công') {
        setState(() {
          _message = response['message']; // Cập nhật thông báo
        });
        // Chuyển sang trang xác thực
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VerifyScreen(email: email)),
        );
      } else {
        // Nếu không phải 'thành công', hiển thị thông báo lỗi
        setState(() {
          _message = response['message'] ?? 'Đăng ký thất bại!';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Đăng ký thất bại: $e';
      });
      print('Lỗi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng Ký')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(labelText: 'Họ Tên'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mật Khẩu'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Đăng Ký'),
            ),
            SizedBox(height: 20),
            Text(_message, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}