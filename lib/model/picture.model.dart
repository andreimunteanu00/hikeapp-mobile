class Picture {
  String? base64;

  Picture({
    this.base64
  });

  Map<String, dynamic> toJson() => {
    'base64': base64,
  };

  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture(
        base64: json['base64'],
    );
  }
}