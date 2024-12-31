import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/Playlist.dart';
import '../Models/Song.dart';
class PlaylistService {

  final String baseUrl = 'http://localhost:8080/api/playlists';
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
}