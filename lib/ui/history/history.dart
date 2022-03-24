import 'dart:async';
import 'dart:convert';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/models/image/image.dart';
import 'package:boilerplate/models/object/object.dart';
import 'package:boilerplate/stores/post/post_store.dart';
import 'package:boilerplate/ui/photoview/photoView.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/widgets/progress_indicator_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late PostStore _postStore;
  late RefreshController _refreshController;
  late bool isRefresh;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
    isRefresh = false;
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
      appBar: _buildAppBar("History"),
      backgroundColor: Colors.white70,
      body: SafeArea(child: _buildBody()),
    );
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar(String text) {
    return AppBar(
      backgroundColor: Colors.amber,
      title: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        _buildMainContent(),
        Observer(
          builder: (context) {
            return _postStore.success
                ? Container()
                : _showErrorMessage(_postStore.errorStore.errorMessage);
          },
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Observer(
      builder: (context) {
        return _postStore.loading && !isRefresh
            ? CustomProgressIndicatorWidget()
            : Material(child: _buildListView());
      },
    );
  }

  Widget _buildListView() {
    return Padding(
      padding: EdgeInsets.only(top: 12.0, bottom: 16.0, right: 8.0, left: 8.0),
      child: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        header: WaterDropHeader(
            refresh: SizedBox(
                width: 25.0,
                height: 25.0,
                child: Icon(Icons.flight_takeoff_outlined,
                    color: Colors.amber, size: 20)),
            waterDropColor: Colors.amber),
        physics: BouncingScrollPhysics(),
        onRefresh: () async {
          isRefresh = true;
          try {
            _postStore.getHistory();
          } catch (error) {
            _showErrorMessage("Failed to load history");
          }
          await Future.delayed(Duration(milliseconds: 5000));
          if (mounted) setState(() {});
          _refreshController.refreshCompleted();
        },
        child: ((_postStore.imgList != null) &&
                _postStore.imgList!.images != null &&
                _postStore.imgList!.images!.length > 0)
            ? ListView.builder(
                itemCount: _postStore.imgList!.images!.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildCard(_postStore.imgList!.images![index], index);
                })
            : Center(
                child: Text("No images"),
              ),
      ),
    );
  }

  Widget _buildCard(Img img, int index) {
    return InkWell(
      onTap: () => showInfoBottomSheet(img),
      onDoubleTap: () => Navigator.push(
          Scaffold.of(context).context,
          CupertinoPageRoute(
              builder: (context) => PhotoViewScreen(
                  imageList: _postStore.imgList!, index: index))),
      child: Container(
        height: 120,
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 4.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
              child:
                  Image.memory(base64Decode(img.image!), fit: BoxFit.fitHeight),
              width: MediaQuery.of(context).size.width * 0.4),
          SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text(img.name!.substring(img.name!.indexOf("-") + 1),
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                Text(
                  img.created!.split('.').first,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ]))
        ]),
      ),
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
        )..show(Scaffold.of(context).context);
      }
    });

    return SizedBox.shrink();
  }

  void showInfoBottomSheet(Img img) async {
    await showModalBottomSheet(
        context: Scaffold.of(context).context,
        enableDrag: true,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        )),
        builder: (BuildContext context) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text("Detail information",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: [
                    _buildRowInfo("Name",
                        img.name!.substring(img.name!.indexOf("-") + 1)),
                    _buildRowInfo("Created at", img.created!.split('.').first),
                    _buildRowInfo("Number of object",
                        img.textLocation!.length.toString()),
                    _buildTable(img.textLocation!)
                  ]),
                ),
              )
            ]),
          );
        });
  }

  Widget _buildRowInfo(String title, String info) {
    TextStyle style = TextStyle(fontSize: 16, color: Colors.black);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Row(children: [
        Expanded(flex: 1, child: Text(title, style: style)),
        SizedBox(width: 32),
        Expanded(flex: 2, child: Text(info, style: style)),
      ]),
    );
  }

  Widget _buildTable(List<ImageObject> objects) {
    TextStyle style =
        TextStyle(color: Colors.black, fontWeight: FontWeight.w700);

    List<TableRow> list = [];
    list.add(TableRow(children: [
      Text(
        "Index",
        textAlign: TextAlign.center,
        style: style,
      ),
      Text(
        "Object",
        textAlign: TextAlign.center,
        style: style,
      ),
      Text(
        "Annotation",
        textAlign: TextAlign.center,
        style: style,
      ),
      Text(
        "Score",
        textAlign: TextAlign.center,
        style: style,
      ),
    ]));

    for (int i = 0; i < objects.length; i++) {
      list.add(TableRow(children: [
        Text((i + 1).toString(), textAlign: TextAlign.center),
        Text(objects[i].name!, textAlign: TextAlign.center),
        Text(
            "(" +
                objects[i].x1.toString() +
                ", " +
                objects[i].y1.toString() +
                ", " +
                objects[i].x2.toString() +
                ", " +
                objects[i].y2.toString() +
                ")" +
                (objects[i].text == null ? "" : "\n" + objects[i].text!),
            textAlign: TextAlign.center),
        Text(objects[i].score.toString(), textAlign: TextAlign.center)
      ]));
    }

    return Table(
      border: TableBorder.all(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(5),
        3: FlexColumnWidth(2),
      },
      children: list,
    );
  }
}
