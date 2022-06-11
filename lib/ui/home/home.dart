import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/models/image/image.dart';
import 'package:boilerplate/models/image/image_list.dart';
import 'package:boilerplate/models/object/object.dart';
import 'package:boilerplate/ui/photoview/photoView.dart';
import 'package:boilerplate/stores/post/post_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image/image.dart' as img;


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //stores:---------------------------------------------------------------------
  late PostStore _postStore;
  late ImagePicker _picker;
  XFile? _image;
  String? selectedImage = "";

  @override
  void initState() {
    super.initState();
    _picker = new ImagePicker();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // initializing stores
    _postStore = Provider.of<PostStore>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar("Aerial Object Detection"),
      backgroundColor: Colors.white70,
      body: SafeArea(child: _buildBody()),
    );
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget buildAppBar(String text) {
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
    return Stack(children: <Widget>[
      _buildMainContent(),
      Observer(
        builder: (context) {
          return _postStore.success
              ? Container()
              : _showErrorMessage(_postStore.errorStore.errorMessage);
        },
      ),
    ]);
  }

  Widget _buildMainContent() {
    return Observer(
      builder: (context) {
        return Material(child: _buildContent());
      },
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                SizedBox(height: 16),
                //Input image
                _image != null
                    ? _buildImage(
                        "Input Image",
                        Image.file(File(_image!.path), fit: BoxFit.contain),
                        false,
                        null)
                    : SizedBox.shrink(),
                SizedBox(height: 16),

                Observer(builder: (context) {
                  if (_postStore.uploading) {
                    return CircularProgressIndicator(
                        strokeWidth: 4.0, color: Colors.amber);
                  } else
                    return Container(width: 0, height: 0);
                }),

                //Output image
                Observer(builder: (context) {
                  if (_postStore.output != null &&
                      _postStore.output!.image != null) {
                    return Column(children: [
                      _buildImage(
                          "Output Image",
                          Image.memory(base64Decode(_postStore.output!.image!),
                              fit: BoxFit.contain),
                          true,
                          [_postStore.output!]),
                      Text(
                          "Processing time: " +
                              _postStore.processingTime! +
                              "s",
                          style: TextStyle(fontSize: 16)),
                      TextButton.icon(
                        onPressed: () {
                          showInfoBottomSheet(_postStore.output!);
                        },
                        icon: Icon(Icons.info_outline_rounded,
                            color: Colors.white),
                        label: Text(
                          "Show detail",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.amber),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0)),
                          ),
                        ),
                      ),
                    ]);
                  } else
                    return Container(width: 0, height: 0);
                }),
                Text(
                    (selectedImage == ""
                        ? "Please select or capture an image"
                        : ""),
                    style: TextStyle(fontSize: 16)),
              ]),
            ),
          ),
          SizedBox(height: 8),
          _buildButton(),
          SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _buildImage(String title, Widget img, bool isOutput, List<Img>? list) {
    return Column(children: [
      Text(title, style: TextStyle(fontSize: 16)),
      GestureDetector(
          onDoubleTap: () {
            if (isOutput) {
              Navigator.push(
                  Scaffold.of(context).context,
                  CupertinoPageRoute(
                      builder: (context) => PhotoViewScreen(
                          imageList: new ImgList(images: list), index: 0)));
            }
          },
          onLongPress: () async {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                  title: const Text('Save image'),
                  content: const Text('Do you want to save this image?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _createFileFromString(_postStore.output!.image!,
                            _postStore.output!.name!);
                        Navigator.pop(context, 'OK');
                      },
                      child: const Text('OK'),
                    ),
                  ]),
            );
          },
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 4.0), child: img)),
    ]);
  }

  _buildButton() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      TextButton.icon(
        onPressed: () {
          _showImageSourceActionSheet(Scaffold.of(context).context);
        },
        icon: Icon(Icons.image_outlined, color: Colors.white),
        label: Text(
          "Upload",
          style: TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.w700),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.amber),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          ),
        ),
      ),
      SizedBox(width: 36),
      TextButton.icon(
        onPressed: () async {
          if (_image != null) {
            _postStore.output = null;
            try {
              _postStore.upload(File(_image!.path));

              _postStore.getHistory();
            } catch (error) {
              _showErrorMessage("Please try again!");
            }
          } else
            _showErrorMessage("Please select or snap an image");
        },
        icon: Icon(Icons.upload_file_outlined, color: Colors.white),
        label: Text("Submit",
            style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w700)),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.amber),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          ),
        ),
      ),
    ]);
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

  _showSuccessMessage(String message) {
    Future.delayed(Duration(milliseconds: 0), () {
      if (message.isNotEmpty) {
        FlushbarHelper.createSuccess(
          message: message,
          title: "Success",
          duration: Duration(seconds: 3),
        )..show(Scaffold.of(context).context);
      }
    });

    return SizedBox.shrink();
  }

  Future<void> selectImageSource(ImageSource imgSrc) async {
    _image = await _picker.pickImage(source: imgSrc);
    if (_image!=null){
      final img.Image? capturedImage = img.decodeImage(await File(_image!.path).readAsBytes());
      final img.Image orientedImage = img.bakeOrientation(capturedImage!);
      await File(_image!.path).writeAsBytes(img.encodeJpg(orientedImage));
      selectedImage = null;
      _postStore.output = _image != null ? _postStore.output : null;
    }
    setState(() {});
  }

  void _showImageSourceActionSheet(BuildContext context) {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(actions: [
          CupertinoActionSheetAction(
            child: Text("Camera"),
            onPressed: () {
              Navigator.pop(context);
              selectImageSource(ImageSource.camera);
            },
          ),
          CupertinoActionSheetAction(
            child: Text("Gallery"),
            onPressed: () {
              Navigator.pop(context);
              selectImageSource(ImageSource.gallery);
            },
          )
        ]),
      );
    } else {
      showModalBottomSheet(
        barrierColor: Colors.black54,
        context: context,
        builder: (context) => Wrap(children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text("Camera"),
            onTap: () {
              Navigator.pop(context);
              selectImageSource(ImageSource.camera);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_album),
            title: Text("Gallery"),
            onTap: () {
              Navigator.pop(context);
              selectImageSource(ImageSource.gallery);
            },
          )
        ]),
      );
    }
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
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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

  Future<String> _createFileFromString(String base64str, String imgName) async {
    Uint8List bytes = base64.decode(base64str);
    String dir = (await getApplicationDocumentsDirectory()).path;
    String fullPath = '$dir/$imgName';
    File file = File(fullPath);
    await file.writeAsBytes(bytes);

    final result = await ImageGallerySaver.saveImage(bytes);
    _showSuccessMessage("Saved image to phone.");
    return file.path;
  }
}
