import 'dart:async';
import 'dart:convert';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/models/image/image_list.dart';
import 'package:boilerplate/ui/photoview/photoView.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:boilerplate/stores/language/language_store.dart';
import 'package:boilerplate/stores/post/post_store.dart';
import 'package:boilerplate/stores/theme/theme_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/widgets/progress_indicator_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_dialog/material_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

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
      appBar: buildAppBar("Aerial Image Detection"),
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
                    return Column(
                      children: [
                        Text(
                            "Processing time: " +
                                _postStore.processingTime! +
                                "s",
                            style: TextStyle(fontSize: 16)),
                        _buildImage(
                            "Output Image",
                            Image.memory(
                              base64Decode(_postStore.output!.image!),
                              fit: BoxFit.contain,
                            ),
                            true),
                      ],
                    );
                  } else
                    return Container(width: 0, height: 0);
                }),
                SizedBox(height: 16),
                //Input image
                _image != null
                    ? _buildImage(
                        "Input Image",
                        Image.file(File(_image!.path), fit: BoxFit.contain),
                        false)
                    : SizedBox.shrink(),
                SizedBox(height: 8),
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

  Widget _buildImage(String title, Widget img, bool isOutput) {
    return Column(children: [
      Text(title, style: TextStyle(fontSize: 16)),
      GestureDetector(
          onLongPress: () {
            if (isOutput)
              Navigator.push(
                  Scaffold.of(context).context,
                  CupertinoPageRoute(
                      builder: (context) => PhotoViewScreen(
                          imageList: new ImgList(images: [_postStore.output!]),
                          index: 0)));
          },
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 4.0), child: img)),
    ]);
  }

  _buildButton() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      TextButton.icon(
        onPressed: () =>
            _showImageSourceActionSheet(Scaffold.of(context).context),
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
        onPressed: () {
          if (_image != null) {
            _postStore.output = null;
            try {
              _postStore.upload(_image!);
              _postStore.getHistory();

            } catch (error) {
              _showErrorMessage("Please try again!");
            }
          } else
            _showErrorMessage("Please select an aerial image");
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

  Future<void> selectImageSource(ImageSource imgSrc) async {
    _image = await _picker.pickImage(source: imgSrc);
    selectedImage = _image != null ? _image!.name : "";
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
}
