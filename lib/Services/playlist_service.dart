import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../Models/Playlist.dart';
import '../Models/Song.dart';
class PlaylistService {
  final String baseUrl = 'http://10.0.2.2:8080/api/playlists';
  //final String baseUrl = 'http://localhost:8080/api/playlists';
  Future<List<Playlist>> fetchPlaylists() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      // Sử dụng utf8.decode để đảm bảo mã hóa đúng
      List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
      print('Fetched Playlists: $jsonData');
      return jsonData.map((json) => Playlist.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load playlists');
    }
  }
  Future<Map<String, dynamic>> createPlaylist(Playlist playlist, Uint8List imageBytes, String imageFileName) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/create'),
    );

    request.fields['name'] = playlist.name;
    request.fields['artist'] = playlist.artist ?? 'Nghệ Sĩ Mặc Định'; // Gán giá trị mặc định nếu là null

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageFileName,
      ),
    );

    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      final playlistResponse = Playlist.fromJson(json.decode(responseBody));
      return {'message': 'Playlist đã được tạo thành công!', 'playlist': playlistResponse};
    } else {
      final responseBody = await response.stream.bytesToString();
      print('Lỗi từ API: ${response.statusCode}, Nội dung: $responseBody');
      throw Exception('Không thể tạo playlist: ${responseBody}');
    }
  }
  Future<List<Song>> fetchSongs(int playlistId) async {
    final response = await http.get(Uri.parse('$baseUrl/$playlistId/songs'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
      return jsonData.map((json) => Song.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load songs');
    }
  }
  Future<void> addSongsToPlaylist(int playlistId, List<int> songIds) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$playlistId/songs'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(songIds),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Bài hát đã được thêm vào playlist thành công!');
    } else {
      final responseBody = utf8.decode(response.bodyBytes); // Sử dụng utf8.decode
      print('Lỗi từ API: ${response.statusCode}, Nội dung: $responseBody');
      throw Exception('Không thể thêm bài hát vào playlist: $responseBody');
    }
  }

  // Lấy bài hát theo nghệ sĩ
  Future<List<Song>> fetchSongsByArtist(String artist) async {
    if (artist.isEmpty) {
      return [];
    }

    final response = await http.get(Uri.parse('$baseUrl/songs?artist=$artist'));

    if (response.statusCode == 200) {
      List<dynamic> songJson = json.decode(utf8.decode(response.bodyBytes)); // Sử dụng utf8.decode
      return songJson.map((json) => Song.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load songs by artist');
    }
  }
}