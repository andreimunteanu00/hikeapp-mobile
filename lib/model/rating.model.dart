import 'package:hikeappmobile/model/user.model.dart';


class Rating {
  User? user;
  String? comment;
  DateTime? dateTimeRate;
  double? rating;

  Rating({
    this.user,
    this.comment,
    this.dateTimeRate,
    this.rating
  });

  Map<String, dynamic> toJson() => {
    'user': user,
    'comment': comment,
    'dateTimeRate': dateTimeRate,
    'rating': rating
  };

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
        user: User.fromJson(json['user']),
        comment: json['comment'],
        dateTimeRate: DateTime.parse(json['dateTimeRate']),
        rating: json['rating']
    );
  }
}