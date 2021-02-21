import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:landmark_classifier/models/landmark.dart';
import 'package:landmark_classifier/services/classification.dart';
import 'package:landmark_classifier/services/image.dart';
import 'package:url_launcher/url_launcher.dart';

class ClassificationPage extends StatefulWidget {
  // when the state is updated, everything in the build method will be initialized again.
  // This includes all the variables with final

  // Landmark picked up from models/landmark.dart
  final Landmark landmark;
  // Constructor for landmark, made using bulb 😆
  const ClassificationPage({Key key, this.landmark}) : super(key: key);

  @override
  _ClassificationPageState createState() => _ClassificationPageState();
}

class _ClassificationPageState extends State<ClassificationPage> {
  ClassificationService _classificationService;
  ImageService _imageService;
  Uint8List userImage;
  List<dynamic> result = [];

  @override
  void initState() {
    super.initState();
    // creating instance of ClassificationService class and passing parameters to
    // the function inside it
    // refer to services/classification.dart line 7
    _classificationService = ClassificationService(
      // refer to models/landmark.dart and constants/data.dart
      modelPath: widget.landmark.model,
      labelPath: widget.landmark.label,
    );
    _imageService = ImageService();
  }

  @override
  void dispose() {
    super.dispose();
    _classificationService.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Classification page code from here using important variables from above ☝️
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.pink.withOpacity(0.5),
        title: Text(widget.landmark.title, style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),),
      ),
      // Classification page code starts from here 👇
      body: Stack(
        children: [
          // Container for the classifier image on the background
          // Background image container code from here 👇
          Container(
            alignment: Alignment.center,
            // height and width of the background image container
            width: double.infinity,
            height: 480,
            decoration: BoxDecoration(
              image: DecorationImage(
                // if image is not passed by user yet,
                // use the landmark image defined in assets
                // else use the image passed by the user.
                image: userImage == null
                    ? AssetImage(widget.landmark.image)
                    : MemoryImage(userImage),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Classified output container code from here 👇
          Container(
            // taking maximum area available
            width: double.infinity,
            height: double.infinity,
            // margin from top
            margin: const EdgeInsets.only(top: 340),
            // padding the text inside the classifier output container, what is this landmark?
            // No image selected.
            padding: const EdgeInsets.only(
              top: 60,
              left: 30,
              right: 20,
            ),
            // Changing classifier output container shape and color
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            // Using singleChildScrollView to avoid overflow of pixel rendering and
            // To view more than 7 predictions if needed by someone without any render errors
            child: SingleChildScrollView(
              child: Column(
                // column's cross axis is left and right
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What is this landmark?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Colors.black
                    ),
                  ),
                  // Space between landmark text and no image selected
                  SizedBox(
                    height: 20,
                  ),
                  // if user didn't pass the image yet, show 'no text selected' else
                  // show predictions
                  userImage == null
                      ? Text(
                    'No image selected.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 15
                    ),
                  )
                  // Predictions made if userImage != null
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // result => dynamic list returned after running runClassification in
                      // services/classification.dart in line 73
                      for (var i = 0; i < result.length; i++)
                        // No of rows == no of predictions to make, i.e, 7
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                // Left align predicted label
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // starts from 0 index so i + 1
                                  Text('${i + 1}. ${result[i]['label']}', style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),),
                                  Text(
                                    '${result[i]['value']}',
                                    style: TextStyle(
                                      color: Colors.pink[700],
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Buttons next to each prediction to launch label search URl
                            // using url launcher package and _launchURL function on line 240
                            RaisedButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                              color: Colors.pink[300],
                              onPressed: () {
                                //function call line 240
                                _launchURL(result[i]['label']);
                              },
                              child: Text('Search', style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold
                              ),),
                            )
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Camera and Gallery Button code from here 👇
          Container(
            margin: const EdgeInsets.only(top: 310),
            alignment: Alignment.topCenter,
            child: Container(
              width: 80,
              height: 80,
              child: RawMaterialButton(
                splashColor: Colors.pink,
                onPressed: () async {
                  // calls loadImage() from services/image.dart
                  var imageData = await _imageService.loadImage();
                  // run classify function defined on line 193 of this page
                  var classification = classify(imageData);
                  setState(() {
                    userImage = imageData;
                    result = classification;
                  });
                },
                // button elevation for UX
                elevation: 5.0,
                fillColor: Colors.black54,
                child: Icon(
                  Icons.camera,
                  size: 50.0,
                  color: Colors.pinkAccent,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to runClassifier after user has passed image using image picker (gallery/photo)
  List<dynamic> classify(imageData) {
    // if no data is passed, return none
    if (imageData == null) {
      return [];
    } else {
      // imageData is picked from line 165 in this page
      // if data is passed call runClassification function from
      // services/classification.dart line 73
      return _classificationService.runClassification(
        imageData: imageData,
      );
    }
  }

  // Asynchronous function to launch urls to default browser of physical device/ emulators
  void _launchURL(String landmark) async {
      var url = "https://google.com/search?q=${landmark.replaceAll('_', ' ')}";
      // encode the complete URL using url_launcher package
      url = Uri.encodeFull(url);
      // await for response and launch url
      if (await canLaunch(url)) {
        await launch(url);
      // else throw error below
      } else {
        throw 'Could not launch $url';
      }
  }
}
