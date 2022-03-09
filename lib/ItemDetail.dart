

import 'dart:async';
import 'package:favorite_button/favorite_button.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:sportsmate/sqfLite.dart';
import 'package:url_launcher/url_launcher.dart';
import 'AllCollection.dart';
import 'FavoriteItems.dart';
import 'ItemCollection.dart';
import 'NewItemPage.dart';
import 'authentication.dart';
import 'main.dart';

class ItemDetail extends StatefulWidget{
  String name;
  String phone;
  String postcode;
  // List<String> sports=[];
   String detail;
   String id;
   String sports;
   BaseAuth auth;
   VoidCallback logoutCallback;
  String userId;
  String date;
  String time;
  String uuid;
  String address;
  String img;
  Future signout;
  bool favored;
 String user;
 bool ismypost;



  ItemDetail({Key key,this.id,this.name,this.phone,this.postcode,
    this.sports,this.detail,this.auth, this.userId, this.logoutCallback,
    this.date,this.time,this.img, this.signout, this.address, this.uuid, this.favored, this.user, this.ismypost
  }):super(key:key);
 // static const routeName = '/detailPage';
  @override
  _ItemDetailState createState()=>_ItemDetailState();

}
class _ItemDetailState extends State<ItemDetail>{
  List<Events> _todoList;
  List<Favorite> _favList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  StreamSubscription<Event> _onFavAddedSubscription;
  StreamSubscription<Event> _onFavChangedSubscription;
  var messageController=new TextEditingController();
  bool favored;
  Query _todoQuery;
  Query _favQuery;

  //bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    //_checkEmailVerification();

    _todoList = new List();
    _todoQuery = _database
        .reference()
        .child("event")
        .orderByChild("id")
        .equalTo(widget.userId);
    _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(onEntryAdded);
    _onTodoChangedSubscription =
        _todoQuery.onChildChanged.listen(onEntryChanged);


    _favList = new List();
    _favQuery = _database
        .reference()
        .child("fav")
        .orderByChild("favby")
        .equalTo(widget.userId);
    _onFavAddedSubscription = _favQuery.onChildAdded.listen(onFavEntryAdded);
    _onFavChangedSubscription =
        _favQuery.onChildChanged.listen(onFavEntryChanged);

  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    _onFavAddedSubscription.cancel();
    _onFavChangedSubscription.cancel();

