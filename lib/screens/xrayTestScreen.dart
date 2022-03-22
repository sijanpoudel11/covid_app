import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class XrayTestScreen extends StatefulWidget {
  const XrayTestScreen({Key? key}) : super(key: key);

  @override
  State<XrayTestScreen> createState() => _XrayTestScreenState();
}

class _XrayTestScreenState extends State<XrayTestScreen> {
  bool _loading = true;
  File? _image;
  List? _output;
  final picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {
        // pass
      });
    });
  }

  loadModel() async {
    Tflite.close();
    await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
    );
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _output = output;
      _loading = false;
    });
  }

  pickImage() async {
    var image = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });

    classifyImage(_image!);
  }

  pickGalleryImage() async {
    var image = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });

    classifyImage(_image!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dianose xray for covid"),
      ),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 60),
              Text('CNN',
                  style: TextStyle(color: Color(0xFFEEDA28), fontSize: 18)),
              SizedBox(height: 6),
              Text("COVID Detection",
                  style: TextStyle(
                    color: Color(0xFFE99600),
                    fontWeight: FontWeight.w500,
                    fontSize: 28,
                  )),
              SizedBox(height: 40),
              Center(
                  child: _loading
                      ? Container(
                          width: 200,
                          child: Column(
                            children: <Widget>[
                              Image.asset(
                                'assets/covid.png',
                                cacheHeight: 200,
                                cacheWidth: 200,
                              ),
                              SizedBox(height: 50),
                            ],
                          ))
                      : Container(
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 250,
                                child: Image.file(_image!),
                              ),
                              SizedBox(height: 20),
                              _output != null
                                  ? Text(
                                      '${_output![0]}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 25,
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        )),
              Container(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Container(
                      padding: new EdgeInsets.only(top: 1.0),
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text('  ',
                              style: new TextStyle(
                                fontSize: 20.0,
                                fontFamily: 'Roboto',
                                color: new Color(0xFF26C6DA),
                              )),
                          new Text(
                            '',
                            style: new TextStyle(
                                fontSize: 35.0,
                                fontFamily: 'Roboto',
                                color: new Color(0xFF26C6DA)),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => pickImage(),
                        child: Container(
                            width: MediaQuery.of(context).size.width - 210,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 17,
                            ),
                            decoration: BoxDecoration(
                                color: Color(0xFFE99600),
                                borderRadius: BorderRadius.circular(6)),
                            child: Text("Take a photo",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20))),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => pickGalleryImage(),
                        child: Container(
                            width: MediaQuery.of(context).size.width - 210,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 17,
                            ),
                            decoration: BoxDecoration(
                                color: Color(0xFFE99600),
                                borderRadius: BorderRadius.circular(6)),
                            child: Text("Select from the storage",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20))),
                      ),
                    ],
                  )),
            ],
          )),
    );
  }
}
