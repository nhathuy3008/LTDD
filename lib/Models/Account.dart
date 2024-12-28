class Account {
  String id; // UUID
  String fullName;
  String email;
  String password;
  String? image;
  bool enabled;
  String? verificationToken;

  Account({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    this.image,
    this.enabled = false,
    this.verificationToken,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? 'Người dùng', // Giá trị mặc định
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      image: json['image'],
      enabled: json['enabled'] ?? false,
      verificationToken: json['verificationToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'image': image,
      'enabled': enabled,
      'verificationToken': verificationToken,
    };
  }
}