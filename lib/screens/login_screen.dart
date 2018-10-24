import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _authenticateWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        await _auth.signInWithGoogle(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'lib/assets/icon_logo.png',
                      width: 150.0,
                      height: 150.0,
                    ),
                    Text(
                      'Expose',
                      style: TextStyle(
                        fontSize: 24.0,
                      ),
                    ),
                  ],
                )),
            Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RaisedButton.icon(
                      color: Colors.white,
                      onPressed: _authenticateWithGoogle,
                      icon: Image.asset(
                          'lib/assets/g-logo.png',
                          width: 25.0,
                        ),
                        label: Text(
                            "Sign in with Google",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                            ),
                          ),
                    ),
                ]))
          ],
        ),
      ),
    );
  }
}
