import 'dart:typed_data';
import 'package:multi_image_picker/multi_image_picker.dart';

class ImageService {
  // A fixed-length list of 8-bit unsigned integers from typed_data dart package
  // Asynchronous function loadImage()
  Future<Uint8List> loadImage() async {
    // Using multi image picker to pick images from gallery
    // Or take picture from camera and select from recent folder in gallery
    var resultList = await MultiImagePicker.pickImages(
      // Allow one image at a time
      maxImages: 1,
      // Enable camera to take pictures and then select on spot
      enableCamera: true,
    );

    // Return nothing on empty list
    if (resultList.length == 0){
      return null;
    }
    // Else read the image as Bytes data.
    // Read the entire file contents as a list of bytes. Returns a Future<Uint8List>
    // that completes with the list of bytes that is the contents of the file.
    // asynchronous function call
    else {
      return readAsBytes(resultList);
    }
  }

  Future<Uint8List> readAsBytes(List<Asset> assets) async {
    // Takes a single element of this stream
    var asset = assets.single;
    // Gets byte data from resultList
    var byteData = await asset.getByteData();
    // Converts to a Uint8 buffer
    return byteData.buffer.asUint8List();
  }
}