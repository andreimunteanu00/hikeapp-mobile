class User {
  String? googleId;
  bool? firstLogin;
  bool? blocked;
  String? username;
  String? email;
  String? profilePicture;

  User({
    this.email,
    this.firstLogin,
    this.blocked,
    this.username,
    this.googleId,
    this.profilePicture
  });

  Map<String, dynamic> toJson() => {
    'googleId': googleId,
    'username': username,
    'firstLogin': firstLogin,
    'blocked': blocked,
    'email': email,
    'profilePicture': profilePicture
  };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstLogin: json['firstLogin'],
      username: json['username'],
      blocked: json['blocked'],
      googleId: json['googleId'],
      email: json['email'],
      profilePicture: json['profilePicture']
    );
  }
}