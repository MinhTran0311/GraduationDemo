class ImageObject {
  String? name;
  int? x1;
  int? y1;
  int? x2;
  int? y2;
  double? score;
  String? text;

  ImageObject({
    this.name,
    this.x1,
    this.y1,
    this.x2,
    this.y2,
    this.score,
    this.text,
  }) {
    this.name = name;
    this.x1 = x1;
    this.x2 = x2;
    this.y1 = y1;
    this.y2 = y2;
    this.score = score;
    this.text = text;
  }

  factory ImageObject.fromMap(List<dynamic> json) => ImageObject(
    name: json[0],
    x1: json[1],
    y1: json[2],
    x2: json[3],
    y2: json[4],
    score: json[5],
    text: json.last is String ? json.last : null,
  );
}
