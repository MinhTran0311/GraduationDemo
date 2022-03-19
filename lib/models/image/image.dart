import 'package:boilerplate/models/object/object.dart';
import 'dart:convert';

class Img {
  String? created;
  String? name;
  String? image;
  List<ImageObject>? textLocation;

  Img({
    this.created,
    this.name,
    this.image,
    this.textLocation,
  }) {
    this.created = created;
    this.name = name;
    this.image = image;
    this.textLocation = textLocation;
  }

  factory Img.fromMap(Map<String, dynamic> json) {
    List<ImageObject> objects = <ImageObject>[];
    Map valueMap = jsonDecode(json["textLocation"]);

    objects = ((valueMap)[json["name"]] as List)
        .map((object) => ImageObject.fromMap(object))
        .toList();

    return Img(
      created: json["created"],
      name: json["name"],
      image: json["image"],
      textLocation: objects,
    );
  }
  Map<String, dynamic> toMap() => {
        "created": created,
        "name": name,
        "image": image,
        "textLocation": textLocation,
      };
}
