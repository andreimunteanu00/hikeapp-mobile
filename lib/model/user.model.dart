class User {
  int? id;
  String? googleId;
  bool? firstLogin;
  String? username;
  String? email;
  String? phoneNumber;

  User({
    this.id,
    this.email,
    this.firstLogin,
    this.username,
    this.googleId,
    this.phoneNumber
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'googleId': googleId,
    'username': username,
    'firstLogin': firstLogin,
    'email': email,
    'phoneNumber': phoneNumber
  };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstLogin: json['firstLogin'],
      username: json['username'],
      googleId: json['googleId'],
      email: json['email'],
      phoneNumber: json['phoneNumber']
    );
  }
}