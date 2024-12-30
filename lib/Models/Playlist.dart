class Playlist {
  int id;
  String name;
  String accountId; // UUID của Account
  String? image;
  List<int> songIds; // Danh sách ID bài hát

  Playlist({
    required this.id,
    required this.name,
    required this.image,
    required this.accountId,
    required this.songIds,
  });
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      accountId: json['owner']['id'], // Lấy accountId từ owner
      songIds: List<int>.from(json['songs'].map((song) => song['id'])), // Sửa thành 'songs'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'accountId': accountId,
      'songIds': songIds,
    };
  }
}