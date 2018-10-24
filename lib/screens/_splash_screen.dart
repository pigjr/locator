// import 'package:flutter/material.dart';
// import 'package:english_words/english_words.dart';

// class SplashScreen extends StatefulWidget {
//   SplashScreen({Key key, this.title}) : super(key: key);

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   _MyHomePageState createState() => new _MyHomePageState();
// }

// class _MyHomePageState extends State<SplashScreen> {
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return new RandomWords();
//   }
// }

// class RandomWordsState extends State<RandomWords> {
//   final List<WordPair> _suggestions = <WordPair>[];
//   final Set<WordPair> _saved = new Set<WordPair>();
//   final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
//   void _pushSaved() {
//     Navigator.of(context).push(
//       new MaterialPageRoute<void>(
//         // Add 20 lines from here...
//         builder: (BuildContext context) {
//           final Iterable<ListTile> tiles = _saved.map(
//             (WordPair pair) {
//               return new ListTile(
//                 title: new Text(
//                   pair.asPascalCase,
//                   style: _biggerFont,
//                 ),
//               );
//             },
//           );
//           final List<Widget> divided = ListTile
//               .divideTiles(
//                 context: context,
//                 tiles: tiles,
//               )
//               .toList();
//           return new Scaffold(
//             // Add 6 lines from here...
//             appBar: new AppBar(
//               title: const Text('Saved Suggestions'),
//             ),
//             body: new ListView(children: divided),
//           );
//         },
//       ),
//     );
//   }

//   Widget build(BuildContext context) {
//     return new Scaffold(
//       // Add from here...
//       appBar: new AppBar(
//         title: new Text('Startup Name Generator'),
//         actions: <Widget>[
//           new IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),
//         ],
//       ),
//       body: _buildSuggestions(),
//     );
//   }

//   Widget _buildRow(WordPair pair) {
//     final bool alreadySaved = _saved.contains(pair); // Add this line.
//     return new ListTile(
//       title: new Text(
//         pair.asPascalCase,
//         style: _biggerFont,
//       ),
//       trailing: new Icon(
//         // Add the lines from here...
//         alreadySaved ? Icons.favorite : Icons.favorite_border,
//         color: alreadySaved ? Colors.red : null,
//       ), // ... to here.
//       onTap: () {
//         // Add 9 lines from here...
//         setState(() {
//           if (alreadySaved) {
//             _saved.remove(pair);
//           } else {
//             _saved.add(pair);
//           }
//         });
//       }, // ... to here.
//     );
//   }

//   Widget _buildSuggestions() {
//     return new ListView.builder(
//         padding: const EdgeInsets.all(16.0),
//         // The itemBuilder callback is called once per suggested
//         // word pairing, and places each suggestion into a ListTile
//         // row. For even rows, the function adds a ListTile row for
//         // the word pairing. For odd rows, the function adds a
//         // Divider widget to visually separate the entries. Note that
//         // the divider may be difficult to see on smaller devices.
//         itemBuilder: (BuildContext _context, int i) {
//           // Add a one-pixel-high divider widget before each row
//           // in the ListView.
//           if (i.isOdd) {
//             return new Divider();
//           }

//           // The syntax "i ~/ 2" divides i by 2 and returns an
//           // integer result.
//           // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
//           // This calculates the actual number of word pairings
//           // in the ListView,minus the divider widgets.
//           final int index = i ~/ 2;
//           // If you've reached the end of the available word
//           // pairings...
//           if (index >= _suggestions.length) {
//             // ...then generate 10 more and add them to the
//             // suggestions list.
//             _suggestions.addAll(generateWordPairs().take(10));
//           }
//           return _buildRow(_suggestions[index]);
//         });
//   }
// }

// class RandomWords extends StatefulWidget {
//   @override
//   RandomWordsState createState() => new RandomWordsState();
// }
