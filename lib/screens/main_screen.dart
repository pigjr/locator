import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import './storage_screen.dart';
import './residence_screen.dart';
import '../constants/preset.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key, this.firestore, this.uuid}) : super(key: key);
  final FirebaseAuth firestore;
  final String uuid;
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Form text controllers
  String _searchText = '';
  final _searchTextController = TextEditingController();
  final _config = Map<String, dynamic>();
  final _preset = Preset();
  // TabController _tabController;

  @override
  void initState() {
    _searchTextController.text = _searchText;
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

  Widget _buildListItem(
      BuildContext context, DocumentSnapshot document, config) {
    final List<String> items = (document['items'] as String).isNotEmpty
        ? document['items'].trim().split(RegExp(r"\s+"))
        : [];
    return InkWell(
      child: Card(
        key: ValueKey(document.documentID),
        child: Container(
          decoration: BoxDecoration(
              // border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(5.0),
              ),
          padding: const EdgeInsets.all(10.0),
          child: Column(
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

  _navigateAndPushEditScreen(BuildContext context, DocumentSnapshot document,
      DocumentSnapshot config) async {
    // Navigator.push returns a Future that will complete after we call
    // Navigator.pop on the Selection Screen!
    final saveData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            StorageScreen(document: document, config: config),
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

  _navigateAndPushPickScreen(
      BuildContext context, DocumentSnapshot config) async {
    // Navigator.push returns a Future that will complete after we call
    // Navigator.pop on the Selection Screen!
    final saveData = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              StorageScreen(document: null, config: config),
        )) as Map<String, dynamic>;
    // After the Selection Screen returns a result, show it in a Snackbar!
    if (saveData != null) {
      saveData['author'] = widget.uuid;
      await Firestore.instance.collection('items').document().setData(saveData);
    }
    // Scaffold.of(context).showSnackBar(SnackBar(content: Text("$saveResult")));
  }

  _navigateAndPushResidenceScreen(
      BuildContext context, DocumentSnapshot config) async {
    // Navigator.push returns a Future that will complete after we call
    // Navigator.pop on the Selection Screen!
    final saveData = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResidenceScreen(config: config),
        )) as Map<String, dynamic>;
    if (saveData != null) {
      saveData['author'] = widget.uuid;
      await Firestore.instance
          .collection('configurations')
          .document(config.reference.documentID)
          .updateData(saveData);
    }
  }

  _itemsScaffold(BuildContext context, DocumentSnapshot config) {
    void _select(String choice) {
      // Causes the app to rebuild with the _selectedChoice.
      switch (choice) {
        case "signOut":
          _signoutWithGoogle();
          break;
        default:
      }
    }
    return Scaffold(
      appBar: AppBar(title: Text("Your Items"), actions: <Widget>[
        // action button
        IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            _navigateAndPushResidenceScreen(context, config);
          },
        ),
        // overflow menu
        PopupMenuButton(
          onSelected: _select,
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                  value: "signOut",
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Sign out'),
                  ))
            ];
          },
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
                    decoration: InputDecoration(
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
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          itemCount: filteredDocuments.length,
                          padding: const EdgeInsets.all(10.0),
                          // itemExtent: 55.0,
                          itemBuilder: (context, index) => _buildListItem(
                              context, filteredDocuments[index], config),
                        )),
            ]);
          }),
      floatingActionButton: Builder(
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
            return ResidenceScreen(initSetup: true, firestore: widget.firestore, uuid: widget.uuid,);
            // return _wizardScaffold(context);
          } else {
            return _itemsScaffold(context, snapshot.data.documents[0]);
          }
        });
  }
}
