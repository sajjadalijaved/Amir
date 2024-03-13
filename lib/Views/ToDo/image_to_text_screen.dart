


// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../CustomClasses/mlkittext_recognizer_class.dart';
import '../../CustomClasses/recognition_response_class.dart';
import '../../CustomClasses/tesseract_text_recognizer.dart';
import '../../CustomClasses/text_recongnizer.dart';
import '../../widgets/image_picker_dialog.dart';

class ImageToTextTasksScreen extends StatefulWidget {
  const ImageToTextTasksScreen({super.key});

  @override
  State<ImageToTextTasksScreen> createState() => _ImageToTextTasksScreenState();
}

class _ImageToTextTasksScreenState extends State<ImageToTextTasksScreen> {
  late ImagePicker picker;
  late ITextRecongnizer recongnizer;
  RecognitionResponse? response;

  @override
  void initState() {
    super.initState();
    picker = ImagePicker();

    // recongnizer = MLKitTextRecognizer();
    recongnizer = TesseractTextRecognizer();
  }

  @override
  void dispose() {
    if (recongnizer is MLKitTextRecognizer) {
      (recongnizer as MLKitTextRecognizer).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text Recongition"),
      ),
      body: response == null
          ? const Center(
              child: Text("Pick image to continue"),
            )
          : ListView(
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).width,
                  width: MediaQuery.sizeOf(context).width,
                  child: Image.file(File(response!.imgPath)),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                Clipboard.setData(ClipboardData(
                                    text: response!.recognizedText));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Copied to Clipboard')));
                              })
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(response!.recognizedText),
                    ],
                  ),
                )
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => imagePickerAlert(onCameraPressed: () async {
                    final imagePath = await obtainImage(ImageSource.camera);
                    if (imagePath == null) return;
                    Navigator.of(context).pop();
                    processImage(imagePath);
                  }, onGalleryPressed: () async {
                    final imagePath = await obtainImage(ImageSource.gallery);
                    if (imagePath == null) return;
                    Navigator.of(context).pop();
                    processImage(imagePath);
                  }));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // functions
  // get image function
  Future<String?> obtainImage(ImageSource source) async {
    final file = await picker.pickImage(source: source);
    return file?.path;
  }

  // process image function
  void processImage(String imgPath) async {
    final recognizedText = await recongnizer.processImage(imgPath);
    setState(() {
      response =
          RecognitionResponse(imgPath: imgPath, recognizedText: recognizedText);
    });
  }
}
