import '../Models/Playlist.dart';
import 'package:flutter/material.dart';
import '../Services/playlist_service.dart'; // Dịch vụ để gọi API lấy bài hát
import '../Models/Song.dart'; // Mô hình bài hát
import '../Screens/play_song.dart'; // Nhớ import màn hình phát nhạc
import '../Screens/create_song_to_playlist.dart'; // Nhập màn hình thêm bài hát vào playlist

class SongListPage extends StatefulWidget {
  final Playlist playlist; // Đối tượng Playlist

  SongListPage({required this.playlist}); // Cập nhật constructor để nhận đối tượng Playlist

  @override
  _SongListPageState createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  List<Song> songs = [];
  final PlaylistService _playlistService = PlaylistService();

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  _fetchSongs() async {
    try {
      List<Song> fetchedSongs = await _playlistService.fetchSongs(widget.playlist.id); // Sử dụng playlist.id
      setState(() {
        songs = fetchedSongs;
      });
    } catch (e) {
      print('Error fetching songs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách bài hát'),
      ),
      body: songs.isEmpty
          ? Center(child: Text('Không có bài hát nào trong playlist này.')) // Hiển thị thông báo nếu danh sách bài hát trống
          : ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Chuyển đến màn hình phát nhạc khi bấm vào bài hát
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaySongScreen(
                    playlist: songs, // Truyền danh sách bài hát
                    currentSongIndex: index, // Bài hát hiện tại
                    accountId: '', // Truyền accountId nếu cần
                  ),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                leading: songs[index].image != null && songs[index].image!.isNotEmpty
                    ? ClipOval(
                  child: Image.network(
                    songs[index].image!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
                    : CircleAvatar(child: Icon(Icons.music_note)), // Biểu tượng mặc định nếu không có hình
                title: Text(songs[index].name),
                subtitle: Text(songs[index].artist),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Chuyển đến trang thêm bài hát vào playlist
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddSongsToPlaylistPage(playlist: widget.playlist), // Truyền đối tượng Playlist
            ),
          );
        },
        child: Icon(Icons.add), // Biểu tượng +
        backgroundColor: Colors.orange, // Màu nền của nút
      ),
    );
  }
}