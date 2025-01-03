import 'package:flutter/material.dart';
import './login_page.dart';
import 'register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './accountupdate_page.dart';
import '../Services/playlist_service.dart';
import '../Models/Playlist.dart';
import './song_in_playlist.dart';
import 'search.dart';
import './create_song.dart';
import './create_playlist.dart';
import '../Models/Favorite.dart';
import '../Screens/list_favorite.dart';

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
        _showLoginPrompt('Vui lòng đăng nhập để xem bài hát yêu thích.');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FavoriteSongsPage(accountId: userId!)),
        );
      }
    } else if (index == 3) {
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

  Widget _buildProfileButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (image != null && image!.isNotEmpty)
          CircleAvatar(
            backgroundImage: NetworkImage(image!),
            radius: 12,
          )
        else
          Icon(
            Icons.person,
            size: 24,
            color: Colors.grey,
          ),
        SizedBox(width: 4),
        Text(
          fullName != null ? fullName! : 'Cá nhân',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double baseFontSize = screenSize.width * 0.025;

    return Scaffold(
      appBar: AppBar(
        title: fullName != null
            ? Row(
          children: [
            if (image != null && image!.isNotEmpty)
              CircleAvatar(
                backgroundImage: NetworkImage(image!),
                radius: baseFontSize * 2,
              ),
            SizedBox(width: 8),
            Text('Chào, $fullName', style: TextStyle(fontSize: baseFontSize * 1.5)),
          ],
        )
            : Text('Home'),
        backgroundColor: Colors.orange,
        actions: [
          if (userId != null)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreatePlaylistPage()),
                );
              },
            ),
          if (fullName != null)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
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
              },
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
                  child: Text('Đăng nhập', style: TextStyle(fontSize: baseFontSize)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text('Đăng ký', style: TextStyle(fontSize: baseFontSize)),
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
              style: TextStyle(fontSize: baseFontSize * 2, fontWeight: FontWeight.bold),
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
                        if (playlists[index].id != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SongListPage(playlistId: playlists[index].id!),
                            ),
                          );
                        } else {
                          _showLoginPrompt('ID playlist không hợp lệ.');
                        }
                      }
                          : () => _showLoginPrompt('Vui lòng đăng nhập để xem danh sách bài hát.'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (playlists[index].image != null && playlists[index].image!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 60.0), // Increase horizontal padding
                                child: Container(
                                  height: screenSize.height * 0.2, // Keep the height as is
                                  width: double.infinity, // Use full width within padding
                                  child: Image.network(
                                    playlists[index].image!,
                                    fit: BoxFit.fill, // Use BoxFit.fill
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              playlists[index].name,
                              style: TextStyle(fontSize: baseFontSize * 1.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
                : Center(child: Text('Không có playlist nào.', style: TextStyle(fontSize: baseFontSize))),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 14), // Add a SizedBox for additional space above
                Icon(Icons.home, size: baseFontSize * 1.5),
                SizedBox(height: 4),
                Text('Trang chủ', style: TextStyle(fontSize: baseFontSize)),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: baseFontSize * 1.5),
                SizedBox(height: 4),
                Text('Tìm kiếm', style: TextStyle(fontSize: baseFontSize)),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, size: baseFontSize * 1.5),
                SizedBox(height: 4),
                Text('Yêu thích', style: TextStyle(fontSize: baseFontSize)),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (image != null && image!.isNotEmpty)
                  CircleAvatar(
                    backgroundImage: NetworkImage(image!),
                    radius: baseFontSize * 0.8, // Reduce the radius to 80% of the original size
                  )
                else
                  Icon(
                    Icons.person,
                    size: baseFontSize * 1.5,
                    color: Colors.grey,
                  ),
                SizedBox(height: 4),
                Text(
                  fullName != null ? fullName! : 'Cá nhân',
                  style: TextStyle(color: Colors.grey, fontSize: baseFontSize),
                ),
              ],
            ),
            label: '',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      floatingActionButton: userId != null
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateSongPage()),
          );
        },
        child: Icon(Icons.upload_file),
        backgroundColor: Colors.orange,
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}