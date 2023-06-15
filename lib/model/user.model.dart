import 'package:hikeappmobile/model/picture.model.dart';

class User {
  String? googleId;
  bool? firstLogin;
  bool? active;
  String? username;
  String? email;
  Picture? profilePicture;
  double? hikePoints;

  User(
      {this.email,
      this.firstLogin,
      this.active,
      this.username,
      this.googleId,
      this.hikePoints,
      this.profilePicture});

  Map<String, dynamic> toJson() => {
        'googleId': googleId,
        'username': username,
        'firstLogin': firstLogin,
        'active': active,
        'hikePoints': hikePoints,
        'email': email,
        'profilePicture': profilePicture
      };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        firstLogin: json['firstLogin'],
        username: json['username'],
        active: json['active'],
        googleId: json['googleId'],
        email: json['email'],
        hikePoints: json['hikePoints'],
        profilePicture: Picture.fromJson(json['profilePicture']));
  }
}
