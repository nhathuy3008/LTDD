class Song {
  final int id;
  final String name;
  final String artist;
  final String? url; // Có thể là null
  final String? image; // Có thể là null
  final Genre genre;
  final int likeCount;

  Song({
    required this.id,
    required this.name,
    required this.artist,
    this.url,
    this.image,
    required this.genre,
    required this.likeCount,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      name: json['name'],
      artist: json['artist'],
      url: json['url'], // URL có thể là null
      image: json['image'], // Ảnh có thể là null
      genre: Genre.fromJson(json['genre']),
      likeCount: json['likeCount'],
    );
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      name: json['name'],
    );
  }
}