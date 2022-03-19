import 'dart:async';

import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/data/network/dio_client.dart';
import 'package:boilerplate/data/network/rest_client.dart';
import 'package:boilerplate/models/image/image_list.dart';
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
      final res = await _dioClient.post(Endpoints.upload,
          options: Options(headers: {"Content-type": "multipart/form-data"}),
          data: data);
      return res;
    } catch (e) {
      throw e;
    }
  }

  Future<ImgList> getHistory() async {
    final res = await _dioClient.get(Endpoints.getHistory,
        options: Options(headers: {"Content-type": "multipart/form-data"}));
    return ImgList.fromJson(res["images"]);
    // try {
    //   final res = await _dioClient.get(Endpoints.getHistory,
    //       options: Options(headers: {"Content-type": "multipart/form-data"}));
    //   return ImgList.fromJson(res["images"]);
    // }
    // catch (e) {
    //   throw e;
    // }
  }
}
