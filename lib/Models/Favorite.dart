class Favorite {
  int id;
  String accountId; // UUID của Account
  int songId; // ID của Song

  Favorite({
    required this.id,
    required this.accountId,
    required this.songId,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      accountId: json['accountId'],
      songId: json['songId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'songId': songId,
    };
  }
}