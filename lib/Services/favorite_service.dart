import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/Song.dart';
import '../Models/Favorite.dart';

class FavoriteService {
  final String baseUrl = 'http://192.168.2.4:8080/api/favorites';
  //final String baseUrl = 'http://localhost:8080/api/favorites';
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }

  Future<List<Song>> getFavoriteSongs() async {
    String accountId = await getUserId();
    if (accountId.isEmpty) {
      throw Exception('Account ID cannot be empty.');
    }

    final response = await http.get(Uri.parse('$baseUrl/account/$accountId/songs'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((song) => Song.fromJson(song)).toList();
    } else {
      throw Exception('Failed to load favorite songs. Status code: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<Favorite> likeSong(String songId) async {
    String accountId = await getUserId();
    if (accountId.isEmpty) {
      throw Exception('Account ID cannot be empty.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/like'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'account': {'id': accountId}, 'song': {'id': songId}}),
    );

    if (response.statusCode == 200) {
      return Favorite.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to like the song. Status code: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<int> countLikesForSong(String songId) async {
    final response = await http.get(Uri.parse('$baseUrl/song/$songId/likes/count'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to count likes for the song. Status code: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<void> unlikeSong(String songId) async {
    String accountId = await getUserId();
    if (accountId.isEmpty) {
      throw Exception('Account ID cannot be empty.');
    }

    final response = await http.delete(Uri.parse('$baseUrl/unlike/$accountId/$songId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to unlike the song. Status code: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<bool> checkIfLiked(String songId) async {
    String accountId = await getUserId();
    if (accountId.isEmpty) {
      throw Exception('Account ID cannot be empty.');
    }

    final response = await http.get(Uri.parse('$baseUrl/account/$accountId/song/$songId/liked'));

    if (response.statusCode == 200) {
      return json.decode(response.body); // Giả sử đây là một giá trị boolean
    } else {
      throw Exception('Failed to check if liked. Status code: ${response.statusCode}, Body: ${response.body}');
    }
  }
}