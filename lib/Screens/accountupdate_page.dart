import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/account_service.dart';
import 'dart:io';

class AccountUpdatePage extends StatefulWidget {
  @override
  _AccountUpdatePageState createState() => _AccountUpdatePageState();
}

class _AccountUpdatePageState extends State<AccountUpdatePage> {
  final _usernameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // Thêm trường xác nhận mật khẩu
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();
  final AccountService _accountService = AccountService();
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('fullName') ?? '';
      _imagePath = prefs.getString('imageUrl');
    });
  }

  Future<void> _updateAccount() async {
    final String userId = (await SharedPreferences.getInstance()).getString('userId') ?? '';

    if (userId.isEmpty) {
      _showErrorDialog('ID tài khoản không hợp lệ');
      return;
    }

    final Map<String, dynamic> accountData = {
      'fullName': _usernameController.text,
    };

    if (_isChangingPassword && _newPasswordController.text.isNotEmpty) {
      // Kiểm tra mật khẩu cũ
      final isValidPassword = await _accountService.validatePassword(userId, _oldPasswordController.text);

      // Kiểm tra nếu mật khẩu cũ hợp lệ
      if (isValidPassword['status'] != 'thành công') {
        _showErrorDialog('Mật khẩu cũ không đúng, vui lòng thử lại.');
        return;
      }

      // Kiểm tra mật khẩu mới và xác nhận
      if (_newPasswordController.text != _confirmPasswordController.text) {
        _showErrorDialog('Mật khẩu mới và xác nhận không trùng nhau.');
        return;
      }

      accountData['password'] = _newPasswordController.text;
    }

    print('Dữ liệu đang gửi đến API: $accountData');

    try {
      final result = await _accountService.updateAccount(userId, accountData, _imagePath);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fullName', accountData['fullName']);

      if (_imagePath != null) {
        await prefs.setString('imageUrl', result['image']);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật thành công! Đăng xuất để áp dụng thay đổi.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Lỗi khi cập nhật tài khoản: $e');
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
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
      appBar: AppBar(
        title: Text('Cập nhật tài khoản', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.orange),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _isChangingPassword,
                    onChanged: (value) {
                      setState(() {
                        _isChangingPassword = value!;
                        _oldPasswordController.clear();
                        _newPasswordController.clear();
                        _confirmPasswordController.clear(); // Xóa trường xác nhận khi thay đổi trạng thái
                      });
                    },
                  ),
                  Text('Thay đổi mật khẩu'),
                ],
              ),
              if (_isChangingPassword) ...[
                TextField(
                  controller: _oldPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu cũ',
                    labelStyle: TextStyle(color: Colors.orange),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
                    labelStyle: TextStyle(color: Colors.orange),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _confirmPasswordController, // Thêm trường xác nhận mật khẩu
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu mới',
                    labelStyle: TextStyle(color: Colors.orange),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
              ],
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Chọn ảnh đại diện', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              if (_imagePath != null && _imagePath!.startsWith('http'))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Image.network(
                    _imagePath!,
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                )
              else if (_imagePath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Image.file(
                    File(_imagePath!),
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateAccount,
                child: Text('Cập nhật', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}