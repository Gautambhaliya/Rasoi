import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerdemo extends StatefulWidget {
  const ImagePickerdemo({super.key});

  @override
  State<ImagePickerdemo> createState() => _ImagePickerdemoState();
}

class _ImagePickerdemoState extends State<ImagePickerdemo> {
  File? image;

  Future<void> _captureImageforCamara() async {
    final pickFile = await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      image = File(pickFile!.path);
    });
  }

  Future<void> _pickImageGallery() async {
    final pickedfile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      image = File(pickedfile!.path);
    });
  }

  // Future<XFile> _comressImage(File image) async {
  //   final compressImage = await FlutterImageCompress.compressAndGetFile(
  //       image.absolute.path, '${image.path}_compress.jpg');
  //   return compressImage!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Picker Example"),
      ),
      body: Center(
        child: image == null ? Text("No Image Selected") : Image.file(image!),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: _pickImageGallery,
            child: const Icon(Icons.photo_library),
          ),
          SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            onPressed: _captureImageforCamara,
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}
