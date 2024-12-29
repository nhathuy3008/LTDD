import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userId;
  String? fullName;
  String? image;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
      fullName = prefs.getString('fullName');
      image = prefs.getString('image');
      print('Image URL: $image');
    });
  }

  _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('fullName');
    await prefs.remove('image');
    setState(() {
      userId = null;
      fullName = null;
      image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: fullName != null
              ? Row(
              children: [
          if (image != null && image!.isNotEmpty)
          GestureDetector(

            child: CircleAvatar(
              backgroundImage: NetworkImage(image!),
              radius: 20,
            ),
          ),
          SizedBox(width: 8), // Khoảng cách giữa ảnh và chữ
            Text('Chào, $fullName'),
            ],
          )
              : Text('Home'),
      backgroundColor: Colors.orange,
      actions: [
        if (fullName != null)
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'logout') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Xác nhận đăng xuất'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _logout();
                          Navigator.of(context).pop();
                        },
                        child: Text('Có'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Không'),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Text('Đăng xuất'),
              ),
            ],
          )
        else
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('Đăng nhập'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text('Đăng ký'),
              ),
            ],
          ),
      ],
    ),
    body: Center(
    child: image != null && image!.isNotEmpty
    ? Image.network(
    image!,
    width: 100,
    height: 100,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
    return Text('Không thể tải ảnh');
    },
    )
        : Text('Ảnh không có hoặc không hợp lệ.'),
    ),
    );
  }
}