class User {
  bool? firstLogin;
  String? firstName;
  String? lastName;
  String? googleId;

  User({this.firstLogin, this.firstName, this.lastName, this.googleId});

  factory User.fromJson(Map<String, dynamic> json) {
    print(json);
    return User(
        firstLogin: json['firstLogin'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      googleId: json['googleId']
    );
  }
}