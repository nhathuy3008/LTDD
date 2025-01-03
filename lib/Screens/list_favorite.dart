import 'package:flutter/material.dart';
import '../Models/Song.dart';
import '../Services/favorite_service.dart';
import '../Screens/play_song.dart'; // Nhớ import màn hình phát nhạc

class FavoriteSongsPage extends StatefulWidget {
  final String accountId;

  FavoriteSongsPage({required this.accountId});

  @override
  _FavoriteSongsPageState createState() => _FavoriteSongsPageState();
}

class _FavoriteSongsPageState extends State<FavoriteSongsPage> {
  late Future<List<Song>> futureFavoriteSongs;

  @override
  void initState() {
    super.initState();
    futureFavoriteSongs = FavoriteService().getFavoriteSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bài hát yêu thích'),
      ),
      body: FutureBuilder<List<Song>>(
        future: futureFavoriteSongs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Bạn chưa thích bài hát nào.'));
          } else {
            List<Song> songs = snapshot.data!;
            return ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    leading: songs[index].image != null && songs[index].image!.isNotEmpty
                        ? ClipOval(
                      child: Image.network(
                        songs[index].image!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Icon(
                      Icons.music_note,
                      size: 50,
                      color: Colors.grey,
                    ),
                    title: Text(
                      songs[index].name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'Nghệ sĩ: ${songs[index].artist}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    onTap: () {
                      // Chuyển đến màn hình phát nhạc khi bấm vào bài hát
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaySongScreen(
                            playlist: songs, // Truyền danh sách bài hát
                            currentSongIndex: index, // Chỉ số bài hát hiện tại
                            accountId: widget.accountId, // Truyền accountId
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Hành động khi bấm nút (nếu cần)
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}