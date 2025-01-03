import 'package:flutter/material.dart';
import '../Models/Song.dart'; // Nhập mô hình Song
import '../Services/song_service.dart'; // Nhập SongService
import 'play_song.dart'; // Nhập PlaySongScreen

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final SongService songService = SongService();
  List<Song> _allSongs = [];
  List<Song> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllSongs();
  }

  Future<void> _loadAllSongs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Song> songs = await songService.getAllSongs();
      setState(() {
        _allSongs = songs;
        _searchResults = songs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchSongs() {
    final query = _controller.text.trim().toLowerCase();

    setState(() {
      _isLoading = true;
    });

    if (query.isEmpty) {
      setState(() {
        _searchResults = _allSongs;
        _isLoading = false;
      });
      return;
    }

    List<Song> results = _allSongs.where((song) {
      return song.name.toLowerCase().contains(query);
    }).toList();

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tìm kiếm bài hát')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: (value) {
                _searchSongs();
              },
              decoration: InputDecoration(
                labelText: 'Nhập tên bài hát',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchSongs,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Colors.orange),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Colors.orange, width: 2.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final song = _searchResults[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16.0),
                      leading: song.image != null
                          ? ClipOval(
                        child: Image.network(
                          song.image!,
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
                        song.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        song.artist,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      onTap: () {
                        if (song.url.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlaySongScreen(
                                playlist: _allSongs,
                                currentSongIndex: index,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('URL không có cho bài hát này')),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}