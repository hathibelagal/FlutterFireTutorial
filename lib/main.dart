import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(new MaterialApp(home: new MyApp()));

class MyApp extends StatelessWidget {

  var myDatabase = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new RaisedButton(
          onPressed: () {
            ImagePicker.pickImage(source: ImageSource.camera).then((photo) {
              BarcodeDetector detector =
              FirebaseVision.instance.barcodeDetector(
                  BarcodeDetectorOptions(
                      barcodeFormats: BarcodeFormat.qrCode
                  )
              );
              detector
                  .detectInImage(FirebaseVisionImage.fromFile(photo))
                  .then((barcodes) {
                    if(barcodes.length > 0) {
                      var barcode = barcodes[0]; // Pick first barcode

                      myDatabase.collection("qr_codes").add({
                        "raw_data": barcode.rawValue,
                        "time": new DateTime.now().millisecondsSinceEpoch
                      }).then((_) {
                        print("One document added.");
                      });

                      showDialog(context: context, builder: (context) {
                        return new AlertDialog(
                          title: new Text("QR Code Contents"),
                          content: new Text(barcode.rawValue),
                          actions: <Widget>[new FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: new Text("OK")
                          )],
                        );
                      });
                    }
                  });
            });
          },
          child: new Text("Capture QR Code")
        )
      )
    );
  }
}
