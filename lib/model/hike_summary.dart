class HikeSummary {
  String? hikeTitle;
  Duration? elapsedTime;
  double? temperatureAverage;

  HikeSummary({this.hikeTitle, this.elapsedTime, this.temperatureAverage});

  Map<String, dynamic> toJson() => {
        'hikeTitle': hikeTitle,
        'elapsedTime': elapsedTime?.inSeconds,
        'temperatureAverage': temperatureAverage,
      };

  factory HikeSummary.fromJson(Map<String, dynamic> json) {
    return HikeSummary(
        hikeTitle: json['hikeTitle'],
        elapsedTime: json['elapsedTime'],
        temperatureAverage: json['temperatureAverage']);
  }
}
