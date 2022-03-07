import 'package:boilerplate/models/image/image.dart';

class ImgList {
  List<Img>? images;

  ImgList({
    this.images,
  }){
    this.images = images;
  }

  factory ImgList.fromJson(List<dynamic> json) {
    List<Img> posts = <Img>[];
    posts = json.map((post) => Img.fromMap(post)).toList();

    return ImgList(
      images: posts,
    );
  }
}
