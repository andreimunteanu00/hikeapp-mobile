import 'dart:typed_data';

class User {
  int? id;
  String? googleId;
  bool? firstLogin;
  String? username;
  String? email;
  String? phoneNumber;
  String? profilePicture;

  User({
    this.id,
    this.email,
    this.firstLogin,
    this.username,
    this.googleId,
    this.phoneNumber,
    this.profilePicture
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'googleId': googleId,
    'username': username,
    'firstLogin': firstLogin,
    'email': email,
    'phoneNumber': phoneNumber,
    'profilePicture': profilePicture
  };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstLogin: json['firstLogin'],
      username: json['username'],
      googleId: json['googleId'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profilePicture: json['profilePicture']
    );
  }
}