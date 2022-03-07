import 'dart:async';

import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/data/network/dio_client.dart';
import 'package:boilerplate/data/network/rest_client.dart';
import 'package:boilerplate/models/image/image_list.dart';
import 'package:boilerplate/models/post/post_list.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class PostApi {
  // dio instance
  final DioClient _dioClient;

  // rest-client instance
  final RestClient _restClient;

  // injecting dio instance
  PostApi(this._dioClient, this._restClient);

  Future<dynamic> upload(XFile file) async {
    try {
      FormData data = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: file.name,
        ),
      });
      final res = await _dioClient.post("http://192.168.20.166:5000/upload",
          options: Options(headers: {"Content-type": "multipart/form-data"}),
          data: data);
      return res;
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<ImgList> getHistory() async {
    try {
      final res = await _dioClient.get("http://192.168.20.166:5000/history",
          options: Options(headers: {"Content-type": "multipart/form-data"}));
      return ImgList.fromJson(res["images"]);
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }
}
