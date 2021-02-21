import 'dart:math';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart' as img;

class ClassificationService {
  // Creating useful variables and initializing the tflite interpreter
  Interpreter interpreter;
  InterpreterOptions _interpreterOptions;
  TfLiteType outputType = TfLiteType.uint8;
  TensorBuffer outputBuffer;

  List<int> inputShape;
  List<int> outputShape;
  List<String> labels;

  // Takes 2 parameters, modelpath and labelpath
  // Refer pages/classification_page.dart line 28
  ClassificationService({String modelPath, String labelPath}) {
    _interpreterOptions = InterpreterOptions();

    // Sets the number of CPU threads to use
    // Setting thread to 2
    _interpreterOptions.threads = 2;

    // Calls the 2 asynchronous functions made below 👇
    loadModel(modelPath);
    loadLabel(labelPath);
  }

  // Closes interpreter to save memory when not needed
  dispose() {
    interpreter.close();
  }

  // Asynchronous function to load model and check if models are in place
  Future<void> loadModel(String modelPath) async {
    try {
      // load model from modelPath passed in function call above ☝️
      interpreter = await Interpreter.fromAsset(modelPath, options: _interpreterOptions);

      // gets all input shape, output shape, and output type if model is loaded successfully
      inputShape = interpreter.getInputTensor(0).shape;
      outputShape = interpreter.getOutputTensor(0).shape;
      outputType = interpreter.getOutputTensor(0).type;

      // Creating an output buffer for predictions
      outputBuffer = TensorBuffer.createFixedSize(outputShape, outputType);

      print('Load Model - $inputShape / $outputShape / $outputType');
      // If model doesn't load catch and print the error in string format
    } catch(err) {
      print('Error : ${err.toString()}');
    }
  }

  // Asynchronous function to load the labels and check if labels are in place
  Future<void> loadLabel(String labelPath) async {
    if (labelPath != null) {
      // load labels
      labels = await FileUtil.loadLabels("assets/$labelPath");
      if (labels.length > 0) {
        print('Labels loaded successfully');
      } else {
        print('Unable to load labels');
      }
    }
  }

  // Line 195 => pages/classification_page.dart
  // Take imageData as parameter
  List<dynamic> runClassification({Uint8List imageData}) {
    // Decodes the image using the image.dart package which was imported as img
    img.Image _baseImage = img.decodeImage(imageData);
    // Stores decoded image as input image for the model, converts to a tensorImage
    TensorImage _inputImage = TensorImage.fromImage(_baseImage);
    // Calls imageResize function on line 115 of this page, take a tensorImage as parameter
    _inputImage = imageResize(_inputImage);

    // Runs the interpreter after resizing and converting to buffer
    interpreter.run(_inputImage.buffer, outputBuffer.getBuffer());

    Map<String, double> map = Map<String, double>();
    // Converts output buffer to a double list
    var outputResult = outputBuffer.getDoubleList();
    var length = min(outputResult.length, labels.length);

    // Mapping buffer with labels
    for (var i = 0; i < length; i++) {
      var name = labels[i];

      if (!map.containsKey(name)) {
        map[name] = outputResult[i];
      } else {
        if (map[name] < outputResult[i]) {
          map[name] = outputResult[i];
        }
      }
    }

    // Sorting the keys in descending order wrt to confidence score
    var sortedKeys = map.keys.toList(growable:false)
      ..sort((k1, k2) => map[k2].compareTo(map[k1]));

    List<dynamic> result = [];

    // Displaying top 7 predicted results only
    for (var i = 0; i < 7; i++) {
      result.add({
        'label': sortedKeys[i],
        'value': map[sortedKeys[i]],
      });
    }
    return result;
  }

  // Function called on line 79 to resize the input image passed
  TensorImage imageResize(TensorImage inputImage) {
    int cropSize = min(inputImage.height, inputImage.width);
    //read tflite_flutter_helper: ^0.1.2 documentation
    // https://pub.dev/documentation/tflite_flutter_helper/latest/
    return ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(ResizeOp(inputShape[1], inputShape[2], ResizeMethod.NEAREST_NEIGHBOUR))
        //.add(NormalizeOp(127.5, 127.5))
        .build()
        .process(inputImage);
  }
}