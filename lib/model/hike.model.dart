class Hike {
  String? title;
  String? description;
  double? allRatings;
  int? numberRatings;

  Hike({
    this.title,
    this.description,
    this.allRatings,
    this.numberRatings
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'allRatings': allRatings,
    'numberRatings': numberRatings
  };

  factory Hike.fromJson(Map<String, dynamic> json) {
    return Hike(
        title: json['title'],
        description: json['description'],
        allRatings: json['allRatings'],
        numberRatings: json['numberRatings']
    );
  }
}