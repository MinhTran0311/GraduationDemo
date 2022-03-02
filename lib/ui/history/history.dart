import 'dart:async';
import 'dart:convert';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/models/image/image.dart';
import 'package:boilerplate/stores/post/post_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/widgets/progress_indicator_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late PostStore _postStore;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // initializing stores
    _postStore = Provider.of<PostStore>(context);

    if (!_postStore.loading) {
      _postStore.getHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.white70,
      body: SafeArea(child: _buildBody()),
    );
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.amber,
      title: Center(child: Text("History", textAlign: TextAlign.center)),
    );
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Stack(
      children: <Widget>[_buildMainContent()],
    );
  }

  Widget _buildMainContent() {
    return Observer(
      builder: (context) {
        return _postStore.loading
            ? CustomProgressIndicatorWidget()
            : Material(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: _buildListView(),
            ));
      },
    );
  }

  Widget _buildListView() {
    return _postStore.imgList != null
        ? ListView.builder(
            itemCount: _postStore.imgList!.images!.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildCard(_postStore.imgList!.images![index]);
            })
        : Center(
            child: Text("No images"),
          );
  }

  Widget _buildCard(Img img) {
    return Container(
      height: 120,
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 4.0),
        // decoration: BoxDecoration(
        //     border: Border.all(color: Colors.balck),
        //     borderRadius: BorderRadius.all(Radius.circular(16.0))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
            child:
                Image.memory(base64Decode(img.image!), fit: BoxFit.fitHeight),
            width: MediaQuery.of(context).size.width * 0.4),
        SizedBox(width: 16),
        Expanded(child: Text(img.created!.split('.').first))
      ]),
    );
  }

  _showDialog<T>({required BuildContext context, required Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T? value) {
      // The value passed to Navigator.pop() or null.
    });
  }

  _showErrorMessage(String message) {
    Future.delayed(Duration(milliseconds: 0), () {
      if (message.isNotEmpty) {
        FlushbarHelper.createError(
          message: message,
          title: AppLocalizations.of(context).translate('home_tv_error'),
          duration: Duration(seconds: 3),
        )..show(context);
      }
    });

    return SizedBox.shrink();
  }
}
