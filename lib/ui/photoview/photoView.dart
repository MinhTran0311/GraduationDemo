import 'dart:convert';

import 'package:boilerplate/models/image/image.dart';
import 'package:boilerplate/models/image/image_list.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewScreen extends StatefulWidget {
  final ImgList imageList;
  final int index;

  PhotoViewScreen({required this.imageList, required this.index});

  @override
  _PhotoViewScreenState createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<PhotoViewScreen> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int firstPage = widget.index;
    PageController _pageController = PageController(initialPage: firstPage);
    return Material(
      child: Stack(children: [
        Container(
            child: PhotoViewGallery.builder(
              //scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: MemoryImage(
                      base64Decode(widget.imageList.images![index].image!)),
                  initialScale: PhotoViewComputedScale.contained * 0.9,
                  minScale: PhotoViewComputedScale.contained * 0.9,
                  maxScale: PhotoViewComputedScale.covered * 2.5,
                  heroAttributes: PhotoViewHeroAttributes(
                      tag: widget.imageList.images![index].created!),
                );
              },
              itemCount: widget.imageList.images!.length,
              loadingBuilder: (context, event) => Center(
                child: Container(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    value: event == null ? 0 : event.cumulativeBytesLoaded / 2,
                  ),
                ),
              ),
              backgroundDecoration: BoxDecoration(color: Colors.black),
              pageController: _pageController,
            )),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop()),
          ),
        ),
      ]),
    );
  }
}
