import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;



class EventCollection {

  static var _eventList=new List<Events>();
  static EventStorage ts=EventStorage();

  static add(String id, String name, String phone, String postcode, String detail, String sports, String day, String time,
      String img){
    _eventList.add(Events(id, name, phone, postcode, detail,sports, day, time, img));
    ts.writeEvents(jsonEncode(_eventList));
    print("Json of: "+jsonEncode(_eventList));
  }
  static remove(String id){
    // ignore: unrelated_type_equality_checks
    _eventList.removeWhere((element) => element.id==id);
    ts.writeEvents(jsonEncode(_eventList));
  }
  static removeAll(){
    _eventList.clear();
    ts.writeEvents(jsonEncode(_eventList));
  }
  static update(String id, String name, String phone, String postcode, String detail, String sports, String day, String time,
      String img){
    Events e=new Events(id, name, phone, postcode, detail,sports, day, time, img);
    _eventList[_eventList.indexWhere((element) => element.id==id)]=e;
    ts.writeEvents(jsonEncode(_eventList));
  }


  static readToDoFromFile() async{
    var tempToDos=await ts.readEvents();
    var tempToDosDecoded=jsonDecode(tempToDos) as List;
    _eventList=tempToDosDecoded.map((eventJson)=>Events.fromJson(eventJson)).toList();
    return _eventList;

  }
  static getCount(){
    return _eventList.length;
  }
}

class Events {

  String id;
  String name;
  String phone;
  String postcode;
  String detail;
  String sports;
  String day;
  String time;
  String img;
  // static final columns = ["id", "name", "phone", "postcode", "detail","sports"];
  Events(this.id, this.name, this.phone, this.postcode, this.detail,this.sports, this.day,this.time,this.img);

  Events.fromSnapshot(DataSnapshot snapshot) :
        id = snapshot.key,
        name= snapshot.value["name"],
        phone= snapshot.value["phone"],
        postcode = snapshot.value["postcode"],
        detail= snapshot.value["detail"],
        sports=snapshot.value["sports"],
        day=snapshot.value["day"],
        time=snapshot.value['time'],
        img=snapshot.value["img"];





  Map toJson()=>{
    'id': id,
    'name': name,
    'phone': phone,
    'postcode': postcode,
    'detail': detail,
    'sports':sports,
    'day':day,
    'time':time,
    'img':img
  };


  factory Events.fromJson(dynamic json){
    return Events(
        json['id'] as String,
        json['name'] as String,
        json['phone'] as String,
        json['postcode'] as String,
        json['detail'] as String,
        json['sports'] as String,
        json['day'] as String,
        json['time'] as String,
        json['img'] as String

    );
  }

}

class EventStorage {

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }
  //
  Future<File> get _localFile async {
    final path = await _localPath;
    print(path);
    return File('$path/eventlist.json');
  }

  Future<File> writeEvents(String events) async {
    final file = await _localFile;

    // Write the file.
    return file.writeAsString('$events');
  }

  Future<String> readEvents() async {
    try {

      final file = await _localFile;

      // Read the file.
      String contents = await file.readAsString();

      return contents.toString();
    } catch (e) {
      // If encountering an error, return 0.
      return 'Something wrong when reading data';
    }
  }
  // Future wait(int seconds) {
  //   return new Future.delayed(Duration(seconds: seconds), () => {});
  // }
  // Future<String> _loadAEventAsset() async {
  //   return await rootBundle.loadString('assets/events.json');
  // }
  //
  // Future<Event> loadEvent() async {
  //   await wait(5);
  //   String jsonString = await _loadAEventAsset();
  //   final jsonResponse = json.decode(jsonString);
  //   return new Event.fromJson(jsonResponse);
  // }
  //






}




//
  // class SQLiteDbProvider {
  //   SQLiteDbProvider._();
  //
  //   static final SQLiteDbProvider db = SQLiteDbProvider._();
  //   static Database _database;
  //
  //   Future<Database> get database async {
  //     if (_database != null)
  //       return _database;
  //     _database = await initDB();
  //     return _database;
  //   }
  //
  //   initDB() async {
  //     Directory documentsDirectory = await
  //     getApplicationDocumentsDirectory();
  //     String path = join(documentsDirectory.path, "Event.db");
  //     return await openDatabase(
  //         path, version: 1,
  //         onOpen: (db) {},
  //         onCreate: (Database db, int version) async {
  //           await db.execute(
  //               "CREATE TABLE Event ("
  //                   "id INTEGER PRIMARY KEY,"
  //                   "name TEXT,"
  //                   "phone TEXT,"
  //                   "postcode TEXT,"
  //                   "detail TEXT,"
  //                   "sports TEXT"
  //                   ")"
  //           );
  //           await db.execute(
  //               "INSERT INTO Event ('id', 'name', 'phone', 'postcode', 'detail','sports')values (?, ?, ?, ?, ?,?)",
  //           [1
  //           , "Emily", "8572337750", '28202', "Looking for a sport friend",'Badminton']
  //           );
  //
  //
  //         }
  //     );
  //   }
  //
  //   Future<List<Event>> getAllEvents() async {
  //     final db = await database;
  //     List<Map> results = await db.query("Event", columns: Event.columns, orderBy: "id ASC");
  //     List<Event> events = new List();
  //     results.forEach((result) {
  //       Event event = Event.fromMap(result);
  //       events.add(event);
  //     });
  //     return events;
  //   }
  //
  //   Future<Event> getEventById(int id) async {
  //     final db = await database;
  //     var result = await db.query("Event", where: "id = ", whereArgs: [id]);
  //     return result.isNotEmpty ? Event.fromMap(result.first) : Null;
  //   }
  //
  //   insert(Event event) async {
  //     final db = await database;
  //     var maxIdResult = await db.rawQuery(
  //         "SELECT MAX(id)+1 as last_inserted_id FROM Event");
  //     var id = maxIdResult.first["last_inserted_id"];
  //     var result = await db.rawInsert(
  //         "INSERT Into Event (id, name, phone, postcode, detail, sports)"
  //             " VALUES (?, ?, ?, ?, ?,?)",
  //         [id, event.name, event.phone,event.postcode,event.detail,event.sports]
  //     );
  //     return result;
  //   }
  //
  //   update(Event event) async {
  //     final db = await database;
  //     var result = await db.update(
  //         "Event", event.toMap(), where: "id = ?", whereArgs: [event.id]
  //     );
  //     return result;
  //   }
  //
  //   delete(int id) async {
  //     final db = await database;
  //     db.delete("Event", where: "id = ?", whereArgs: [id]);
  //   }
  //   deleteAll() async {
  //     final db = await database;
  //     db.rawDelete("Delete from Event");
  //   }
  // }
  //
  //
  //
  // // Implement toString to make it easier to see information about
  // // each dog when using the print statement.

