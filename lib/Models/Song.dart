class Song {
  int id;
  String name;
  String artist;
  String url; // Đường dẫn file nhạc
  String? image; // Hình ảnh có thể là null
  int genreId;
  int likeCount;

  Song({
    required this.id,
    required this.name,
    required this.artist,
    required this.url,
    this.image,
    required this.genreId,
    required this.likeCount,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? 'Unknown',
      artist: json['artist'] ?? 'Unknown Artist',
      url: json['url'] ?? '',
      image: json['image'] ?? null, // Đặt thành null nếu không có hình ảnh
      genreId: json['genre'] != null ? (json['genre']['id'] is int ? json['genre']['id'] : int.tryParse(json['genre']['id'].toString()) ?? 0) : 0,
      likeCount: json['likeCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'artist': artist,
      'url': url,
      'image': image,
      'genre': {
        'id': genreId,
      },
      'likeCount': likeCount,
    };
  }
}