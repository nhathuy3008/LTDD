import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './accountupdate_page.dart';
import '../Services/playlist_service.dart';
import '../Models/Playlist.dart';

import 'search.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userId;
  String? fullName;
  String? image;
  List<Playlist> playlists = [];
  final PlaylistService _playlistService = PlaylistService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchPlaylists();
  }

  _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
      fullName = prefs.getString('fullName');
      image = prefs.getString('image');
    });
  }

  _fetchPlaylists() async {
    try {
      List<Playlist> fetchedPlaylists = await _playlistService.fetchPlaylists();
      setState(() {
        playlists = fetchedPlaylists;
      });
    } catch (e) {
      print('Error fetching playlists: $e');
    }
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

  void _showLoginPrompt(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else if (index == 1) {
      if (userId == null) {
        _showLoginPrompt('Vui lòng đăng nhập để tìm kiếm bài hát.');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchScreen()),
        );
      }
    } else if (index == 2) {
      if (userId == null) {
        _showLoginPrompt('Vui lòng đăng nhập để quản lý thông tin cá nhân.');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AccountUpdatePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: fullName != null
            ? Row(
          children: [
            if (image != null && image!.isNotEmpty)
              CircleAvatar(
                backgroundImage: NetworkImage(image!),
                radius: 20,
              ),
            SizedBox(width: 8),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              'Danh sách album',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 5),
          Expanded(
            child: playlists.isNotEmpty
                ? ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: GestureDetector(
                      onTap: userId != null
                          ? () {

                      }
                          : () => _showLoginPrompt(
                          'Vui lòng đăng nhập để xem danh sách bài hát.'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (playlists[index].image != null &&
                              playlists[index].image!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10)),
                              child: Image.network(
                                playlists[index].image!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              playlists[index].name,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
                : Center(child: Text('Không có playlist nào.')),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Tìm kiếm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