    super.dispose();
  }

  onEntryChanged(Event event) {
    var oldEntry = _todoList.singleWhere((entry) {
      return entry.id == event.snapshot.key;

    });

    setState(() {
      _todoList[_todoList.indexOf(oldEntry)] =
          Events.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded(Event event) {
    setState(() {
      _todoList.add(Events.fromSnapshot(event.snapshot));
    });
  }

  onFavEntryChanged(Event event) {
    var oldEntry = _favList.singleWhere((entry) {
      return entry.id == event.snapshot.key;
    });

    setState(() {
      _favList[_favList.indexOf(oldEntry)] =
          Favorite.fromSnapshot(event.snapshot);
    });
  }

  onFavEntryAdded(Event event) {
    setState(() {
      print(widget.userId);
      if(Favorite.fromSnapshot(event.snapshot).favby==widget.userId) {
        _favList.add(Favorite.fromSnapshot(event.snapshot));
      }
      print("favlist length"+_favList.length.toString());
    });
  }



  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }
  // String _message = "";

  String _message = "";

  void _sendSMS(String message, List<String> recipents) async {
    String _result =
    await FlutterSms.sendSMS(message: message, recipients: recipents);
    setState(() => _message = _result);
  }

  // void _canSendSMS() async {
  //   bool _result = await canSendSMS();
  //   setState(() => _canSendSMSMessage =
  //   _result ? 'This unit can send SMS' : 'This unit cannot send SMS');
  // }

  addNewFav(String id,String user,String name, String phone, String postcode, String detail,
      String sports, String day, String time,
      String img, String address,String uuid) {
    print(_favList);
    if (widget.userId.length > 0) {
     Favorite todo = new Favorite(
          id, user,name, phone, postcode, detail, sports, day, time, img, address,uuid,widget.userId);
      _database.reference().child("fav").push().set(todo.toJson());
    }
  }

  // updateFav(Favorite fav) {
  //   //Toggle completed
  //
  //   if (fav != null) {
  //     _database.reference().child("fav").child('fa').set(todo.toJson());
  //   }
  // }

  deleteFav(String uuid, String favby) {
    print(_favList[0].uuid);
    print(uuid);
    print(_favList[0].favby);
    print(favby);
    print(_favList.where((element) => element.favby==favby&&element.uuid==uuid).length);
    if(_favList.where((element) => element.favby==favby&&element.uuid==uuid).length>0) {
      var ele = _favList.firstWhere((element) =>
      element.favby == favby && element.uuid == uuid);
      var id = ele.id;
      print(id);
      _database.reference().child("fav").child(id).remove().then((_) {
        print("Delete $uuid successful");
        setState(() {
          _favList.remove((fav) => fav.favby == favby && fav.uuid == uuid);
          print(_favList.length);
        });
      });
    }
  }
  _launchURL() async {
    var url = 'tel://'+ widget.phone;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override

  Widget build(BuildContext context) {
     favored=widget.favored;
    List<String>sportlist=widget.sports.split(',');
    widget.img.replaceAll("[[", "");
    widget.img.replaceAll("]]", "");
    widget.img.trimLeft();
    widget.img.trimRight();
    List<String> imagelist= widget.img.split(',');
    messageController.text="Hi this is [REPLACE WITH YOUR NAME], I am insterested in your post '${widget.name}'and would like to play sports with you! "
       + "Please let me know if you are available";
    Widget titleSection = Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    //
                    child:
                    Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.center,
                      spacing: 5.0,
                      runSpacing: 6.0,

                      children:sportlist.map((s)=>Chip(
                        // avatar: CircleAvatar(
                        //   backgroundColor: Colors.grey.shade800,
                        //   child: Text('AB'),
                        // ),
                        backgroundColor: Colors.lightGreen,
                        shadowColor: Colors.black26,

                        label: Text(s),
                        labelStyle: TextStyle(color: Colors.white),
                      )).toList().cast<Widget>(),
                    )

                ),

                // Text(
                //   "Phone Number:  " +widget.phone,
                //   style: TextStyle(
                //     color: Colors.grey[500],
                //   ),
                // ),

              ],
            ),
          ),
          /*3*/
         widget.ismypost==true?Container():
          FavoriteButton(
            isFavorite: favored,
            valueChanged: (_isFavorite) {
              print('Is Favorite $_isFavorite');
              if(_isFavorite==true&&_favList.where((e)=>e.uuid==widget.uuid).length==0){
                addNewFav(widget.id, widget.user, widget.name, widget.phone, widget.postcode, widget.detail, widget.sports, widget.date, widget.time, widget.img, widget.address, widget.uuid);
              }else if(_favList.where((e)=>e.uuid==widget.uuid).length>=0&& _isFavorite==false){
                print(widget.uuid);
                print(widget.userId);
                deleteFav(widget.uuid,widget.userId);
              }
            },
          )
        ],
      ),
    );

    Color color = Theme.of(context).primaryColor;

    Widget buttonSection = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(color, Icons.message, 'MESSAGE'),
          _buildButtonColumn(color, Icons.near_me, 'ROUTE'),
          _buildButtonColumn(color, Icons.call, 'CALL'),
        ],
      ),
    );
    Widget pictureSection=new Center(
      child: new Container(
        height: 200.0,
        child: new ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          children: new List.generate(imagelist.length, (int index) {
            return new Center(
                child:new Card(
              // color: Colors.blue[index * 100],
              child: new Container(
                width: 150.0,
                height: 200.0,
                child: new Image.network(imagelist[index]),
              ),
            ));
          }),
        ),
      )
    );


    Widget textSection = Container(
        padding: const EdgeInsets.all(32),
        child: Text(
          "Time:\n"+widget.date+'\n'+widget.time+'\n'+
          "Address:\n"+widget.address+'\n'+
          "Detail:\n"+widget.detail,
          softWrap: true,

        ));

    return
      Scaffold(
        drawer: Drawer(
          child: ListView(

            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text(
                  'Sportsmate',
                  style: TextStyle(color: Colors.limeAccent, fontSize: 25),
                ),
                decoration: BoxDecoration(
                    color: Colors.lime,
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage('images/sports.jpg'))),
              ),
              ListTile(
                leading: Icon(Icons.house_outlined),
                title: Text('Home Page'),
                onTap: () => { Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>MyHomePage(
                userId: widget.userId,
                auth: widget.auth,
                logoutCallback:widget.logoutCallback,
                )))}
              ),
              ListTile(
                leading: Icon(Icons.add_circle_outline),
                title: Text('Post an Invitation'),
                onTap: () => {
                  print("Post from ItemDetail:"+widget.userId),
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>NewItemPage(
                      userId: widget.userId,
                      auth: widget.auth,
                      logoutCallback:widget.logoutCallback,
                 )),
                )},
              ),
              ListTile(
                leading: Icon(Icons.view_list_outlined),
                title: Text('My Post History'),
                onTap: () => {Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>ItemCollection(
                      userId: widget.userId,
                      auth: widget.auth,
                      logoutCallback:widget.logoutCallback)),
                )},
              ),
              ListTile(
                leading: Icon(Icons.saved_search),
                title: Text('Searh for Events'),
                onTap: () => {Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>AllCollection(
                    userId: widget.userId,
                    auth: widget.auth,
                    logoutCallback: widget.logoutCallback,
                    // googleaccount: widget.googleaccount,
                    // signout:signOut()
                  )),
                )},
              ),
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text('My Favorite Events'),
                onTap: () => {Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>FavoriteItems(
                    userId: widget.userId,
                    auth: widget.auth,
                    logoutCallback: widget.logoutCallback,

                  )),
                )},
              ),

            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.lime,
          title: Text('Post Detail',style: TextStyle(
            color: Colors.white,
          ),),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body:
        Container(
            child:
            new ListView(
                shrinkWrap: true,
            children:[
              Column(
              mainAxisSize: MainAxisSize.min,
              children:<Widget> [

                imagelist.length>0?
                Container(child:Image.network(
                  imagelist[0].toString().replaceAll('[', '').replaceAll(']', '').trimLeft().trimRight(),
                  width: 600,
                  height: 240,
                  fit: BoxFit.cover,
                ))
                    : Container(
                  child: Image.asset("images/default.png",
                      width: 600,
                      height: 240,
                      fit: BoxFit.cover),
                ),
                titleSection,
                buttonSection,

                textSection,
                pictureSection,
               Container(
                 padding: const EdgeInsets.all(32),
               )


              ]

      )
          ]
      )
    )
);
  }
  Column _buildButtonColumn(Color color, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed:(){
          if(label=="MESSAGE"){
            _sendSMS(messageController.text, [widget.phone]);
          }
          else if(label=="ROUTE"){
            print(widget.address);
            MapsLauncher.launchQuery(widget.address);
          }else if(label=="CALL"){
            _launchURL();
          }
        }, icon: Icon(icon, color: color)),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),

    )
    ]
    );

}
}

