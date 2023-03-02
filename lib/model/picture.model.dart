class Picture {
  int? id;
  String? base64;

  Picture({
    this.id,
    this.base64
  });

  Map<String, dynamic> toJson() => {
    'base64': base64,
    'id': id
  };

  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture(
        base64: json['base64'],
        id: json['id']
    );
  }
}