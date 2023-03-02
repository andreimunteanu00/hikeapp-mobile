import 'package:hikeappmobile/model/picture.model.dart';

class Hike {
  String? title;
  String? description;
  double? allRatings;
  int? numberRatings;
  Picture? mainPicture;
  List<Picture?>? pictureList;

  Hike({
    this.title,
    this.description,
    this.allRatings,
    this.numberRatings,
    this.mainPicture,
    this.pictureList
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'allRatings': allRatings,
    'numberRatings': numberRatings,
    'mainPicture': mainPicture,
    'pictureList': pictureList
  };

  factory Hike.fromJson(Map<String, dynamic> json) {
    return Hike(
        title: json['title'],
        description: json['description'],
        allRatings: json['allRatings'],
        numberRatings: json['numberRatings'],
        mainPicture: Picture.fromJson(json['mainPicture'])
    );
  }

  factory Hike.fromJsonPictureList(Map<String, dynamic> json) {
    return Hike(
        title: json['title'],
        description: json['description'],
        allRatings: json['allRatings'],
        numberRatings: json['numberRatings'],
        pictureList: (json['pictureList'] as List<dynamic>)
            .map((e) => e == null ? null : Picture.fromJson(e))
            .toList()
    );
  }
}