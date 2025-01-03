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
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../Models/Song.dart'; // Nhập mô hình Song

class SongService {
  // Đặt URL cơ sở ở đây
  //final String baseUrl = 'http://localhost:8080/api/songs'; // Bạn có thể thay đổi thành 'http://10.0.2.2:8080/api/songs' khi chạy trên trình giả lập
  final String baseUrl = 'http://10.0.2.2:8080/api/songs';
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
  Future<Song> createSong(Song song, Uint8List audioBytes, String audioFileName, Uint8List imageBytes, String imageFileName) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/create'),
    );

    // Thêm thông tin bài hát
    request.fields['name'] = song.name;
    request.fields['artist'] = song.artist;
    request.fields['genre_id'] = song.genreId.toString();

    // Thêm tệp âm thanh
    request.files.add(
      http.MultipartFile.fromBytes(
        'file', // Tên trường trong API cho âm thanh
        audioBytes,
        filename: audioFileName,
      ),
    );

    // Thêm tệp hình ảnh
    request.files.add(
      http.MultipartFile.fromBytes(
        'image', // Tên trường cho hình ảnh trong API
        imageBytes,
        filename: imageFileName,
      ),
    );

    try {
      final response = await request.send();

      // Kiểm tra mã trạng thái phản hồi
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        return Song.fromJson(json.decode(responseBody));
      } else {
        final responseBody = await response.stream.bytesToString(); // Lấy nội dung phản hồi
        print('Lỗi từ API: ${response.statusCode}, ${responseBody}');
        throw Exception('Không thể tạo bài hát.');
      }
    } catch (e) {
      print('Lỗi khi gửi yêu cầu: $e');
      throw Exception('Lỗi mạng hoặc kết nối.');
    }
  }
  Future<String> playSong(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/play/$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // Giả sử API trả về URL của bài hát
      return jsonDecode(response.body)['url']; // Cập nhật để lấy URL từ phản hồi
    } else if (response.statusCode == 404) {
      throw Exception('Bài hát không tồn tại.');
    } else {
      throw Exception('Lỗi khi phát bài hát: ${response.statusCode}');
    }
  }
}