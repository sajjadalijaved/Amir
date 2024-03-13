import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../widgets/image_picker_dialog.dart';
// ignore_for_file: use_build_context_synchronously

// ignore_for_file: library_private_types_in_public_api

class ImageToTextNotesScreen extends StatefulWidget {
  const ImageToTextNotesScreen({super.key});

  @override
  _ImageToTextNotesScreenState createState() => _ImageToTextNotesScreenState();
}

class _ImageToTextNotesScreenState extends State<ImageToTextNotesScreen> {
  File? _image;
  final picker = ImagePicker();

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> readTextFromImage() async {
    final inputImage = InputImage.fromFile(_image!);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    String text = recognizedText.text;

    textRecognizer.close();

    // Process the extracted text as required (e.g., display in a dialog).
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Extracted Text'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(
                      "Recognized Text",
                      style: Theme.of(context).textTheme.titleLarge,
                    )),
                    CupertinoButton(
                        minSize: 0,
                        padding: EdgeInsets.zero,
                        child: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: text));
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Copied to Clipboard')));
                        })
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(text),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Image to Text'),
      ),
      body: Center(
        child: _image == null
            ? const Text('No image selected.')
            : Column(
                children: [
                  Image.file(
                    _image!,
                    height: MediaQuery.of(context).size.height * 0.6,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        readTextFromImage();
                      },
                      child: const Text("Get Text From Image"))
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => imagePickerAlert(onCameraPressed: () async {
                    getImageFromCamera();
                    Navigator.of(context).pop();
                  }, onGalleryPressed: () async {
                    getImageFromGallery();
                    Navigator.of(context).pop();
                  }));
        },
        tooltip: 'Select Image',
        child: const Icon(Icons.image),
      ),
    );
  }
}
