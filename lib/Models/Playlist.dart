class Playlist {
  int id;
  String name;
  String accountId; // UUID của Account
  List<int> songIds; // Danh sách ID bài hát

  Playlist({
    required this.id,
    required this.name,
    required this.accountId,
    required this.songIds,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      accountId: json['accountId'],
      songIds: List<int>.from(json['songIds']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'accountId': accountId,
      'songIds': songIds,
    };
  }
}