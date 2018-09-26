import 'package:flutter/material.dart';

class DummyScreen extends StatelessWidget {
  DummyScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Container(
          child: Row(
        children: <Widget>[
          Text(title),
        ],
      )),
    );
  }
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Screen'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Launch screen'),
          onPressed: () {
            // Navigate to second screen when tapped!
          },
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Screen"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
            // Navigate back to first screen when tapped!
            // Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}