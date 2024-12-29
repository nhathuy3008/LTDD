import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/account_service.dart';
import 'dart:io'; // Chỉ cần nếu bạn sử dụng trên mobile
import 'package:flutter/foundation.dart'; // Để sử dụng kIsWeb

class AccountUpdatePage extends StatefulWidget {
  @override
  _AccountUpdatePageState createState() => _AccountUpdatePageState();
}

class _AccountUpdatePageState extends State<AccountUpdatePage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _imagePath; // Đường dẫn đến ảnh
  final ImagePicker _picker = ImagePicker();
  final AccountService _accountService = AccountService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('fullName') ?? '';
      _imagePath = prefs.getString('imageUrl'); // Lưu lại URL ảnh nếu có
    });
  }

  Future<void> _updateAccount() async {
    final String userId = (await SharedPreferences.getInstance()).getString('userId') ?? '';
    final Map<String, dynamic> accountData = {
      'fullName': _usernameController.text,
      'password': _passwordController.text,
    };

    try {
      // Nếu có hình ảnh mới, upload hình ảnh trước

      final result = await _accountService.updateAccount(userId, accountData);

      // Cập nhật URL ảnh mới vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fullName', accountData['fullName']);

      // Lưu URL mới nếu có
      if (_imagePath != null) {
        await prefs.setString('imageUrl', result['image']); // Lưu URL từ phản hồi
      }

      print('Cập nhật thành công: $result');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật thành công!'),
          duration: Duration(seconds: 2),
        ),
      );

    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path; // Lưu đường dẫn ảnh
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
      appBar: AppBar(title: Text('Cập nhật tài khoản')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Tải lên ảnh mới'),
            ),
            if (_imagePath != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: kIsWeb // Kiểm tra nếu đang chạy trên web
                    ? Image.network(
                  _imagePath!, // Nếu image là URL
                  height: 100,
                  fit: BoxFit.cover,
                )
                    : Image.file(
                  File(_imagePath!), // Nếu là file cục bộ
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateAccount,
              child: Text('Cập nhật'),
            ),
          ],
        ),
      ),
    );
  }
}



