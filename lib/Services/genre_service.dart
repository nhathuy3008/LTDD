import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/Genre.dart';

class GenreService {

  final String baseUrl = 'http://10.0.2.2:8080/api/genres';// Cập nhật URL cho API genres
  //final String baseUrl = 'http://localhost:8080/api/genres';
  //final String baseUrl = 'http://192.168.2.4:8080/api/genres';
  Future<List<Genre>> fetchGenres() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((genre) => Genre.fromJson(genre)).toList();
    } else {
      throw Exception('Không thể tải danh sách thể loại.');
    }
  }
}