// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:note_app/JsonModels/task_model.dart';
import 'package:note_app/SQLite/task_sqlite.dart';
import 'package:note_app/widgets/custom_button.dart';
import 'package:speech_to_text/speech_to_text.dart';


class SpeechToTextToDoScreen extends StatefulWidget {
  const SpeechToTextToDoScreen({super.key});

  @override
  State<SpeechToTextToDoScreen> createState() => _SpeechToTextToDoScreenState();
}

class _SpeechToTextToDoScreenState extends State<SpeechToTextToDoScreen> {
  late SpeechToText _speechToText;
  late DataBaseHelperTasks helper;

  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;

  @override
  void initState() {
    super.initState();
    _speechToText = SpeechToText();
    helper = DataBaseHelperTasks();
    initSpeech();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _confidenceLevel = 0;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
      _confidenceLevel = result.confidence;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Speech To Text',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
         leading: InkWell(
                onTap: () {
                  Navigator.of(context).pop(true);
                },
                child: const Icon(Icons.arrow_back)),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                _speechToText.isListening
                    ? "listening..."
                    : _speechEnabled
                        ? "Tap the microphone to start listening..."
                        : "Speech not available",
                style: const TextStyle(fontSize: 20.0),
              ),
            ),
            Container(
              height: 400,
              width: double.infinity,
              margin: const EdgeInsets.only(left: 20, right: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xff734a34), width: 3)),
              child: Text(
                _wordsSpoken,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),

            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: CustomButton(
                  title: "Save Task",
                  onTap: () async {
                    if (_wordsSpoken != "") {
                      String title = _wordsSpoken;
                      helper
                          .createtask(TaskModel(
                              taskTitle: title,
                              createdAt: DateTime.now().toIso8601String()))
                          .whenComplete(() {
                        Navigator.of(context).pop(true);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Task Add Successfully!")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Please first speech than save")));
                    }
                  }),
            )
            // if (_speechToText.isNotListening && _confidenceLevel > 0)
            //   Padding(
            //     padding: const EdgeInsets.only(
            //       bottom: 100,
            //     ),
            //     child: Text(
            //       "Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%",
            //       style: const TextStyle(
            //         fontSize: 30,
            //         fontWeight: FontWeight.w200,
            //       ),
            //     ),
            //   )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        isExtended: true,
        onPressed: _speechToText.isListening ? _stopListening : _startListening,
        tooltip: 'Listen',
        backgroundColor: const Color(0xff734a34),
        child: Icon(
          _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}
