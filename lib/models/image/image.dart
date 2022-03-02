class Img {
  String? created;
  String? name;
  String? image;

  Img({
    this.created,
    this.name,
    this.image,
  });

  factory Img.fromMap(Map<String, dynamic> json) => Img(
        created: json["created"],
        name: json["name"],
        image: json["image"],
      );

  Map<String, dynamic> toMap() => {
        "created": created,
        "name": name,
        "image": image,
      };
}
