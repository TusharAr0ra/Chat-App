import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickImage});

  final void Function(File pickedImage) onPickImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile; //it's null initially

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    ); //image picker object
    //ab image uthane ke baad set state kr denge bs or kya.
    if (pickedImage == null) {
      return;
    }
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
    widget.onPickImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50.0,
          backgroundImage: const AssetImage('assets/images/image.png'),
          backgroundColor: Colors.grey,
          foregroundImage:
              _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
        ),
        Positioned(
          bottom: 0,
          right: -10,
          child: TextButton(
            style: ButtonStyle(
              iconSize: MaterialStateProperty.resolveWith<double>(
                (states) {
                  return 30;
                },
              ),
            ),
            onPressed: _pickImage,
            child: const Icon(
              Icons.add_a_photo,
              color: Colors.deepPurpleAccent,
            ),
          ),
        ),
      ],
    );
  }
}
