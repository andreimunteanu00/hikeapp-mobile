class HikeHistory {
  DateTime? createdDateTime;
  Duration? elapsedTime;
  String? hikeTitle;
  double? hikePoints;

  HikeHistory({
    this.createdDateTime,
    this.elapsedTime,
    this.hikeTitle,
    this.hikePoints,
  });

  Map<String, dynamic> toJson() => {
        'createdDateTime': createdDateTime,
        'elapsedTime': elapsedTime?.inSeconds,
        'hikeTitle': hikeTitle,
        'hikePoints': hikePoints,
      };

  factory HikeHistory.fromJson(Map<String, dynamic> json) {
    return HikeHistory(
      createdDateTime: DateTime.parse(json['createdDateTime']),
      hikeTitle: json['hikeTitle'],
      elapsedTime: Duration(
          seconds: int.parse(json['elapsedTime']
              .substring(2, json['elapsedTime'].length - 1))),
      hikePoints: json['hikePoints'],
    );
  }
}
