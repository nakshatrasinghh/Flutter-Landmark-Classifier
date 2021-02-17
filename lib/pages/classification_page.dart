import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:landmark_classifier/models/landmark.dart';
import 'package:landmark_classifier/services/classification.dart';
import 'package:landmark_classifier/services/image.dart';
import 'package:url_launcher/url_launcher.dart';

class ClassificationPage extends StatefulWidget {
  final Landmark landmark;

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
    _classificationService = ClassificationService(
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        title: Text(widget.landmark.title, style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),),
      ),
      body: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 480,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: userImage == null
                    ? AssetImage(widget.landmark.image)
                    : MemoryImage(userImage),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Container(
            width: double.infinity,
            height: double.infinity,
            margin: const EdgeInsets.only(top: 340),
            padding: const EdgeInsets.only(
              top: 70,
              left: 30,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What is this landmark?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  userImage == null
                      ? Text(
                    'No image selected.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < result.length; i++)
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text('${i + 1}. ${result[i]['label']}', style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),),
                                  Text(
                                    '${result[i]['value']}',
                                    style: TextStyle(
                                      color: Colors.pink,
                                      fontSize: 16
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RaisedButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                              color: Colors.black,
                              onPressed: () {
                                _launchURL(result[i]['label']);
                              },
                              child: Text('Search', style: TextStyle(
                                color: Colors.white,
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

          // Camera, Gallery Button
          Container(
            margin: const EdgeInsets.only(top: 310),
            alignment: Alignment.topCenter,
            child: Container(
              width: 70,
              height: 70,
              child: RawMaterialButton(
                splashColor: Colors.redAccent,
                onPressed: () async {
                  var imageData = await _imageService.loadImage();
                  var classification = classify(imageData);
                  setState(() {
                    userImage = imageData;
                    result = classification;
                  });
                },
                elevation: 5.0,
                fillColor: Colors.white,
                child: Icon(
                  Icons.camera,
                  size: 40.0,
                  color: Colors.redAccent,
                ),
                padding: EdgeInsets.all(15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> classify(imageData) {
    if (imageData == null) {
      return [];
    } else {
      return _classificationService.runClassification(
        imageData: imageData,
        resultCount: 10,
      );
    }
  }

  void _launchURL(String landmark) async {
    var url = 'https://google.com/search?q=${landmark.replaceAll('_', ' ')}';
    url = Uri.encodeFull(url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
