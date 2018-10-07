import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import './image_picker_screen.dart';
import '../constants/preset.dart';

class FirestoreScreen extends StatefulWidget {
  FirestoreScreen({Key key, this.firestore, this.uuid}) : super(key: key);
  final FirebaseAuth firestore;
  final String uuid;
  @override
  _FirestoreScreenState createState() => new _FirestoreScreenState();
}

class _FirestoreScreenState extends State<FirestoreScreen>
    with SingleTickerProviderStateMixin {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Form text controllers
  String _searchText = '';
  final _searchTextController = TextEditingController();
  final _config = Map<String, dynamic>();
  final _preset = Preset();
  TabController _tabController;

  @override
  void initState() {
    _searchTextController.text = _searchText;
    _tabController = new TabController(vsync: this, length: 2);
    _config['houseType'] = 'Two-story House';
    _config['stories'] = json.encode(_preset.houseTypes['Two-story House']);
    return super.initState();
  }

  void _signoutWithGoogle() async {
    await _googleSignIn.disconnect();
    await widget.firestore.signOut();
  }

  Widget _buildChip(BuildContext context, String item) {
    // return Text(item);
    return Chip(label: Text(item));
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document, config) {
    final List<String> items = (document['items'] as String).isNotEmpty
        ? document['items'].trim().split(RegExp(r"\s+"))
        : [];
    return InkWell(
      child: Card(
        key: new ValueKey(document.documentID),
        child: new Container(
          decoration: new BoxDecoration(
              // border: new Border.all(color: const Color(0x80000000)),
              // borderRadius: new BorderRadius.circular(5.0),
              ),
          padding: const EdgeInsets.all(10.0),
          child: new Column(
            children: <Widget>[
              Expanded(
                  flex: 3,
                  child: Center(
                      child: (document['imagePath'] != null &&
                              FileSystemEntity.typeSync(
                                      document['imagePath']) !=
                                  FileSystemEntityType.notFound)
                          ? Image.file(File(document['imagePath']))
                          : Text(document['storage'] ?? "Noname"))),
              Expanded(
                  flex: 1,
                  child: ListView.builder(
                    // shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        _buildChip(context, items[index]),
                  ))
            ],
          ),
        ),
      ),
      onTap: () {
        _navigateAndPushEditScreen(context, document, config);
      },
      // onTap: () => Firestore.instance.runTransaction((transaction) async {
      //       DocumentSnapshot freshSnap =
      //           await transaction.get(document.reference);
      //       // await transaction
      //       //     .update(freshSnap.reference, {'votes': freshSnap['votes'] + 1});
      //     }),
    );
  }

  _navigateAndPushEditScreen(
      BuildContext context, DocumentSnapshot document, DocumentSnapshot config) async {
    // Navigator.push returns a Future that will complete after we call
    // Navigator.pop on the Selection Screen!
    final saveData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePickerScreen(document: document, config: config),
      ),
    );
    if (saveData != null) {
      saveData['author'] = widget.uuid;
      await Firestore.instance
          .collection('items')
          .document(document.reference.documentID)
          .updateData(saveData);
    }
    // Scaffold.of(context).showSnackBar(SnackBar(content: Text("$saveResult")));
  }

  _navigateAndPushPickScreen(BuildContext context, DocumentSnapshot config) async {
    // Navigator.push returns a Future that will complete after we call
    // Navigator.pop on the Selection Screen!
    final saveData =
        await Navigator.push(context, MaterialPageRoute(
        builder: (context) => ImagePickerScreen(document: null, config: config),
      )) as Map<String, dynamic>;
    // After the Selection Screen returns a result, show it in a Snackbar!
    if (saveData != null) {
      saveData['author'] = widget.uuid;
      await Firestore.instance.collection('items').document().setData(saveData);
    }
    // Scaffold.of(context).showSnackBar(SnackBar(content: Text("$saveResult")));
  }

  _itemsScaffold(BuildContext context, config) {
    return Scaffold(
      appBar: AppBar(title: new Text("Your Items"), actions: <Widget>[
        IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: _signoutWithGoogle,
        ),
      ]),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('items')
              .where("author", isEqualTo: widget.uuid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            List filteredDocuments = _searchText.isNotEmpty
                ? (snapshot.data.documents as List)
                    .where((d) => (d['items'] as String).contains(_searchText))
                    .toList()
                : snapshot.data.documents;
            return Column(children: [
              Container(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    decoration: new InputDecoration(
                        hintText: "What item are you looking for?",
                        prefixIcon: Icon(
                          Icons.search,
                          size: 28.0,
                        ),
                        suffixIcon: _searchText.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _searchText = '';
                                    _searchTextController.clear();
                                  });
                                })
                            : null),
                    controller: _searchTextController,
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                  )),
              Expanded(
                  child: filteredDocuments.isEmpty
                      ? Center(
                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Icon(Icons.event_seat),
                            Text("Whoa, such empty"),
                            Icon(Icons.event_seat),
                          ],
                        ))
                      : GridView.builder(
                          gridDelegate:
                              new SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          itemCount: filteredDocuments.length,
                          padding: const EdgeInsets.all(10.0),
                          // itemExtent: 55.0,
                          itemBuilder: (context, index) =>
                              _buildListItem(context, filteredDocuments[index], config),
                        )),
            ]);
          }),
      floatingActionButton: new Builder(
        // Create an inner BuildContext so that the onPressed methods
        // can refer to the Scaffold with Scaffold.of().
        builder: (BuildContext context) {
          return FloatingActionButton(
            heroTag: "addStorage",
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              _navigateAndPushPickScreen(context, config);
            },
          );
        },
      ),
    );
  }

  _getChips(List rooms) {
    final _chips = rooms.map<Widget>((room) {
      return InputChip(
          key: ValueKey<String>(room),
          // avatar: CircleAvatar(
          //   backgroundImage: _nameToAvatar(name),
          // ),
          label: Text(room),
          onDeleted: () {
            setState(() {
              // _removeTool(name);
            });
          });
    }).toList();
    _chips.add(InputChip(
      label: Text('+'),
      onPressed: () {},
    ));
    return _chips;
  }

  _wizardScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: new Text("Your Home"),
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
          Column(
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
                  .toList()),
          ListView(
              children: json
                  .decode(_config['stories'])
                  .entries
                  .map<Widget>((MapEntry story) => Card(
                          child: Column(
                        children: <Widget>[
                          Text(
                            story.key,
                            textScaleFactor: 1.5,
                          ),
                          Wrap(
                            children: _getChips(story.value),
                          )
                        ],
                      )))
                  .toList()),
        ],
      ),
      floatingActionButton: new Builder(
        // Create an inner BuildContext so that the onPressed methods
        // can refer to the Scaffold with Scaffold.of().
        builder: (BuildContext context) {
          return FloatingActionButton(
            heroTag: "confirm",
            child: Icon(
              Icons.confirmation_number,
              color: Colors.white,
            ),
            onPressed: () {
              _saveConfig(context);
            },
          );
        },
      ),
    );
  }

  _saveConfig(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call
    // Navigator.pop on the Selection Screen!
    final saveData = _config;
    // After the Selection Screen returns a result, show it in a Snackbar!
    if (saveData != null) {
      saveData['author'] = widget.uuid;
      await Firestore.instance
          .collection('configurations')
          .document()
          .setData(saveData);
    }
    // Scaffold.of(context).showSnackBar(SnackBar(content: Text("$saveResult")));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('configurations')
            .where("author", isEqualTo: widget.uuid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if ((snapshot.data.documents as List).isEmpty) {
            return _wizardScaffold(context);
          } else {
            return _itemsScaffold(context, snapshot.data.documents[0]);
          }
        });
  }
}
