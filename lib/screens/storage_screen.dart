import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';

class StorageScreen extends StatefulWidget {
  StorageScreen({Key key, @optionalTypeArgs this.document, this.config})
      : super(key: key);
  final DocumentSnapshot document;
  final DocumentSnapshot config;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<StorageScreen> {
  final _formKey = GlobalKey<FormState>();
  int currentStep = 0;
  File _image;
  Map<String, dynamic> _data; // = Map<String, String>();
  Future getImage(bool useCamera) async {
    final image = useCamera
        ? await ImagePicker.pickImage(source: ImageSource.camera)
        : await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = image;
        _data['imagePath'] = image.path;
      });
    }
  }

  // Form text controllers
  final _storageController = TextEditingController();
  final _itemsController = TextEditingController();

  @override
  void initState() {
    _data = widget.document != null && widget.document.exists
        ? widget.document.data
        : Map<String, dynamic>();
    _image = _data.containsKey('imagePath') &&
            FileSystemEntity.typeSync(_data['imagePath']) !=
                FileSystemEntityType.notFound
        ? File(_data['imagePath'])
        : null;
    _storageController.text = _data['storage'];
    _itemsController.text = _data['items'];
    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget containerSection = TextField(
      decoration: InputDecoration(
        hintText: "Name the Storage Location",
      ),
      controller: _storageController,
      onChanged: (value) {
        setState(() {
          _data['storage'] = value;
        });
      },
    );
    final _stories = json.decode(widget.config.data['stories']) as Map;
    Widget floorSection = Column(
        children: _stories.keys
            .map<Widget>((story) => RadioListTile(
                  title: Text(story),
                  value: story,
                  groupValue: _data['floor'],
                  onChanged: (value) {
                    setState(() {
                      _data['floor'] = value;
                    });
                  },
                ))
            .toList());
    print(_stories[_data['floor']]);
    var _rooms = _stories[_data['floor']] as List;
    Widget roomSection = Column(
        children: _rooms != null ?
            _rooms.map<Widget>(
              (room) => RadioListTile(
                    title: Text(room),
                    value: room,
                    groupValue: _data['room'],
                    onChanged: (value) {
                      setState(() {
                        _data['room'] = value;
                      });
                    },
                  ),
            )
            .toList() : []
        // <Widget>[
        //   RadioListTile(
        //     title: const Text('Basement'),
        //     value: 'Basement',
        //     groupValue: _data['room'],
        //     onChanged: (value) {
        //       setState(() {
        //         _data['room'] = value;
        //       });
        //     },
        //   ),
        //   RadioListTile(
        //     title: const Text('Kitchen'),
        //     value: 'Kitchen',
        //     groupValue: _data['room'],
        //     onChanged: (value) {
        //       setState(() {
        //         _data['room'] = value;
        //       });
        //     },
        //   ),
        // ],
        );
    Widget itemsSection = Column(children: [
      TextField(
        decoration: InputDecoration(
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
                  ? Column(children: <Widget>[
                      RaisedButton.icon(
                        onPressed: () {
                          getImage(true);
                        },
                        icon: Icon(Icons.camera),
                        label: Text('Take Image'),
                      ),
                      Text("or"),
                      RaisedButton.icon(
                        onPressed: () {
                          getImage(false);
                        },
                        icon: Icon(Icons.photo_album),
                        label: Text('Pick Photo'),
                      ),
                    ])
                  : Image.file(_image))),
      Step(
          isActive: true,
          title: Text("Storage Name"),
          content: containerSection),
      Step(isActive: true, title: Text("Floor"), content: floorSection),
      Step(isActive: true, title: Text("Room"), content: roomSection),
      Step(isActive: true, title: Text("Items"), content: itemsSection),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_data['storage'] ?? 'Storage'),
      ),
      body: Form(
          key: _formKey,
          // autovalidate: true,
          child: Stepper(
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
                  FocusScope.of(context).requestFocus(FocusNode());
                } else {
                  String missingValues = '';
                  ['floor', 'room', 'storage', 'items'].forEach((k) {
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
                        builder: (_) => AlertDialog(
                              title: Text("Missing Input"),
                              content: Text(
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