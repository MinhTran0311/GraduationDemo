import 'dart:async';
import 'dart:convert';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
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
  late ThemeStore _themeStore;
  late LanguageStore _languageStore;
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
    _languageStore = Provider.of<LanguageStore>(context);
    _themeStore = Provider.of<ThemeStore>(context);
    _postStore = Provider.of<PostStore>(context);
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
      title: Center(
          child: Text("Aerial Image Detection", textAlign: TextAlign.center)),
    );
  }

  Widget _buildThemeButton() {
    return Observer(
      builder: (context) {
        return IconButton(
          onPressed: () {
            _themeStore.changeBrightnessToDark(!_themeStore.darkMode);
          },
          icon: Icon(
            _themeStore.darkMode ? Icons.brightness_5 : Icons.brightness_3,
          ),
        );
      },
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
        return _postStore.uploading
            ? CustomProgressIndicatorWidget()
            : Material(child: _buildContent());
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
                _image != null
                    ? Column(children: [
                        Text("Input Image"),
                        Container(
                          child: Image.file(File(_image!.path),
                              fit: BoxFit.contain),
                        ),
                      ])
                    : SizedBox.shrink(),
                SizedBox(height: 16),
                Observer(builder: (context) {
                  if (_postStore.output != null) {
                    return Column(children: [
                      Text("Output Image"),
                      Image.memory(base64Decode(_postStore.output!)),
                    ]);
                  } else
                    return Container(width: 0, height: 0);
                }),
                  SizedBox(height: 8),
                Text((selectedImage == ""
                    ? "Please select or capture an image"
                    : selectedImage!)),
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

  _buildButton() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      TextButton.icon(
        onPressed: () =>
            _showImageSourceActionSheet(Scaffold.of(context).context),
        icon: Icon(Icons.image_outlined, color: Colors.white),
        label: Text(
          "Upload",
          style: TextStyle(fontSize: 18, color: Colors.white),
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
          if (_image != null)
            _postStore.upload(_image!);
          else
            _showErrorMessage("Please select an aerial image");
        },
        icon: Icon(Icons.upload_file_outlined, color: Colors.white),
        label:
            Text("Submit", style: TextStyle(fontSize: 18, color: Colors.white)),
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
        )..show(context);
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
