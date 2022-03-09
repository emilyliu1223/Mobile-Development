// import 'package:flutter/material.dart';
//
// import 'package:firebase_database/firebase_database.dart';
// import 'package:sportsmate/sqfLite.dart';
//
// import 'dart:async';
//
// import 'authentication.dart';
//
// class HomePage extends StatefulWidget {
//   HomePage({Key key, this.auth, this.userId, this.logoutCallback})
//       : super(key: key);
//
//   final BaseAuth auth;
//   final VoidCallback logoutCallback;
//   final String userId;
//
//   @override
//   State<StatefulWidget> createState() => new _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   List<Events> _todoList;
//
//   final FirebaseDatabase _database = FirebaseDatabase.instance;
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//
//   final _textEditingController = TextEditingController();
//   StreamSubscription<Event> _onTodoAddedSubscription;
//   StreamSubscription<Event> _onTodoChangedSubscription;
//
//   Query _todoQuery;
//
//   //bool _isEmailVerified = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     //_checkEmailVerification();
//
//     _todoList = new List();
//     _todoQuery = _database
//         .reference()
//         .child("event")
//         .orderByChild("id")
//         .equalTo(widget.userId);
//     _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(onEntryAdded);
//     _onTodoChangedSubscription =
//         _todoQuery.onChildChanged.listen(onEntryChanged);
//   }
//
// //  void _checkEmailVerification() async {
// //    _isEmailVerified = await widget.auth.isEmailVerified();
// //    if (!_isEmailVerified) {
// //      _showVerifyEmailDialog();
// //    }
// //  }
//
// //  void _resentVerifyEmail(){
// //    widget.auth.sendEmailVerification();
// //    _showVerifyEmailSentDialog();
// //  }
//
// //  void _showVerifyEmailDialog() {
// //    showDialog(
// //      context: context,
// //      builder: (BuildContext context) {
// //        // return object of type Dialog
// //        return AlertDialog(
// //          title: new Text("Verify your account"),
// //          content: new Text("Please verify account in the link sent to email"),
// //          actions: <Widget>[
// //            new FlatButton(
// //              child: new Text("Resent link"),
// //              onPressed: () {
// //                Navigator.of(context).pop();
// //                _resentVerifyEmail();
// //              },
// //            ),
// //            new FlatButton(
// //              child: new Text("Dismiss"),
// //              onPressed: () {
// //                Navigator.of(context).pop();
// //              },
// //            ),
// //          ],
// //        );
// //      },
// //    );
// //  }
//
// //  void _showVerifyEmailSentDialog() {
// //    showDialog(
// //      context: context,
// //      builder: (BuildContext context) {
// //        // return object of type Dialog
// //        return AlertDialog(
// //          title: new Text("Verify your account"),
// //          content: new Text("Link to verify account has been sent to your email"),
// //          actions: <Widget>[
// //            new FlatButton(
// //              child: new Text("Dismiss"),
// //              onPressed: () {
// //                Navigator.of(context).pop();
// //              },
// //            ),
// //          ],
// //        );
// //      },
// //    );
// //  }
//
//   @override
//   void dispose() {
//     _onTodoAddedSubscription.cancel();
//     _onTodoChangedSubscription.cancel();
//     super.dispose();
//   }
//
//   onEntryChanged(Event event) {
//     var oldEntry = _todoList.singleWhere((entry) {
//       return entry.id == event.snapshot.key;
//     });
//
//     setState(() {
//       _todoList[_todoList.indexOf(oldEntry)] =
//           Events.fromSnapshot(event.snapshot);
//     });
//   }
//
//   onEntryAdded(Event event) {
//     setState(() {
//       _todoList.add(Events.fromSnapshot(event.snapshot));
//     });
//   }
//
//   signOut() async {
//     try {
//       await widget.auth.signOut();
//       widget.logoutCallback();
//     } catch (e) {
//
//
//
//
//       print(e);
//     }
//   }
//
//   addNewTodo(String name, String phone, String postcode, String detail, String sports, String day, String time,
//       String img) {
//     if (name.length > 0) {
//       Events todo = new Events(widget.userId.toString(),name,phone,postcode,detail,sports, day, time, img);
//       _database.reference().child("event").push().set(todo.toJson());
//     }
//   }
//
//   updateTodo(Events todo) {
//     //Toggle completed
//
//     if (todo != null) {
//       _database.reference().child("event").child(todo.id).set(todo.toJson());
//     }
//   }
//
//   deleteTodo(String todoId, int index) {
//     _database.reference().child("event").child(todoId).remove().then((_) {
//       print("Delete $todoId successful");
//       setState(() {
//         _todoList.removeAt(index);
//       });
//     });
//   }
//
//   showAddTodoDialog(BuildContext context) async {
//     _textEditingController.clear();
//     await showDialog<String>(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             content: new Row(
//               children: <Widget>[
//                 new Expanded(
//                     child: new TextField(
//                       controller: _textEditingController,
//                       autofocus: true,
//                       decoration: new InputDecoration(
//                         labelText: 'Add new todo',
//                       ),
//                     ))
//               ],
//             ),
//             actions: <Widget>[
//               new FlatButton(
//                   child: const Text('Cancel'),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   }),
//               new FlatButton(
//                   child: const Text('Save'),
//                   onPressed: () {
//                     addNewTodo('1','2','3','4','5','6','7','8');
//                     Navigator.pop(context);
//                   })
//             ],
//           );
//         });
//   }
//
//   Widget showTodoList() {
//     if (_todoList.length > 0) {
//       return ListView.builder(
//           shrinkWrap: true,
//           itemCount: _todoList.length,
//           itemBuilder: (BuildContext context, int index) {
//             String Id = _todoList[index].id;
//             String detail = _todoList[index].detail;
//             String sports = _todoList[index].sports;
//             String userId = _todoList[index].name;
//             return Dismissible(
//               key: Key(Id),
//               background: Container(color: Colors.red),
//               onDismissed: (direction) async {
//                 deleteTodo(Id, index);
//               },
//               child: ListTile(
//                 title: Text(
//                   detail+'\n'+sports+'\n'+userId,
//                   style: TextStyle(fontSize: 20.0),
//                 ),
//                 trailing: RaisedButton(
//                     // icon: (completed)
//                     //     ? Icon(
//                     //   Icons.done_outline,
//                     //   color: Colors.green,
//                     //   size: 20.0,
//                     // )
//                     //     : Icon(Icons.done, color: Colors.grey, size: 20.0),
//                     onPressed: () {
//                       updateTodo(_todoList[index]);
//                     }),
//               ),
//             );
//           });
//     } else {
//       return Center(
//           child: Text(
//             "Welcome. Your list is empty",
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 30.0),
//           ));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//         appBar: new AppBar(
//           title: new Text('Flutter login demo'),
//           actions: <Widget>[
//             new FlatButton(
//                 child: new Text('Logout',
//                     style: new TextStyle(fontSize: 17.0, color: Colors.white)),
//                 onPressed: signOut)
//           ],
//         ),
//         body: showTodoList(),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             showAddTodoDialog(context);
//           },
//           tooltip: 'Increment',
//           child: Icon(Icons.add),
//         ));
//   }
// }