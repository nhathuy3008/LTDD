import 'package:flutter/material.dart';
import '../Services/account_service.dart';
import '../Screens/verify_page.dart'; // Nhập trang VerifyScreen
import 'login_page.dart'; // Thêm import cho LoginPage

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
      final response = await _accountService.createAccount(accountData);
      print('Phản hồi từ API: $response');

      if (response['status'] == 'thành công') {
        setState(() {
          _message = response['message'];
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VerifyScreen(email: email)),
        );
      } else {
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
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  "assets/images/vector-2.png",
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.4,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Đăng Ký',
                style: TextStyle(
                  color: Color(0xFF755DC1),
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Họ Tên',
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
                      color: Color(0xFF837E93),
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
              const SizedBox(height: 15),
              TextField(
                controller: _emailController,
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
                      color: Color(0xFF837E93),
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
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mật Khẩu',
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
                      color: Color(0xFF837E93),
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
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9F7BFF),
                    ),
                    child: const Text(
                      'Đăng Ký',
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
              Text(_message, style: TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Đã có tài khoản?',
                    style: TextStyle(
                      color: Color(0xFF837E93),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 2.5),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context); // Quay lại trang đăng nhập
                    },
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(
                        color: Color(0xFF755DC1),
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}