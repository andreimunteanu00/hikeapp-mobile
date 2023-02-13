class User {
  bool? firstLogin;
  String? username;
  String? googleId;

  User({this.firstLogin, this.username, this.googleId});

  Map<String, dynamic> toJson() => {
    'username': username,
    'googleId': googleId,
    'firstLogin': firstLogin,
  };

  factory User.fromJson(Map<String, dynamic> json) {
    print(json);
    return User(
      firstLogin: json['firstLogin'],
      username: json['username'],
      googleId: json['googleId']
    );
  }
}