import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';
import '../widgets/unsaved_changes_alert.dart' show UnsavedChangesAlert;
import '../utilities/string_to_color.dart' show stringToColor;
import '../constants/enums.dart' show Actions;

class StorageScreen extends StatefulWidget {
  StorageScreen(
      {Key key,
      @optionalTypeArgs this.document,
      this.config,
      this.showItemsTab})
      : super(key: key);
  final DocumentSnapshot document;
  final DocumentSnapshot config;
  final bool showItemsTab;
  @override
  _StorageScreenState createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _itemsFormKey = GlobalKey<FormState>();
  bool _edited = false;
  final _addItemTextInputController = TextEditingController();
  String _addItemTextInputValue;
  int currentStep = 0;
  File _image;
  Map<String, dynamic> _data; // = Map<String, String>();
  Future getImage(bool useCamera) async {
    final image = useCamera
        ? await ImagePicker.pickImage(source: ImageSource.camera)
        : await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _edited = true;
      setState(() {
        _image = image;
        _data['imagePath'] = image.path;
      });
    }
  }

  // Form text controllers
  final _storageController = TextEditingController();

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 5);
    _data = widget.document != null && widget.document.exists
        ? widget.document.data
        : Map<String, dynamic>();
    _image = _data.containsKey('imagePath') &&
            FileSystemEntity.typeSync(_data['imagePath']) !=
                FileSystemEntityType.notFound
        ? File(_data['imagePath'])
        : null;
    _storageController.text = _data['storage'];
    _addItemTextInputController.text = _addItemTextInputValue;
    _addItemTextInputController.addListener(_addItemTextInputListener);
    if (widget.showItemsTab) {
      _tabController.index = 4;
    }
    return super.initState();
  }

  _addItemTextInputListener() {
    setState(() {
      _addItemTextInputValue = _addItemTextInputController.text;
    });
  }

  @override
  void dispose() {
    _storageController.dispose();
    _addItemTextInputController.removeListener(_addItemTextInputListener);
    _addItemTextInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildCard(
        {@required String title,
        @required Widget child,
        @optionalTypeArgs bool isFirst = false,
        @optionalTypeArgs bool isLast = false}) {
      return Card(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
            Padding(padding: EdgeInsets.all(10.0)),
            Text(title, style: Theme.of(context).textTheme.title),
            Expanded(
              child: child,
            ),
          ]));
    }

    Widget _containerSection = _buildCard(
        title: 'Storage Name',
        child: Container(
            margin: EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "E.g., Living room cabinet 1",
              ),
              controller: _storageController,
              onChanged: (value) {
                _edited = true;
                setState(() {
                  _data['storage'] = value;
                });
              },
            )));
    final _stories = json.decode(widget.config.data['stories']) as Map;
    Widget _floorSection = _buildCard(
        title: 'Storey',
        child: Column(
            children: _stories.keys
                .map<Widget>((story) => RadioListTile(
                      title: Text(story),
                      value: story,
                      groupValue: _data['storey'],
                      onChanged: (value) {
                        _edited = true;
                        setState(() {
                          _data['storey'] = value;
                        });
                      },
                    ))
                .toList()));
    var _rooms = _stories[_data['storey']] as List;
    Widget _roomSection = _buildCard(
        title: 'Room',
        child: Column(
            children: _rooms != null
                ? _rooms
                    .map<Widget>(
                      (room) => RadioListTile(
                            title: Text(room),
                            value: room,
                            groupValue: _data['room'],
                            onChanged: (value) {
                              _edited = true;
                              setState(() {
                                _data['room'] = value;
                              });
                            },
                          ),
                    )
                    .toList()
                : []));
    final _colors = stringToColor(_data['room']);
    List<String> _items =
        _data['items'] != null ? (_data['items'] as String).split('|') : [];
    List<Widget> _itemChips = _items
        .map((item) => Container(
            margin: EdgeInsets.only(right: 5.0),
            child: InputChip(
                key: ValueKey<String>(item),
                backgroundColor: _colors[0],
                deleteIconColor: _colors[1],
                label: Text(
                  item,
                  style: TextStyle(color: _colors[1]),
                ),
                onDeleted: () {
                  _edited = true;
                  _items.remove(item);
                  setState(() {
                    _data['items'] =
                        _items.length > 0 ? _items.join('|') : null;
                  });
                })))
        .toList();
    final _addChipColors = stringToColor('+');
    _itemChips.add(Container(
        margin: EdgeInsets.only(right: 5.0),
        child: InputChip(
          label: Text(
            '+',
            style: TextStyle(color: _addChipColors[1]),
          ),
          backgroundColor: _addChipColors[0],
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                        title: Text("Add One or More Items"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'You can input multiple items at the same time - just use comma to separate them',
                              style: Theme.of(context).textTheme.caption,
                            ),
                            Form(
                                key: _itemsFormKey,
                                autovalidate: true,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "Item Name",
                                    suffixIcon: IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _addItemTextInputValue = null;
                                          });
                                          _addItemTextInputController.clear();
                                        }),
                                  ),
                                  controller: _addItemTextInputController,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    if (value.contains('|')) {
                                      return 'Item names cannot contain "|"';
                                    }
                                  },
                                ))
                          ],
                        ),
                        actions: <Widget>[
                          FlatButton.icon(
                            icon: const Icon(Icons.save_alt, size: 18.0),
                            label: const Text('Save'),
                            onPressed: () {
                              if (_itemsFormKey.currentState.validate()) {
                                Navigator.pop(context, _addItemTextInputValue);
                              }
                            },
                          ),
                        ])).then((value) {
              if (value != null) {
                // value is null when dismissed
                _edited = true;
                final RegExp _commaPattern = RegExp(r'(,|，)');
                if ((value as String).contains(_commaPattern)) {
                  final _itemsToAdd = (value as String).split(_commaPattern);
                  _itemsToAdd.forEach((item) => item.trim());
                  _itemsToAdd
                      .removeWhere((item) => (item == null) || (item == ''));
                  _items.addAll(_itemsToAdd);
                } else {
                  _items.add(value.trim());
                }
                setState(() {
                  _data['items'] = _items.join('|');
                });
                _addItemTextInputValue = null;
                _addItemTextInputController.clear();
              }
            });
          },
        )));
    Widget _itemsSection = _buildCard(
        title: 'Items (${_items.length})',
        isLast: true,
        child: Container(
            margin: EdgeInsets.all(20.0),
            child: Column(children: [
              Wrap(
                children: _itemChips,
              ),
            ])));

    Widget _photoSection = _buildCard(
        title: 'Choose a Photo',
        isFirst: true,
        child: _image == null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    RaisedButton.icon(
                      onPressed: () {
                        getImage(true);
                      },
                      icon: Icon(Icons.camera),
                      label: Text('From Camera'),
                    ),
                    Padding(padding: EdgeInsets.all(5.0)),
                    RaisedButton.icon(
                      onPressed: () {
                        getImage(false);
                      },
                      icon: Icon(Icons.photo_album),
                      label: Text('From Album'),
                    ),
                  ])
            : Container(
                constraints: BoxConstraints.loose(Size.square(300.0)),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(_image),
                    fit: BoxFit.fitWidth,
                  ),
                ),
                alignment: AlignmentDirectional.center,
                child: Stack(
                  children: <Widget>[
                    FloatingActionButton(
                      backgroundColor: _colors[0],
                      foregroundColor: _colors[1],
                      mini: true,
                      child: Icon(Icons.delete),
                      onPressed: () => setState(() {
                            _image = null;
                          }),
                    ),
                  ],
                )));

    final _scaffold = Scaffold(
      appBar: AppBar(
          title: Text(_data['storage'] ?? 'Storage'),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: () {
                Navigator.pop(context, Actions.DELETE);
              },
            )
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(text: "Photo", icon: Icon(Icons.photo)),
              Tab(text: "Storage", icon: Icon(Icons.book)),
              Tab(text: "Storey", icon: Icon(Icons.layers)),
              Tab(text: "Room", icon: Icon(Icons.crop_square)),
              Tab(text: "Items", icon: Icon(Icons.widgets)),
            ],
          )),
      body: Form(
          key: _formKey,
          // autovalidate: true,
          child: TabBarView(controller: _tabController, children: <Widget>[
            _photoSection,
            _containerSection,
            _floorSection,
            _roomSection,
            _itemsSection,
          ])),
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
              int _index;
              final _necessaryDataFields = [
                'storage',
                'storey',
                'room',
                'items'
              ];
              for (var i = 0; i < 4; i++) {
                if (!_data.containsKey(_necessaryDataFields[i]) ||
                    _data[_necessaryDataFields[i]].isEmpty) {
                  _index = i + 1;
                  break;
                }
              }
              if (_index != null) {
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          title: Text("Missing Input"),
                          content: Text(
                              "One or more fields are required. Please review before proceed"),
                        )).then((_) => _tabController.animateTo(_index));
              } else {
                Navigator.pop(context, _data);
                _edited = false;
              }
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.navigate_before),
              onPressed: () {
                _tabController.animateTo(_tabController.index - 1);
              },
            ),
            IconButton(
              icon: Icon(Icons.navigate_next),
              onPressed: () {
                _tabController.animateTo(_tabController.index + 1);
              },
            ),
          ],
        ),
        shape: CircularNotchedRectangle(),
      ),
    );
    return UnsavedChangesAlert(hasUnsavedChanges: _edited, child: _scaffold);
  }
}
