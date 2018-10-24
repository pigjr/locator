import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/preset.dart' show Preset;
import '../widgets/unsaved_changes_alert.dart' show UnsavedChangesAlert;
import '../utilities/string_to_color.dart' show stringToColor;

class ResidenceScreen extends StatefulWidget {
  ResidenceScreen(
      {Key key, this.config, this.initSetup = false, this.firestore, this.uuid})
      : super(key: key);
  final FirebaseAuth firestore;
  final String uuid;
  final DocumentSnapshot config;
  final bool initSetup;
  @override
  _ResidenceScreenState createState() => _ResidenceScreenState();
}

class _ResidenceScreenState extends State<ResidenceScreen>
    with TickerProviderStateMixin {
  final _config = Map<String, dynamic>();
  final _preset = Preset();
  TabController _tabController;
  final _addRoomTextInputController = TextEditingController();
  String _addRoomTextInputValue;
  bool _edited = false;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
    if (widget.config != null) {
      _config['houseType'] = widget.config.data['houseType'];
      _config['stories'] = widget.config.data['stories'];
      _tabController.index = 1;
    } else {
      _config['houseType'] = 'Two-story House';
      _config['stories'] = json.encode(_preset.houseTypes['Two-story House']);
      _tabController.index = 0;
    }
    _addRoomTextInputController.text = _addRoomTextInputValue;
    _addRoomTextInputController.addListener(_addRoomTextInputListener);
    return super.initState();
  }

  @override
  void dispose() {
    // Stop listening to text changes
    _addRoomTextInputController.removeListener(_addRoomTextInputListener);
    // Clean up the controller when the Widget is removed from the Widget tree
    _addRoomTextInputController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  _addRoomTextInputListener() {
    setState(() {
      _addRoomTextInputValue = _addRoomTextInputController.text;
    });
  }

  _getChips(String storey, List rooms) {
    final _formKey = GlobalKey<FormState>();
    final _chips = rooms.map<Widget>((room) {
      final _colors = stringToColor(room);
      return Container(
          margin: EdgeInsets.only(right: 5.0),
          child: InputChip(
              key: ValueKey<String>(room),
              // avatar: CircleAvatar(
              //   backgroundImage: _nameToAvatar(name),
              // ),
              backgroundColor: _colors[0],
              deleteIconColor: _colors[1],
              label: Text(
                room,
                style: TextStyle(color: _colors[1]),
              ),
              onDeleted: () {
                _edited = true;
                final _newStories = json.decode(_config['stories']);
                (_newStories[storey] as List).remove(room);
                setState(() {
                  _config['stories'] = json.encode(_newStories);
                });
              }));
    }).toList();
    final _addChipColors = stringToColor('+');
    _chips.add(InputChip(
      label: Text(
        '+',
        style: TextStyle(color: _addChipColors[1]),
      ),
      backgroundColor: _addChipColors[0],
      onPressed: () {
        final _newStories = json.decode(_config['stories']);
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                    title: Text("Add a Room"),
                    content: Form(
                        key: _formKey,
                        autovalidate: true,
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: "Room Name",
                            suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _addRoomTextInputValue = null;
                                  });
                                  _addRoomTextInputController.clear();
                                }),
                          ),
                          controller: _addRoomTextInputController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }
                            if ((_newStories[storey] as List).contains(value)) {
                              return 'Room names must be unique';
                            }
                          },
                          // onChange: (value) {
                          //   setState(() {
                          //     _addRoomTextInputValue = value;
                          //   });
                          // },
                        )),
                    actions: <Widget>[
                      FlatButton.icon(
                        icon: const Icon(Icons.save_alt, size: 18.0),
                        label: const Text('Save'),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            Navigator.pop(context, _addRoomTextInputValue);
                          }
                        },
                      ),
                    ])).then((value) {
          if (value != null) {
            // value is null when dismissed
            _edited = true;
            (_newStories[storey] as List).add(_addRoomTextInputValue);
            setState(() {
              _config['stories'] = json.encode(_newStories);
            });
            _addRoomTextInputValue = null;
            _addRoomTextInputController.clear();
          }
        });
      },
    ));
    return _chips;
  }

  @override
  Widget build(BuildContext context) {
    final _scaffold = Scaffold(
      appBar: AppBar(
          title: Text("Your Home"),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: "House Type",
                icon: Icon(Icons.layers),
              ),
              Tab(text: "Rooms", icon: Icon(Icons.crop_square)),
            ],
          )),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Column(children: <Widget>[
            Expanded(
              child: GridView.count(
                  // Create a grid with 2 columns. If you change the scrollDirection to
                  // horizontal, this would produce 2 rows.
                  crossAxisCount: 2,
                  // Generate 100 Widgets that display their index in the List
                  children: _preset.houseTypes.keys
                      .map((s) => Column(
                            children: <Widget>[
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    _edited = true;
                                    setState(() {
                                      _config['houseType'] = s;
                                    });
                                    setState(() {
                                      _config['stories'] =
                                          json.encode(_preset.houseTypes[s]);
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 10.0),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.fitHeight,
                                        image: AssetImage(
                                            _preset.houseTypeIcons[s]),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              RadioListTile(
                                title: Text(s),
                                value: s,
                                groupValue: _config['houseType'],
                                onChanged: (value) {
                                  _edited = true;
                                  setState(() {
                                    _config['houseType'] = value;
                                  });
                                  setState(() {
                                    _config['stories'] =
                                        json.encode(_preset.houseTypes[value]);
                                  });
                                },
                              ),
                            ],
                          ))
                      .toList()),
            ),
          ]),
          Column(children: <Widget>[
            Expanded(
                child: ListView(
                    children: json
                        .decode(_config['stories'])
                        .entries
                        .map<Widget>((MapEntry story) => Container(
                            // alignment: AlignmentDirectional.centerStart,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: BorderDirectional(
                                bottom: BorderSide(
                                    color: story.key != null
                                        ? stringToColor(story.key)[0]
                                        : Colors.white,
                                    width: 5.0),
                              ),
                            ),
                            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                            margin: EdgeInsets.only(top: 20.0),
                            child: Column(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  story.key,
                                  textScaleFactor: 1.5,
                                ),
                                Wrap(
                                  children: _getChips(story.key, story.value),
                                )
                              ],
                            )))
                        .toList())),
          ]),
        ],
      ),
      floatingActionButton: Builder(
        // Create an inner BuildContext so that the onPressed methods
        // can refer to the Scaffold with Scaffold.of().
        builder: (BuildContext context) {
          return FloatingActionButton(
            heroTag: "Save",
            child: Icon(
              Icons.done,
              color: Colors.white,
            ),
            onPressed: () {
              _config['author'] = widget.uuid;
              if (widget.initSetup) {
                Firestore.instance
                    .collection('configurations')
                    .document()
                    .setData(_config);
              } else {
                Navigator.pop(context, _config);
              }
            },
          );
        },
      ),
    );
    return UnsavedChangesAlert(hasUnsavedChanges: _edited, child: _scaffold);
  }
}
