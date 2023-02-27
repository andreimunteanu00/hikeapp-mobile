import 'package:hikeappmobile/model/hike.model.dart';
import 'package:hikeappmobile/model/user.model.dart';


class Rating {
  Hike? hike;
  User? user;
  String? comment;
  DateTime? dateTimeRate;
  double? rating;

  Rating({
    this.hike,
    this.user,
    this.comment,
    this.dateTimeRate,
    this.rating
  });

  Map<String, dynamic> toJson() => {
    'hike': hike,
    'user': user,
    'comment': comment,
    'dateTimeRate': dateTimeRate,
    'rating': rating
  };

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
        hike: Hike.fromJson(json['hike']),
        user: User.fromJson(json['user']),
        comment: json['comment'],
        dateTimeRate: DateTime.parse(json['dateTimeRate']),
        rating: json['rating']
    );
  }
}