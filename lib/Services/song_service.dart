// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../Models/Song.dart'; // Nhập mô hình Song
//
// class SongService {
//   // Đặt URL cơ sở ở đây
//   final String baseUrl = 'http://localhost:8080/api/songs';
//   //
//   //
//   // final String baseUrl = 'http://10.0.2.2:8080/api/songs';
//   Future<List<Song>> findSongsByName(String name) async {
//     final response = await http.get(
//       Uri.parse('$baseUrl/find/$name'),
//       headers: {
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       List<dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
//       return jsonResponse.map((song) => Song.fromJson(song)).toList();
//     } else {
//       throw Exception('Không thể tải bài hát');
//     }
//   }
// }
//===============================
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/Song.dart'; // Nhập mô hình Song

class SongService {
  // Đặt URL cơ sở ở đây
  final String baseUrl = 'http://localhost:8080/api/songs'; // Bạn có thể thay đổi thành 'http://10.0.2.2:8080/api/songs' khi chạy trên trình giả lập

  /// Tìm kiếm bài hát theo tên.
  Future<List<Song>> findSongsByName(String name) async {
    final response = await http.get(
      Uri.parse('$baseUrl/find/$name'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // Kiểm tra mã trạng thái của phản hồi
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((song) => Song.fromJson(song)).toList();
    } else if (response.statusCode == 404) {
      throw Exception('Không tìm thấy bài hát');
    } else {
      throw Exception('Không thể tải bài hát: ${response.statusCode}');
    }
  }

  /// Lấy tất cả bài hát từ API.
  Future<List<Song>> getAllSongs() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // Kiểm tra mã trạng thái của phản hồi
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((song) => Song.fromJson(song)).toList();
    } else {
      throw Exception('Không thể tải danh sách bài hát');
    }
  }
}