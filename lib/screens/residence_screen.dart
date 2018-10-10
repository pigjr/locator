import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/preset.dart';

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

  @override
  void initState() {
    if (widget.config != null) {
      _config['houseType'] = widget.config.data['houseType'];
      _config['stories'] = widget.config.data['stories'];
    } else {
      _config['houseType'] = 'Two-story House';
      _config['stories'] = json.encode(_preset.houseTypes['Two-story House']);
    }
    _tabController = TabController(vsync: this, length: 2);
    return super.initState();
  }

  _getChips(String storey, List rooms) {
    final _chips = rooms.map<Widget>((room) {
      return InputChip(
          key: ValueKey<String>(room),
          // avatar: CircleAvatar(
          //   backgroundImage: _nameToAvatar(name),
          // ),
          label: Text(room),
          onDeleted: () {
            final _newStories = json.decode(_config['stories']);
            (_newStories[storey] as List).remove(room);
            setState(() {
              _config['stories'] = json.encode(_newStories);
            });
          });
    }).toList();
    _chips.add(InputChip(
      label: Text('+'),
      onPressed: () {},
    ));
    return _chips;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                flex: 1,
                child: Column(
                    children: _preset.houseTypes.keys
                        .map((s) => RadioListTile(
                              subtitle: Text(s),
                              title: Text(s),
                              value: s,
                              groupValue: _config['houseType'],
                              onChanged: (value) {
                                setState(() {
                                  _config['houseType'] = value;
                                });
                                setState(() {
                                  _config['stories'] =
                                      json.encode(_preset.houseTypes[value]);
                                });
                              },
                            ))
                        .toList())),
            ButtonBar(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RaisedButton.icon(
                  color: Colors.lightGreen,
                  icon: const Icon(Icons.navigate_next, size: 18.0),
                  label: const Text('Next'),
                  onPressed: () {
                    _tabController.animateTo(1);
                  },
                ),
              ],
            ),
          ]),
          Column(children: <Widget>[
            Expanded(
                flex: 1,
                child: ListView(
                    children: json
                        .decode(_config['stories'])
                        .entries
                        .map<Widget>((MapEntry story) => Card(
                            margin: EdgeInsets.only(top: 20.0),
                            child: Column(
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
            ButtonBar(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RaisedButton.icon(
                  color: Colors.lightGreen,
                  icon: const Icon(Icons.navigate_before, size: 18.0),
                  label: const Text('Previous'),
                  onPressed: () {
                    _tabController.animateTo(0);
                  },
                ),
                RaisedButton.icon(
                  color: Colors.lightGreen,
                  icon: const Icon(Icons.save_alt, size: 18.0),
                  label: const Text('Save'),
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
                ),
              ],
            ),
          ]),
        ],
      ),
    );
  }
}
