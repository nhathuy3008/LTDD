import 'package:flutter/material.dart';
import '../Models/Playlist.dart';
import '../Models/Song.dart';
import '../Services/playlist_service.dart';

class AddSongsToPlaylistPage extends StatefulWidget {
  final Playlist playlist;

  AddSongsToPlaylistPage({required this.playlist});

  @override
  _AddSongsToPlaylistPageState createState() => _AddSongsToPlaylistPageState();
}

class _AddSongsToPlaylistPageState extends State<AddSongsToPlaylistPage> {
  final PlaylistService _playlistService = PlaylistService();
  List<Song> _allSongs = []; // Danh sách tất cả các bài hát
  List<int> _selectedSongIds = []; // Danh sách các ID bài hát được chọn
  bool _isLoading = true; // Biến để theo dõi trạng thái tải

  @override
  void initState() {
    super.initState();
    _fetchSongs(); // Lấy danh sách bài hát
  }

  Future<void> _fetchSongs() async {
    try {
      String artist = widget.playlist.artist ?? 'Nghệ Sĩ Mặc Định'; // Gán giá trị mặc định nếu artist là null
      List<Song> allSongs = await _playlistService.fetchSongsByArtist(artist);
      List<Song> currentSongs = await _playlistService.fetchSongs(widget.playlist.id); // Lấy các bài hát hiện có trong playlist

      // Lọc ra những bài hát chưa có trong playlist
      _allSongs = allSongs.where((song) => !currentSongs.any((currentSong) => currentSong.id == song.id)).toList();
    } catch (e) {
      print('Error fetching songs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi lấy bài hát.')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Cập nhật trạng thái tải
      });
    }
  }

  void _toggleSongSelection(int songId) {
    setState(() {
      if (_selectedSongIds.contains(songId)) {
        _selectedSongIds.remove(songId);
      } else {
        _selectedSongIds.add(songId);
      }
    });
  }

  Future<void> _addSongsToPlaylist() async {
    if (_selectedSongIds.isNotEmpty) {
      try {
        await _playlistService.addSongsToPlaylist(widget.playlist.id, _selectedSongIds);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bài hát đã được thêm vào playlist thành công!')),
        );
        Navigator.pop(context); // Quay lại trang trước
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn ít nhất một bài hát!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm Bài Hát Vào Playlist của ${widget.playlist.name}'),
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Hiển thị vòng tròn tải khi đang tải dữ liệu
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Playlist của nghệ sĩ: ${widget.playlist.artist}', // Hiển thị tên nghệ sĩ
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _allSongs.length,
              itemBuilder: (context, index) {
                final song = _allSongs[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  leading: song.image != null
                      ? Image.network(
                    song.image!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : Container(width: 50, height: 50, color: Colors.grey), // Placeholder if no image
                  title: Text(song.name),
                  subtitle: Text(song.artist),
                  trailing: Checkbox(
                    value: _selectedSongIds.contains(song.id),
                    onChanged: (bool? value) {
                      _toggleSongSelection(song.id);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _addSongsToPlaylist,
              child: Text('Thêm Bài Hát'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}