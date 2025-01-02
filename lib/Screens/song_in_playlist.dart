import 'package:flutter/material.dart';
import '../Services/playlist_service.dart'; // Dịch vụ để gọi API lấy bài hát
import '../Models/Song.dart'; // Mô hình bài hát

class SongListPage extends StatefulWidget {
  final int playlistId; // ID của playlist

  SongListPage({required this.playlistId});

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
      List<Song> fetchedSongs = await _playlistService.fetchSongs(widget.playlistId);
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
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Xử lý khi bấm vào bài hát, ví dụ: phát bài hát
              print('Playing ${songs[index].name}');
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
    );
  }
}