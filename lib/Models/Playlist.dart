class Playlist {
  int id;
  String name;
  String? artist; // Thêm trường artist
  String? image;
  List<int> songIds; // Danh sách ID bài hát

  Playlist({
    required this.id,
    required this.name,
    this.artist, // Thay đổi trường artist thành optional
    this.image,
    required this.songIds,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    print(json); // In ra dữ liệu JSON để kiểm tra
    return Playlist(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Tên Playlist Mặc Định', // Gán mặc định cho name
      artist: json['artist'] ?? 'Nghệ Sĩ Mặc Định', // Gán mặc định cho artist
      image: json['image'],
      songIds: List<int>.from(json['songs']?.map((song) => song['id']) ?? []), // Kiểm tra trường 'songs'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artist': artist, // Thêm trường artist vào JSON
      'image': image,
      'songIds': songIds,
    };
  }
}