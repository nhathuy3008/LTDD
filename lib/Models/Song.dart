class Song {
  int id;
  String name;
  String artist;
  String url; // Đường dẫn file nhạc
  String? image;
  int genreId;
  int likeCount;

  Song({
    required this.id,
    required this.name,
    required this.artist,
    required this.url,
    this.image,
    required this.genreId,
    this.likeCount = 0,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      name: json['name'],
      artist: json['artist'],
      url: json['url'],
      image: json['image'],
      genreId: json['genreId'],
      likeCount: json['likeCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artist': artist,
      'url': url,
      'image': image,
      'genreId': genreId,
      'likeCount': likeCount,
    };
  }
}