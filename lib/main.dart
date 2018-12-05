import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './screens/login_screen.dart' show LoginScreen;
import './screens/main_screen.dart' show MainScreen;
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  runApp(MyApp());
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // English
        const Locale('zh', 'CN'), // Chinese
        // ... other locales the app supports
      ],
      title: 'Expose',
      initialRoute: '/',
      routes: {
        // When we navigate to the "/" route, build the FirstScreen Widget
        '/': (context) => _handleCurrentScreen(),
        // '/pick': (context) => StorageScreen(),
      },
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        // primaryColor: Colors.blue,
        primarySwatch: Colors.green,
      ),
    );
  }

  Widget _handleCurrentScreen() {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    return StreamBuilder<FirebaseUser>(
        stream: _auth.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   // return SplashScreen();
          //   return DummyScreen(title: '1Test');
          // } else {
            if (snapshot.hasData) {
              return MainScreen(
                  firestore: _auth,
                  uuid: snapshot.data.uid);
            }
            return LoginScreen();
          // }
        });
  }
}
