# Flutter Landmark Classifier

This is a project that can recognize and search landmarks in each region (Asia, South America, North America, Europe, Oceania, Antarctica).
Complete working code for iOS emulators and Android physical devices/emulators is provided.Unfortunately, the performance of the tflite model results worse than the example provided in tfhub. To be used in real-world projects, you need to improve the performance of your model. I have used [onlinecsvtool](https://onlinecsvtools.com/delete-csv-columns) to delimit the labelmaps provided in tfhub and converted them to .txt format for easy parsing. 

## Instructions to follow for Andriod physical devices/emulators 👇

* `Step 1`: Go to command prompt and cd to the root directory of the project.

* `Step 2`: Execute the command **[install.bat](https://github.com/nakshatrasinghh/landmark-classifier-flutter/blob/main/install.bat)** on the terminal.

* `Step 3`: Run main.dart 


<p align="center">
<img height="530" src="https://user-images.githubusercontent.com/53419293/108623282-274f6b80-7464-11eb-861c-95928092f236.png?raw=true"></a>&nbsp;&nbsp;
<img height="530" src="https://user-images.githubusercontent.com/53419293/108623277-1ef73080-7464-11eb-9220-16bf1d48931b.png?raw=true"></a>&nbsp;&nbsp;
</p>

## TfHub Models 👇

* [Africa Landmark Model](https://tfhub.dev/google/on_device_vision/classifier/landmarks_classifier_africa_V1/1)

* [Asia Landmark Model](https://tfhub.dev/google/on_device_vision/classifier/landmarks_classifier_asia_V1/1)

* [Europe Landmark Model](https://tfhub.dev/google/on_device_vision/classifier/landmarks_classifier_europe_V1/1)

* [North America Landmark Model](https://tfhub.dev/google/on_device_vision/classifier/landmarks_classifier_north_america_V1/1)

* [Oceania Landmark Model](https://tfhub.dev/google/on_device_vision/classifier/landmarks_classifier_oceania_antarctica_V1/1)

* [South America Landmark Model](https://tfhub.dev/google/on_device_vision/classifier/landmarks_classifier_south_america_V1/1)

## Pubspec Packages 👇

* [Multi Image Picker](https://pub.dev/packages/multi_image_picker) ⤜ [Documentation](https://sh1d0w.github.io/multi_image_picker/#/)

* [Tflite Flutter](https://pub.dev/packages/tflite_flutter) ⤜ [Documentation](https://pub.dev/documentation/tflite_flutter/latest/)

* [Tflite Flutter Helper](https://pub.dev/packages/tflite_flutter_helper) ⤜ [Documentation](https://pub.dev/documentation/tflite_flutter_helper/latest/)

* [URL Launcher](https://pub.dev/packages/url_launcher) ⤜ [Documentation](https://pub.dev/documentation/url_launcher/latest/)

* [Image](https://pub.dev/packages/image) ⤜ [Documentation](https://github.com/brendan-duncan/image/wiki)


