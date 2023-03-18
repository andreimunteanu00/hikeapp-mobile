import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hikeappmobile/model/picture.model.dart';

class Hike {
  String? title;
  String? description;
  double? allRatings;
  int? numberRatings;
  Picture? mainPicture;
  List<Picture?>? pictureList;
  String? difficulty;
  LatLng? startPoint;
  LatLng? endPoint;

  Hike({
    this.title,
    this.description,
    this.allRatings,
    this.numberRatings,
    this.mainPicture,
    this.pictureList,
    this.difficulty,
    this.startPoint,
    this.endPoint
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'allRatings': allRatings,
        'numberRatings': numberRatings,
        'mainPicture': mainPicture,
        'pictureList': pictureList,
        'difficulty': difficulty,
        'startPoint': startPoint,
        'endPoint': endPoint
      };

  factory Hike.fromJson(Map<String, dynamic> json) {
    return Hike(
        title: json['title'],
        description: json['description'],
        allRatings: json['allRatings'],
        numberRatings: json['numberRatings'],
        mainPicture: Picture.fromJson(json['mainPicture']),
        difficulty: json['difficulty']);
  }

  factory Hike.fromJsonDetail(Map<String, dynamic> json) {
    return Hike(
      title: json['title'],
      description: json['description'],
      allRatings: json['allRatings'],
      numberRatings: json['numberRatings'],
      pictureList: (json['pictureList'] as List<dynamic>)
          .map((e) => e == null ? null : Picture.fromJson(e))
          .toList(),
      difficulty: json['difficulty'],
      startPoint: LatLng(
          json['startPoint']['latitude'], json['startPoint']['longitude']),
      endPoint:
          LatLng(json['endPoint']['latitude'], json['endPoint']['longitude']),
    );
  }
}
