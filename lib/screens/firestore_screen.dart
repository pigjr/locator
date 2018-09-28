import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import './splash_screen.dart' show SplashScreen;
import './image_picker_screen.dart';

class FirestoreScreen extends StatefulWidget {
  FirestoreScreen({Key key, this.title, this.firestore, this.uuid})
      : super(key: key);
  final String title;
  final FirebaseAuth firestore;
  final String uuid;
  @override
  _FirestoreScreenState createState() => new _FirestoreScreenState();
}

class _FirestoreScreenState extends State<FirestoreScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Form text controllers
  String _searchText = '';
  final _searchTextController = TextEditingController();

  @override
  void initState() {
    _searchTextController.text = _searchText;
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

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
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
                      child: (document['imagePath'] != null  && FileSystemEntity.typeSync(document['imagePath']) != FileSystemEntityType.notFound)
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
              _navigateAndPushEditScreen(context, document);
            },
      // onTap: () => Firestore.instance.runTransaction((transaction) async {
      //       DocumentSnapshot freshSnap =
      //           await transaction.get(document.reference);
      //       // await transaction
      //       //     .update(freshSnap.reference, {'votes': freshSnap['votes'] + 1});
      //     }),
    );
  }

  _navigateAndPushEditScreen(BuildContext context, DocumentSnapshot  document) async {
    // Navigator.push returns a Future that will complete after we call
    // Navigator.pop on the Selection Screen!
    final saveData =
        await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImagePickerScreen(document: document),
                ),
              );
    if (saveData != null) {
      saveData['author'] = widget.uuid;
      await Firestore.instance.collection('items').document(document.reference.documentID).updateData(saveData);
    }
    // Scaffold.of(context).showSnackBar(SnackBar(content: Text("$saveResult")));
  }

  _navigateAndPushPickScreen(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call
    // Navigator.pop on the Selection Screen!
    final saveData =
        await Navigator.pushNamed(context, '/pick') as Map<String, dynamic>;
    // After the Selection Screen returns a result, show it in a Snackbar!
    if (saveData != null) {
      saveData['author'] = widget.uuid;
      await Firestore.instance.collection('items').document().setData(saveData);
    }
    // Scaffold.of(context).showSnackBar(SnackBar(content: Text("$saveResult")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: new Text(widget.title), actions: <Widget>[
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
            return Column(
              children: [
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
                      ? Center(child: Row(
                        mainAxisAlignment:MainAxisAlignment.spaceEvenly,
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
                              _buildListItem(context, filteredDocuments[index]),
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
              _navigateAndPushPickScreen(context);
            },
          );
        },
      ),
    );
  }
}
