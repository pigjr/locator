import '../utilities/string_to_color.dart';

class Storage {
  final String id;
  final String storage;
  final String storey;
  final String room;
  final String items;
  String photoURL;
  String imageURL;
  String backgroundColor;
  String foregroundColor;

  Storage(this.id, [this.storage, this.storey, this.room, this.items, String photoURL, this.imageURL]) {
    final _colors = stringToColor(this.room);
    this.backgroundColor = _colors[0];
    this.foregroundColor = _colors[1];
  }

  Storage.fromMap(Map map) :
        this(map['id'], map['storage'], map['storey'], map['room'], map['items'], map['photoURL'], map['imageURL']);

  Map toMap() => {
    "id": id,
    "storage": storage,
    "storey": storey,
    "room": room,
    "items": items,
    "photoURL": photoURL,
    "imageURL": imageURL,
    "backgroundColor": backgroundColor,
    "foregroundColor": foregroundColor
  };
}