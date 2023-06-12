import 'hike.model.dart';

class HikeHistory {
  DateTime? createdDateTime;
  Duration? elapsedTime;
  double? hikePoints;
  Hike? hike;

  HikeHistory({
    this.createdDateTime,
    this.elapsedTime,
    this.hikePoints,
    this.hike,
  });

  Map<String, dynamic> toJson() => {
        'createdDateTime': createdDateTime,
        'elapsedTime': elapsedTime?.inSeconds,
        'hikePoints': hikePoints,
        'hike': hike,
      };

  factory HikeHistory.fromJson(Map<String, dynamic> json) {
    return HikeHistory(
      createdDateTime: DateTime.parse(json['createdDateTime']),
      elapsedTime: Duration(
        hours: int.parse(RegExp(r'(\d+)H').firstMatch(json['elapsedTime'])?.group(1) ?? '0'),
        minutes: int.parse(RegExp(r'(\d+)M').firstMatch(json['elapsedTime'])?.group(1) ?? '0'),
        seconds: int.parse(RegExp(r'(\d+)S').firstMatch(json['elapsedTime'])?.group(1) ?? '0'),
      ),
      hikePoints: json['hikePoints'],
      hike: Hike.fromJsonHikeHistory(json['hike'])
    );
  }
}
