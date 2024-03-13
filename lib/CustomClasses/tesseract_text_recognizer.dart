import 'dart:developer';
import 'package:flutter_tesseract_ocr/android_ios.dart';

import 'text_recongnizer.dart';


class TesseractTextRecognizer extends ITextRecongnizer {
  @override
  Future<String> processImage(String imgPath) async {
    final res = await FlutterTesseractOcr.extractText(imgPath, args: {
      "psm": "4",
      "preserve_interword_spaces": "1",
    });
    log("----- Res");
    log(res);
    return res;
  }
}
