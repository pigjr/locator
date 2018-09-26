import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';

class ImagePickerScreen extends StatefulWidget {
  ImagePickerScreen({Key key, @optionalTypeArgs this.document}) : super(key: key);
  final DocumentSnapshot document;
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<ImagePickerScreen> {
  final _formKey = GlobalKey<FormState>();
  int currentStep = 0;
  File _image;
  Map<String, dynamic> _data;// = new Map<String, String>();
  Future getImage() async {
    // var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
      _data['imagePath'] = image.path;
    });
  }

  // Form text controllers
  final _storageController = TextEditingController();
  final _itemsController = TextEditingController();

  @override
  void initState() {
    _data = widget.document.exists ? widget.document.data : new Map<String, dynamic>();
    _image = _data.containsKey('imagePath') ? File(_data['imagePath']) : null;
    _storageController.text = _data['storage'];
    _itemsController.text = _data['items'];
    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget containerSection = TextField(
      decoration: new InputDecoration(
        hintText: "Name the Storage Location",
      ),
      controller: _storageController,
      onChanged: (value) {
        setState(() {
          _data['storage'] = value;
        });
      },
    );
    Widget floorSection = Column(
      children: <Widget>[
        new RadioListTile(
          title: const Text('Basement'),
          value: 'Basement',
          groupValue: _data['floor'],
          onChanged: (value) {
            setState(() {
              _data['floor'] = value;
            });
          },
        ),
        new RadioListTile(
          title: const Text('First Floor'),
          value: 'First Floor',
          groupValue: _data['floor'],
          onChanged: (value) {
            setState(() {
              _data['floor'] = value;
            });
          },
        ),
      ],
    );
    Widget roomSection = Column(
      children: <Widget>[
        new RadioListTile(
          title: const Text('Basement'),
          value: 'Basement',
          groupValue: _data['room'],
          onChanged: (value) {
            setState(() {
              _data['room'] = value;
            });
          },
        ),
        new RadioListTile(
          title: const Text('Kitchen'),
          value: 'Kitchen',
          groupValue: _data['room'],
          onChanged: (value) {
            setState(() {
              _data['room'] = value;
            });
          },
        ),
      ],
    );
    Widget itemsSection = Column(children: [
      TextField(
        decoration: new InputDecoration(
          hintText: "Items in this storage, one per line",
        ),
        keyboardType: TextInputType.multiline,
        maxLines: 5,
        controller: _itemsController,
        onChanged: (value) {
          setState(() {
            _data['items'] = value;
          });
        },
      ),
    ]);

    List<Step> mySteps = [
      Step(
          isActive: true,
          title: Text("Add a Picture"),
          content: Align(
              alignment: Alignment.centerLeft,
              child: _image == null
                  ? RaisedButton.icon(
                      onPressed: getImage,
                      icon: Icon(Icons.camera),
                      label: Text('Pick Image'),
                    )
                  : Image.file(_image))),
      Step(isActive: true, title: Text("Storage Name"), content: containerSection),
      Step(isActive: true, title: Text("Floor"), content: floorSection),
      Step(isActive: true, title: Text("Room"), content: roomSection),
      Step(isActive: true, title: Text("Items"), content: itemsSection),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Add a Storage and Items'),
      ),
      body: Form(
          key: _formKey,
          // autovalidate: true,
          child: new Stepper(
            // Using a variable here for handling the currentStep
            currentStep: this.currentStep,
            // List the steps you would like to have
            steps: mySteps,
            // Define the type of Stepper style
            // StepperType.horizontal :  Horizontal Style
            // StepperType.vertical   :  Vertical Style
            type: StepperType.vertical,
            // Know the step that is tapped
            onStepTapped: (step) {
              // On hitting step itself, change the state and jump to that step
              setState(() {
                // update the variable handling the current step value
                // jump to the tapped step
                currentStep = step;
              });
            },
            onStepCancel: () {
              // On hitting cancel button, change the state
              setState(() {
                // update the variable handling the current step value
                // going back one step i.e subtracting 1, until its 0
                if (currentStep > 0) {
                  currentStep = currentStep - 1;
                } else {
                  Navigator.pop(context);
                }
              });
            },
            // On hitting continue button, change the state
            onStepContinue: () {
              setState(() {
                // update the variable handling the current step value
                // going back one step i.e adding 1, until its the length of the step
                if (currentStep < mySteps.length - 1) {
                  currentStep = currentStep + 1;
                  FocusScope.of(context).requestFocus(new FocusNode());
                } else {
                  String missingValues = '';
                  ['floor', 'room', 'storage', 'items']
                      .forEach((k) {
                    if (!_data.containsKey(k) || _data[k].isEmpty) {
                      missingValues += k + ' ';
                    }
                  });
                  if (missingValues.isEmpty) {
                    // Return data to save
                    Navigator.pop(context, _data);
                  } else {
                    showDialog(
                        context: context,
                        builder: (_) => new AlertDialog(
                              title: new Text("Missing Input"),
                              content: new Text(
                                  "Please input values to these fields: " +
                                      missingValues),
                            ));
                  }
                }
              });
            },
          )),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Validate will return true if the form is valid, or false if
      //     // the form is invalid.
      //     if (_formKey.currentState.validate()) {
      //       // If the form is valid, we want to show a Snackbar
      //       Scaffold.of(context)
      //           .showSnackBar(SnackBar(content: Text('Processing Data')));
      //     }
      //   },
      //   tooltip: 'Confirm',
      //   child: Icon(Icons.check),
      // ),
    );
  }
}
