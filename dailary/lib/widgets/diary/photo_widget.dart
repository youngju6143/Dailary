import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoWidget extends StatefulWidget {
  final Function(XFile?) onImageSelected;
  final Function() onImageDeleted;
  final XFile? pickedImg;
  final String imgURL;

  const PhotoWidget({
    required this.onImageSelected,
    required this.onImageDeleted,
    required this.pickedImg,
    required this.imgURL,
  });

  @override
  _PhotoWidgetState createState() => _PhotoWidgetState();
}

class _PhotoWidgetState extends State<PhotoWidget> {
  final ImagePicker _picker = ImagePicker();

  Future<void> getImage(ImageSource source) async {
    final XFile? pickedImg = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );
    widget.onImageSelected(pickedImg);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘의 사진',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          getImage(ImageSource.gallery);
                        },
                        icon: const Icon(Icons.add_a_photo, size: 30, color: Colors.black),
                      ),
                      IconButton(
                        onPressed: widget.onImageDeleted,
                        icon: const Icon(Icons.delete, size: 30, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Container(
                  child: widget.pickedImg != null 
                    ? Image.file(File(widget.pickedImg!.path))
                    : widget.imgURL.isNotEmpty 
                        ? Image.network(widget.imgURL)
                        : Container(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
