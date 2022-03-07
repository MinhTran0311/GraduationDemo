// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$PostStore on _PostStore, Store {
  Computed<bool>? _$loadingComputed;

  @override
  bool get loading => (_$loadingComputed ??=
          Computed<bool>(() => super.loading, name: '_PostStore.loading'))
      .value;
  Computed<bool>? _$uploadingComputed;

  @override
  bool get uploading => (_$uploadingComputed ??=
          Computed<bool>(() => super.uploading, name: '_PostStore.uploading'))
      .value;

  final _$fetchPostsFutureAtom = Atom(name: '_PostStore.fetchPostsFuture');

  @override
  ObservableFuture<ImgList?> get fetchPostsFuture {
    _$fetchPostsFutureAtom.reportRead();
    return super.fetchPostsFuture;
  }

  @override
  set fetchPostsFuture(ObservableFuture<ImgList?> value) {
    _$fetchPostsFutureAtom.reportWrite(value, super.fetchPostsFuture, () {
      super.fetchPostsFuture = value;
    });
  }

  final _$fetchUploadFutureAtom = Atom(name: '_PostStore.fetchUploadFuture');

  @override
  ObservableFuture<dynamic> get fetchUploadFuture {
    _$fetchUploadFutureAtom.reportRead();
    return super.fetchUploadFuture;
  }

  @override
  set fetchUploadFuture(ObservableFuture<dynamic> value) {
    _$fetchUploadFutureAtom.reportWrite(value, super.fetchUploadFuture, () {
      super.fetchUploadFuture = value;
    });
  }

  final _$postListAtom = Atom(name: '_PostStore.postList');

  @override
  PostList? get postList {
    _$postListAtom.reportRead();
    return super.postList;
  }

  @override
  set postList(PostList? value) {
    _$postListAtom.reportWrite(value, super.postList, () {
      super.postList = value;
    });
  }

  final _$successAtom = Atom(name: '_PostStore.success');

  @override
  bool get success {
    _$successAtom.reportRead();
    return super.success;
  }

  @override
  set success(bool value) {
    _$successAtom.reportWrite(value, super.success, () {
      super.success = value;
    });
  }

  final _$imgListAtom = Atom(name: '_PostStore.imgList');

  @override
  ImgList? get imgList {
    _$imgListAtom.reportRead();
    return super.imgList;
  }

  @override
  set imgList(ImgList? value) {
    _$imgListAtom.reportWrite(value, super.imgList, () {
      super.imgList = value;
    });
  }

  final _$outputAtom = Atom(name: '_PostStore.output');

  @override
  Img? get output {
    _$outputAtom.reportRead();
    return super.output;
  }

  @override
  set output(Img? value) {
    _$outputAtom.reportWrite(value, super.output, () {
      super.output = value;
    });
  }

  final _$processingTimeAtom = Atom(name: '_PostStore.processingTime');

  @override
  String? get processingTime {
    _$processingTimeAtom.reportRead();
    return super.processingTime;
  }

  @override
  set processingTime(String? value) {
    _$processingTimeAtom.reportWrite(value, super.processingTime, () {
      super.processingTime = value;
    });
  }

  final _$getHistoryAsyncAction = AsyncAction('_PostStore.getHistory');

  @override
  Future<dynamic> getHistory() {
    return _$getHistoryAsyncAction.run(() => super.getHistory());
  }

  final _$uploadAsyncAction = AsyncAction('_PostStore.upload');

  @override
  Future<dynamic> upload(XFile file) {
    return _$uploadAsyncAction.run(() => super.upload(file));
  }

  @override
  String toString() {
    return '''
fetchPostsFuture: ${fetchPostsFuture},
fetchUploadFuture: ${fetchUploadFuture},
postList: ${postList},
success: ${success},
imgList: ${imgList},
output: ${output},
processingTime: ${processingTime},
loading: ${loading},
uploading: ${uploading}
    ''';
  }
}
