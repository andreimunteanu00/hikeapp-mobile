class User {
  String? googleId;
  bool? firstLogin;
  bool? active;
  String? username;
  String? email;
  String? profilePicture;

  User({
    this.email,
    this.firstLogin,
    this.active,
    this.username,
    this.googleId,
    this.profilePicture
  });

  Map<String, dynamic> toJson() => {
    'googleId': googleId,
    'username': username,
    'firstLogin': firstLogin,
    'active': active,
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
      profilePicture: json['profilePicture']
    );
  }
}