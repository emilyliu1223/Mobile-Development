
import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sportsmate/ItemDetail.dart';
import 'package:sportsmate/main.dart';
import 'package:sportsmate/sqfLite.dart';
import 'AllCollection.dart';
import 'ItemCollection.dart';
import 'NewItemPage.dart';
import 'authentication.dart';


class FavoriteItems extends StatefulWidget{
  // static const routeName = '/mypostPage';
  // List<Event> event;
  // List<String> sports;
  // final Future signout;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  // final GoogleSignInAccount googleaccount;
  // static const routeName = '/mypostPage';
  FavoriteItems({Key key,this.auth, this.userId, this.logoutCallback}) : super(key:key);


  @override
  _FavoriteItemsState createState()=>_FavoriteItemsState();

}

class _FavoriteItemsState  extends State<FavoriteItems> {

  List<Favorite> _favList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();


  StreamSubscription<Event> _onFavAddedSubscription;
  StreamSubscription<Event> _onFavChangedSubscription;

  Query _favQuery;

  //bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    //_checkEmailVerification();

    _favList = new List();
    _favQuery = _database
        .reference()
        .child("fav")
        .orderByChild("favby")
        .equalTo(widget.userId);
    _onFavAddedSubscription = _favQuery.onChildAdded.listen(onEntryAdded);
    _onFavChangedSubscription =
        _favQuery.onChildChanged.listen(onEntryChanged);
  }

  @override
  void dispose() {
    _onFavAddedSubscription.cancel();
    _onFavChangedSubscription.cancel();
    super.dispose();
  }

  onEntryChanged(Event event) {
    var oldEntry = _favList.singleWhere((entry) {
      return entry.id == event.snapshot.key;
    });

    setState(() {
      _favList[_favList.indexOf(oldEntry)] =
          Favorite.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded(Event event) {
    setState(() {
      if(Favorite.fromSnapshot(event.snapshot).favby==widget.userId){
      _favList.add(Favorite.fromSnapshot(event.snapshot));
      print("Favorite List:"+_favList.length.toString());
      }
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

  addNewFav(String id,String user,String name, String phone, String postcode, String detail,
      String sports, String day, String time,
      String img, String address,String uuid) {
    if (widget.userId.length > 0) {
      Favorite todo = new Favorite(
          id, user,name, phone, postcode, detail, sports, day, time, img, address,uuid,widget.userId);
      _database.reference().child("fav").push().set(todo.toJson());
    }
  }

  updateTodo(Events todo) {
    //Toggle completed

    if (todo != null) {
      _database.reference().child("event").child(todo.id).set(todo.toJson());
    }
  }

  deleteFav(String favby, String uuid) {
    _database.reference().child("fav").child(favby).child(uuid).remove().then((_) {
      print("Delete $uuid successful");
      setState(() {
        _favList.remove((fav)=>fav.favby==favby&&fav.uuid==uuid);
      });
    });
  }

  Widget myfuturewidget;

  @override
  Widget build(BuildContext context) {
    print(widget.userId.toString()+"userid of collection from homepage");
    // final ItemCollection args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
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
                onTap: () => {Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>MyHomePage(
                    userId: widget.userId,
                    auth: widget.auth,
                    logoutCallback: widget.logoutCallback,
                    // googleaccount: widget.googleaccount,
                    // signout:widget.signout
                  )),
                ),print("User id in collection on call of home page:"+widget.userId)},
              ),
              ListTile(
                leading: Icon(Icons.add_circle_outline),
                title: Text('Post an Invitation'),
                onTap: () => {Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>NewItemPage(
                    userId: widget.userId,
                    auth: widget.auth,
                    logoutCallback: widget.logoutCallback,
                    // googleaccount: widget.googleaccount,
                    //   signout:widget.signout

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
                    logoutCallback: widget.logoutCallback,
                    // googleaccount: widget.googleaccount,
                    // signout:widget.signout
                  )),
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
          title: Text("Sportsmate",style: TextStyle(
            color: Colors.white,
          ),),
          iconTheme: IconThemeData(color: Colors.white),
          // actions: <Widget>[
          //   new FlatButton(
          //       child: new Text('Logout',
          //           style: new TextStyle(fontSize: 17.0, color: Colors.white)),
          //       onPressed: signOut)
          // ],
        ),
        body:
        _favList.length > 0 ? (
        Column(
          children:[
            Container(),
            Expanded(
                child:
            ListView.builder(
            shrinkWrap: true,
            itemCount: _favList.length,
            itemBuilder: (BuildContext context, int index) {
              String Id = _favList[index].id;
              String user=_favList[index].user;
              String detail = _favList[index].detail;
              String sports = _favList[index].sports;
              String name = _favList[index].name;
              String postcode = _favList[index].postcode;
              String phone = _favList[index].phone;
              String date=_favList[index].day;
              String time=_favList[index].time;
              String img=_favList[index].img;
              String uuid=_favList[index].uuid;
              var imglist=img.split(",");
              img=imglist[0];
              String address=_favList[index].address;
              // String img1=_todoList[index].img1;
              // String img2=_todoList[index].img2;
              // String img3=_todoList[index].img3;

              // return Dismissible(
              //
              //   key: Key(Id),
              //   background: Container(color: Colors.lime),
                // onDismissed: (direction) async {
                //     deleteFav(widget.userId,uuid);
                // },

           return
                Card(
                    elevation: 8.0,
                    margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                    child:
                    // Column(
                    //   // mainAxisSize: MainAxisSize.min,
                    //   children: [
                        // Container(
                        //   alignment: Alignment.centerLeft,
                        //   child: Image.network(img,height: 150,)
                        //   ),
                        Container(
                          // height:200,
                          child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                              // leading: Container(
                              //    padding: EdgeInsets.only(right: 12.0),
                              //   decoration: new BoxDecoration(
                              //       border: new Border(
                              //           right: new BorderSide(width: 1.0, color: Colors.lime))),
                              //   child: FittedBox(
                              //     fit: BoxFit.fitHeight,
                              //       child: Text(date),
                              //   ),
                              // ),
                              // leading: new Image.network(
                              //  img,
                              //   fit: BoxFit.cover,
                              //   height: 200.0,
                              //
                              // ),
                              title: Text(
                                name,
                                style: TextStyle(fontSize: 18.0),
                              ),
                              subtitle: Row(
                                children: <Widget>[
                                  Icon(Icons.search, color: Colors.black26),
                                  Text(sports, style: TextStyle(color: Colors.black26))
                                ],
                              ),
                              trailing:
                              IconButton(icon:Icon(Icons.keyboard_arrow_right), color: Colors.black26,  onPressed: ()  {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) =>
                                        ItemDetail(
                                          id: Id,
                                          user:user,
                                          name: name,
                                          phone: phone,
                                          postcode: postcode,
                                          detail: detail,
                                          sports: sports,
                                          date: date,
                                          time: time,
                                          address:address,
                                          uuid:uuid,
                                          img: _favList[index].img,
                                          userId: widget.userId,
                                          auth: widget.auth,
                                          logoutCallback: widget.logoutCallback,
                                          favored: true,
                                          // signout:widget.signout

                                        ))
                                );
                              },)),
                      //   ),
                      // ],
                    )
                  // Container(
                  //   decoration: BoxDecoration(color: Colors.white),
                  //   child: ListTile(
                  //     contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  //     leading: Container(
                  //        padding: EdgeInsets.only(right: 12.0),
                  //       decoration: new BoxDecoration(
                  //           border: new Border(
                  //               right: new BorderSide(width: 1.0, color: Colors.lime))),
                  //       child: Image.network(img),
                  //     ),
                  //     title: Text(
                  //       name,
                  //       style: TextStyle(fontSize: 20.0),
                  //     ),
                  //       subtitle: Row(
                  //         children: <Widget>[
                  //           Icon(Icons.search, color: Colors.black26),
                  //           Text(sports, style: TextStyle(color: Colors.black26))
                  //         ],
                  //       ),
                  //       trailing:
                  //       IconButton(icon:Icon(Icons.keyboard_arrow_right), color: Colors.black26,  onPressed: ()  {
                  //         Navigator.push(context,
                  //             MaterialPageRoute(builder: (context) =>
                  //                 ItemDetail(
                  //                   id: Id,
                  //                   name: name,
                  //                   phone: phone,
                  //                   postcode: postcode,
                  //                   detail: detail,
                  //                   sports: sports,
                  //                   date: date,
                  //                   time: time,
                  //                   img: _todoList[index].img,
                  //                   userId: widget.userId,
                  //                   auth: widget.auth,
                  //                   logoutCallback: widget.logoutCallback,
                  //                   // signout:widget.signout
                  //
                  //                 ))
                  //         );
                  //       },)),
                  //
                  //
                  //
                  //   ),





                );


            }
        ))])
        ) : (Center(
            child: Text(
              "Welcome. Your list is empty",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30.0),
            )
        )
        )
    );
  }
}





