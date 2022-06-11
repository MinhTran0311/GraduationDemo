import 'package:boilerplate/data/repository.dart';
import 'package:boilerplate/models/image/image.dart';
import 'package:boilerplate/models/image/image_list.dart';
import 'package:boilerplate/models/post/post_list.dart';
import 'package:boilerplate/stores/error/error_store.dart';
import 'package:boilerplate/utils/dio/dio_error_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';

part 'post_store.g.dart';

class PostStore = _PostStore with _$PostStore;

abstract class _PostStore with Store {
  // repository instance
  late Repository _repository;

  // store for handling errors
  final ErrorStore errorStore = ErrorStore();

  // constructor:---------------------------------------------------------------
  _PostStore(Repository repository) : this._repository = repository;

  // store variables:-----------------------------------------------------------
  static ObservableFuture<ImgList?> emptyPostResponse =
      ObservableFuture.value(null);

  @observable
  ObservableFuture<ImgList?> fetchPostsFuture =
      ObservableFuture<ImgList?>(emptyPostResponse);

  static ObservableFuture<dynamic> emptyUploadResponse =
      ObservableFuture.value(null);

  @observable
  ObservableFuture<dynamic> fetchUploadFuture =
      ObservableFuture<dynamic>(emptyUploadResponse);

  @observable
  PostList? postList;

  @observable
  bool success = false;

  @computed
  bool get loading => fetchPostsFuture.status == FutureStatus.pending;

  @computed
  bool get uploading => fetchUploadFuture.status == FutureStatus.pending;

  // actions:-------------------------------------------------------------------
  @action
  Future getHistory() async {
    final future = _repository.getHistory();
    fetchPostsFuture = ObservableFuture(future);

    future.then((imgs) {
      imgList = imgs;
    });
    // .catchError((error) {
    //   errorStore.errorMessage = DioErrorUtil.handleError(error);
    // });
  }

  @observable
  ImgList? imgList;

  @observable
  Img? output;

  @observable
  String? processingTime;

  @action
  Future upload(XFile file) async {
    final future = _repository.upload(file);
    fetchUploadFuture = ObservableFuture(future);

    future.then((img) {
      processingTime = img["time"].toString();
      output = Img.fromMap(img);
    }).catchError((error) {
      errorStore.errorMessage = DioErrorUtil.handleError(error);
      print(error);
    });
  }
}
