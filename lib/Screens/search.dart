// import 'package:flutter/material.dart';
// import '../Models/Song.dart'; // Import your Song model
// import '../Services/song_service.dart'; // Import the SongService
//
// class SearchScreen extends StatefulWidget {
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final SongService songService = SongService();
//   List<Song> _searchResults = [];
//   bool _isLoading = false;
//
//   void _searchSongs() async {
//     setState(() {
//       _isLoading = true;
//       _searchResults = []; // Clear previous results
//     });
//
//     try {
//       List<Song> results = await songService.findSongsByName(_controller.text);
//       print(results); // In ra kết quả để kiểm tra
//       setState(() {
//         _searchResults = results;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false; // Stop loading
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Search Songs')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                 labelText: 'Enter song name',
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.search),
//                   onPressed: _searchSongs, // Trigger search
//                 ),
//               ),
//             ),
//             SizedBox(height: 16.0),
//             _isLoading
//                 ? Center(child: CircularProgressIndicator()) // Center loading indicator
//                 : Expanded(
//               child: ListView.builder(
//                 itemCount: _searchResults.length,
//                 itemBuilder: (context, index) {
//                   final song = _searchResults[index];
//                   return ListTile(
//                     title: Row(
//                       children: [
//                         if (song.image != null)
//                           Padding(
//                             padding: const EdgeInsets.only(right: 8.0),
//                             child: Image.network(
//                               song.image!,
//                               width: 50,
//                               height: 50,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(song.name, style: TextStyle(fontWeight: FontWeight.bold)),
//                               Text(song.artist),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     onTap: () {
//                       if (song.url != null) {
//                         // Xử lý URL nếu không phải null
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('URL không có cho bài hát này')),
//                         );
//                       }
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//========================================
import 'package:flutter/material.dart';
import '../Models/Song.dart'; // Nhập mô hình Song
import '../Services/song_service.dart'; // Nhập SongService

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final SongService songService = SongService();
  List<Song> _allSongs = []; // Danh sách tất cả bài hát
  List<Song> _searchResults = []; // Danh sách bài hát tìm kiếm
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllSongs(); // Tải danh sách tất cả bài hát khi khởi tạo
  }

  Future<void> _loadAllSongs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Song> songs = await songService.getAllSongs();
      setState(() {
        _allSongs = songs; // Lưu danh sách bài hát
        _searchResults = songs; // Hiển thị toàn bộ danh sách khi mới vào
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Dừng trạng thái loading
      });
    }
  }

  void _searchSongs() {
    final query = _controller.text.trim().toLowerCase();

    setState(() {
      _isLoading = true; // Bắt đầu trạng thái loading
    });

    // Kiểm tra nếu trường tìm kiếm trống
    if (query.isEmpty) {
      setState(() {
        _searchResults = _allSongs; // Hiển thị toàn bộ danh sách bài hát
        _isLoading = false; // Dừng trạng thái loading
      });
      return;
    }

    // Lọc danh sách bài hát dựa trên query
    List<Song> results = _allSongs.where((song) {
      return song.name.toLowerCase().contains(query);
    }).toList();

    setState(() {
      _searchResults = results; // Cập nhật danh sách bài hát tìm kiếm
      _isLoading = false; // Dừng trạng thái loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Songs')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: (value) {
                _searchSongs(); // Tự động tìm kiếm khi nhập
              },
              decoration: InputDecoration(
                labelText: 'Enter song name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchSongs, // Gọi hàm tìm kiếm khi nhấn nút
                ),
              ),
            ),
            SizedBox(height: 16.0),
            _isLoading
                ? Center(child: CircularProgressIndicator()) // Hiển thị loading
                : Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final song = _searchResults[index];
                  return ListTile(
                    title: Row(
                      children: [
                        if (song.image != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.network(
                              song.image!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(song.name, style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(song.artist),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (song.url != null) {
                        // Xử lý URL nếu không phải null
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('URL không có cho bài hát này')),
                        );
                      }
                    },
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