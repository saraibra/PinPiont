import 'dart:io';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';

class ImageEdit extends StatefulWidget {
  final File image;

  const ImageEdit({Key key, this.image}) : super(key: key);

  @override
  _ImageEditState createState() => _ImageEditState();
}

class _ImageEditState extends State<ImageEdit> {
  @override
  Widget build(BuildContext context) {
    File finalImage;
    Future uploadPic(BuildContext context) async {
      String fileName = basename(widget.image.path);
      StorageReference storageReference =
          FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask storageUploadTask =
          storageReference.putFile(widget.image);
      StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;
      setState(() {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Profile picture updated!'),
        ));
      });
    }

    Future<File> _cropImage() async {
      File cropped = await ImageCropper.cropImage(
        sourcePath: widget.image.path,
      );
      setState(() {
        finalImage = cropped;
      });
      return File(widget.image.path);
    }

    return Scaffold(
      body:
      
        Builder(
          builder: (BuildContext context) => Container(
            child: Center(
              child: Image.file(finalImage,
              filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      
    );
  }
}
