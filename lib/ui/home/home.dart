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
      backgroundColor: Colors.white70,
      body: SafeArea(child: _buildBody()),
    );
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(AppLocalizations.of(context).translate('home_tv_posts')),
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

  String? selectedImage = "";

  Widget _buildContent() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text((selectedImage == "" ? "Nothing to show" : selectedImage!)),
      TextButton.icon(
        onPressed: () => _showImageSourceActionSheet(context),
        icon: Icon(Icons.upload_file, color: Colors.white),
        label: Text(
          "upload",
        ),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.amber)),
      ),
      TextButton.icon(
        onPressed: () {
          if (_image != null)
            _postStore.upload(_image!);
          else
            _showErrorMessage("Please select an aerial image");
        },
        icon: Icon(Icons.upload_file, color: Colors.white),
        label: Text("submit"),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.amber)),
      ),
      Observer(builder: (context) {
        if (_postStore.output != null) {
          print("213212112312132");
          return Image.memory(base64Decode(_postStore.output!));
        } else
          return Container(width: 0, height: 0);
      }),
      _image != null
          ? Expanded(
              child: Container(
                child: Image.file(File(_image!.path), fit: BoxFit.contain),
              ),
            )
          : SizedBox.shrink()
    ]));
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
