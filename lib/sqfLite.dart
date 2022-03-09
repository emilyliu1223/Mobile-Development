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

  // static add(String id, String name, String phone, String postcode, String detail, String sports, String day, String time,
  //     String img){
  //   _eventList.add(Events(id, name, phone, postcode, detail,sports, day, time, img));
  //   ts.writeEvents(jsonEncode(_eventList));
  //   print("Json of: "+jsonEncode(_eventList));
  // }
  // static remove(String id){
  //   // ignore: unrelated_type_equality_checks
  //   _eventList.removeWhere((element) => element.id==id);
  //   ts.writeEvents(jsonEncode(_eventList));
  // }
  // static removeAll(){
  //   _eventList.clear();
  //   ts.writeEvents(jsonEncode(_eventList));
  // }
  // static update(String id, String name, String phone, String postcode, String detail, String sports, String day, String time,
  //     String img){
  //   Events e=new Events(id, name, phone, postcode, detail,sports, day, time, img);
  //   _eventList[_eventList.indexWhere((element) => element.id==id)]=e;
  //   ts.writeEvents(jsonEncode(_eventList));
  // }


  // static readToDoFromFile() async{
  //   var tempToDos=await ts.readEvents();
  //   var tempToDosDecoded=jsonDecode(tempToDos) as List;
  //   _eventList=tempToDosDecoded.map((eventJson)=>Events.fromJson(eventJson)).toList();
  //   return _eventList;
  //
  // }
  // static getCount(){
  //   return _eventList.length;
  // }
}

class FavCollection {


  static var _favList=new List<Favorite>();
  static FavStorage fs=FavStorage();

  // static add(String id, String name, String phone, String postcode, String detail, String sports, String day, String time,
  //     String img){
  //   _eventList.add(Events(id, name, phone, postcode, detail,sports, day, time, img));
  //   ts.writeEvents(jsonEncode(_eventList));
  //   print("Json of: "+jsonEncode(_eventList));
  // }
  // static remove(String id){
  //   // ignore: unrelated_type_equality_checks
  //   _eventList.removeWhere((element) => element.id==id);
  //   ts.writeEvents(jsonEncode(_eventList));
  // }
  // static removeAll(){
  //   _eventList.clear();
  //   ts.writeEvents(jsonEncode(_eventList));
  // }
  // static update(String id, String name, String phone, String postcode, String detail, String sports, String day, String time,
  //     String img){
  //   Events e=new Events(id, name, phone, postcode, detail,sports, day, time, img);
  //   _eventList[_eventList.indexWhere((element) => element.id==id)]=e;
  //   ts.writeEvents(jsonEncode(_eventList));
  // }
  //
  //
  // static readToDoFromFile() async{
  //   var tempToDos=await fs.readFavs();
  //   var tempToDosDecoded=jsonDecode(tempToDos) as List;
  //   _favList=tempToDosDecoded.map((favJson)=>Favorite.fromJson(favJson)).toList();
  //   return _favList;
  //
  // }
  // static getCount(){
  //   return _favList.length;
  // }
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
  String address;
  String uuid;
  String user;
  // static final columns = ["id", "name", "phone", "postcode", "detail","sports"];
  Events(this.id, this.user,this.name, this.phone, this.postcode, this.detail,this.sports, this.day,this.time,this.img,this.address,this.uuid);

  Events.fromSnapshot(DataSnapshot snapshot) :
        id = snapshot.key,
        user=snapshot.value['user'],
        name= snapshot.value["name"],
        phone= snapshot.value["phone"],
        postcode = snapshot.value["postcode"],
        detail= snapshot.value["detail"],
        sports=snapshot.value["sports"],
        day=snapshot.value["day"],
        time=snapshot.value['time'],
        img=snapshot.value["img"],
        address=snapshot.value["address"],
        uuid=snapshot.value["uuid"];






  Map toJson()=>{
    'id': id,
    'user':user,
    'name': name,
    'phone': phone,
    'postcode': postcode,
    'detail': detail,
    'sports':sports,
    'day':day,
    'time':time,
    'img':img,
    'address':address,
    'uuid':uuid
  };


  factory Events.fromJson(dynamic json){
    return Events(
        json['id'] as String,
        json['user'] as String,
        json['name'] as String,
        json['phone'] as String,
        json['postcode'] as String,
        json['detail'] as String,
        json['sports'] as String,
        json['day'] as String,
        json['time'] as String,
        json['img'] as String,
        json['address'] as String,
        json['uuid'] as String

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

class Favorite {
  String id;
  String name;
  String user;
  String phone;
  String postcode;
  String detail;
  String sports;
  String day;
  String time;
  String img;
  String address;
  String uuid;
  String favby;
  // static final columns = ["id", "name", "phone", "postcode", "detail","sports"];
  Favorite(this.id, this.user,this.name, this.phone, this.postcode, this.detail,this.sports, this.day,this.time,this.img,this.address,this.uuid,this.favby);

  Favorite.fromSnapshot(DataSnapshot snapshot) :
        id = snapshot.key,
        user=snapshot.value['user'],
        name= snapshot.value["name"],
        phone= snapshot.value["phone"],
        postcode = snapshot.value["postcode"],
        detail= snapshot.value["detail"],
        sports=snapshot.value["sports"],
        day=snapshot.value["day"],
        time=snapshot.value['time'],
        img=snapshot.value["img"],
        address=snapshot.value["address"],
        uuid=snapshot.value["uuid"],
        favby=snapshot.value['favby'];






  Map toJson()=>{
    'id': id,
    'user':user,
    'name': name,
    'phone': phone,
    'postcode': postcode,
    'detail': detail,
    'sports':sports,
    'day':day,
    'time':time,
    'img':img,
    'address':address,
    'uuid':uuid,
    'favby':favby
  };


  factory Favorite.fromJson(dynamic json){
    return Favorite(
        json['id'] as String,
        json['user'] as String,
        json['name'] as String,
        json['phone'] as String,
        json['postcode'] as String,
        json['detail'] as String,
        json['sports'] as String,
        json['day'] as String,
        json['time'] as String,
        json['img'] as String,
        json['address'] as String,
        json['uuid'] as String,
        json['favby'] as String

    );
  }

}

class FavStorage {

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }
  //
  Future<File> get _localFile async {
    final path = await _localPath;
    print(path);
    return File('$path/favlist.json');
  }

  Future<File> writeFavs(String favs) async {
    final file = await _localFile;

    // Write the file.
    return file.writeAsString('$favs');
  }

  Future<String> readFavs() async {
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

}


