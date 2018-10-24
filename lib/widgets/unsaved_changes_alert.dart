import 'dart:async';
import 'package:flutter/material.dart';

class UnsavedChangesAlert extends StatelessWidget {
  const UnsavedChangesAlert({Key key, this.hasUnsavedChanges, this.child})
      : super(key: key);

  final bool
      hasUnsavedChanges; // Value indicating there are unsaved changes if true
  final Scaffold child; // Scaffold to add the unsaved changes check

  @override
  Widget build(BuildContext context) {
    Future<bool> _onWillPop() {
      return hasUnsavedChanges
          ? showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('Unsaved Changes'),
                    content: Text(
                        'You have unsaved changes. Discard them and leave this page?'),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('No'),
                      ),
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Yes'),
                      ),
                    ],
                  ),
            )
          : Future.value(true); // When no unsaved change, just pop the scope
    }

    return WillPopScope(onWillPop: _onWillPop, child: child);
  }
}
