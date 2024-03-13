import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:note_app/SQLite/task_sqlite.dart';
import 'package:note_app/widgets/custom_button.dart';

import '../../JsonModels/task_model.dart';
import '../../widgets/image_picker_dialog.dart';
// ignore_for_file: use_build_context_synchronously

// ignore_for_file: library_private_types_in_public_api

class ImageToTextTasksScreen extends StatefulWidget {
  const ImageToTextTasksScreen({super.key});

  @override
  _ImageToTextTasksScreenState createState() => _ImageToTextTasksScreenState();
}

class _ImageToTextTasksScreenState extends State<ImageToTextTasksScreen> {
  File? _image;
  String text = '';
  late DataBaseHelperTasks helper;
  bool value = false;
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
    setState(() {
      text = recognizedText.text;
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          value = true;
        });
      });
    });

    textRecognizer.close();
  }

  @override
  void initState() {
    super.initState();
    helper = DataBaseHelperTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: CupertinoButton(
                minSize: 0,
                padding: EdgeInsets.zero,
                child: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to Clipboard')));
                }),
          )
        ],
        title: const Text('Image to Text'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: _image == null
              ? const Center(child: Text('No image selected.'))
              : Column(
                  children: [
                    Image.file(
                      _image!,
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.6,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    text == ''
                        ? const SizedBox(
                            height: 5,
                          )
                        : value == false
                            ? const CircularProgressIndicator()
                            : Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                padding: const EdgeInsets.all(20),
                                margin:
                                    const EdgeInsets.only(left: 20, right: 20),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: Colors.black, width: 2)),
                                child: ListView(children: [Text(text)])),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20, left: 20),
                      child: CustomButton(
                        title: "Get Text From Image",
                        onTap: () {
                          readTextFromImage();
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20, left: 20),
                      child: CustomButton(
                        title: "Save Task",
                        onTap: () {
                          if (text != "") {
                            String title = text;

                            helper
                                .createtask(TaskModel(
                                    taskTitle: title,
                                    createdAt:
                                        DateTime.now().toIso8601String()))
                                .whenComplete(() {
                              Navigator.of(context).pop(true);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Note Add Successfully!")));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Please first speech than save")));
                          }
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff734a34),
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
        child: const Icon(
          Icons.image,
          color: Colors.white,
        ),
      ),
    );
  }
}
