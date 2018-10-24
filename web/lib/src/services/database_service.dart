import 'dart:async';

import 'package:angular/angular.dart';
import 'package:firebase/firebase.dart';
import 'package:firebase/firestore.dart' as fs;
import '../config.dart' as config;
import '../models/storage.dart' as storage;

@Injectable()
class DatabaseService {
  Auth _fbAuth;
  GoogleAuthProvider _fbGoogleAuthProvider;
  User user;
  List<storage.Storage> messages;

  DatabaseService() {
    if (apps.length == 0) {
      initializeApp(
        apiKey: config.apiKey,
        authDomain: config.authDomain,
        databaseURL: config.databaseURL,
        storageBucket: config.storageBucket,
        projectId: config.projectId,
        messagingSenderId: config.messagingSenderId,
      );
    }
    _fbGoogleAuthProvider = GoogleAuthProvider();
    _fbAuth = auth();
    _fbAuth.onAuthStateChanged.listen(_authChanged);
  }

  void _authChanged(User fbUser) {
    user = fbUser;
    if (user != null) {
      messages = [];
      fs.Query ref = firestore().collection('items').where('author', '==', user.uid);
      ref.onSnapshot.listen((querySnapshot) {

        messages = querySnapshot.docs
            .map((snapshot) => storage.Storage.fromMap(snapshot.data()))
            .toList();
      });
    }
  }

  Future signIn() async {
    try {
      await _fbAuth.signInWithPopup(_fbGoogleAuthProvider);
    } catch (error) {
      print("$runtimeType::login() -- $error");
    }
  }

  void signOut() {
    _fbAuth.signOut();
  }
}
