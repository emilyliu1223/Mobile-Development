
import 'dart:io';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sportsmate/sqfLite.dart';
import 'package:time_range/time_range.dart';
import 'authentication.dart';
import 'package:path/path.dart' as Path;

class NewItemForm extends StatefulWidget{


  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  NewItemForm( {Key key,this.auth, this.userId, this.logoutCallback}):super(key: key);

  @override
  NewItemFormState createState()=>NewItemFormState();


}

class NewItemFormState extends State<NewItemForm> {

  File _image;
  File _image1;
  File _image2;
  File _image3;
  List<File> filelist;
  List<String> imageUrls;
  // String _uploadedFileURL;
  // String _uploadedFileURL1;
  // String _uploadedFileURL2;
  // String _uploadedFileURL3;
  final _formKey=GlobalKey<FormState>();
  final nameController=TextEditingController();
  final phoneController=TextEditingController();
  final postcodeController=TextEditingController();
  final detailController=TextEditingController();
  var sports='';
  var filestring='';

  Future<void> _initializeControllerFuture;
  List<Events> _todoList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  Query _todoQuery;

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


    // _controller = CameraController(
    //   // Get a specific camera from the list of available cameras.
    //   widget.camera,
    //   // Define the resolution to use.
    //   ResolutionPreset.medium,
    // );
    // // Next, initialize the controller. This returns a Future.
    // _initializeControllerFuture = _controller.initialize();
    filelist=new List<File>();
    imageUrls=new List<String>();
  }


  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    // _controller.dispose();
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

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

 Future addNewTodo(String name, String phone, String postcode, String detail, String sports, String day, String time,
      String img)async {

    if (name.length > 0) {
     Events todo = new Events(widget.userId.toString(),name,phone,postcode,detail,sports, day, time, img);
     await _database.reference().child("event").push().set(todo.toJson());
    }
    print("3");
  }


  updateTodo(Events todo) {
    if (todo != null) {
      _database.reference().child("event").child(todo.id).set(todo.toJson());
    }
  }

  deleteTodo(String todoId, int index) {
    _database.reference().child("event").child(todoId).remove().then((_) {
      print("Delete $todoId successful");
      setState(() {
        _todoList.removeAt(index);
      });
    });
  }


  Future _handleNewItemEntry() async{
    for(int i=0;i<sportlist.length;i++){
      if(i==0){
         sports+=sportlist.elementAt(i);
      }else{
        sports+=",";
        sports+=sportlist.elementAt(i);
      }
    }
    sportlist.clear();
if(photos()) {
  for (int j = 0; j < imageUrls.length; j++) {
    if (j == 0) {
      filestring += imageUrls.elementAt(j);
    } else {
      filestring += ',';
      filestring += imageUrls.elementAt(j);
    }
  }
}else{
    filestring+="default";
}
  print("2");
    }

 void addphoto(File img){
   if(img!=null){filelist.add(img);}
 }

  bool photos(){
    return filelist.isNotEmpty;
  }
  bool tcondition=false;
  bool dcondition=false;
  var start='';
  var end='';
  var tvisibility=false;
  var dvisibility=false;
  var newDate='';
  DateTime now=new DateTime.now();
  bool isPhotoExisted=false;



  @override
  Widget build(BuildContext context) {

    DateTime _date = DateTime(2021, 3, 17);

    void _selectDate() async {
      final DateTimeRange newDateRange = await showDateRangePicker(
        context: context,
        initialDateRange: DateTimeRange(
          start: DateTime(now.year,now.month,now.day),
          end: DateTime(now.year,now.month,now.day+1),
        ),
        firstDate: DateTime(now.year,now.month,now.day),
        lastDate: DateTime(now.year,now.month+2,now.day),
        helpText: 'Select a date',
      );
      if (newDateRange.end.day != null && newDateRange.start.day!=null) {
        setState(() {
          newDate ="From: " + newDateRange.start.year.toString()
              +"/"+newDateRange.start.month.toString()
              +"/"+newDateRange.start.day.toString()
              + " To: "
              +newDateRange.end.year.toString()
              +"/"+newDateRange.end.month.toString()
              +"/"+newDateRange.end.day.toString()
          ;
        });
      }
    }
    Widget pictureSection=new Container(
      height: 200.0,
      child: new ListView(
        scrollDirection: Axis.horizontal,
        children: new List.generate(filelist.length, (int index) {
          return new Card(
            // color: Colors.blue[index * 100],
            child: new Container(
              width: 150.0,
              height: 200.0,
              child: new Image.file(filelist[index]),
            ),
          );
        }),
      ),
    );
   return
   Scaffold(

     body:  Form(
       key:_formKey,
       child:  SingleChildScrollView(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.stretch,
             children: <Widget>[
               Padding(padding:EdgeInsets.all(10.0) ),
               Container(
                 padding: EdgeInsets.all(12),
                 width: 300,
                 height: 80,
                 child: TextFormField(
                   keyboardType: TextInputType.name,
                   decoration: InputDecoration(
                     labelText: "Name",
                     labelStyle: TextStyle(color: Colors.lime),
                     border: new OutlineInputBorder(
                       borderRadius: new BorderRadius.circular(25.0),
                       borderSide: new BorderSide(),
                     ),),
                   textAlign: TextAlign.center,
                   style: TextStyle(color: Colors.black26, fontSize: 16.0),
                   controller: nameController,
                   validator: (value){
                     if(value.isEmpty){
                       return 'Please enter Name';
                     }
                     return null;
                   },
                 ),
               ),
               Container(
                 padding: EdgeInsets.all(12),
                 width: 300,
                 height: 80,
                 child:  TextFormField(
                   keyboardType: TextInputType.phone,
                   decoration: InputDecoration(
                     labelText: "Phone",
                     labelStyle: TextStyle(color: Colors.lime),
                     border: new OutlineInputBorder(
                       borderRadius: new BorderRadius.circular(25.0),
                       borderSide: new BorderSide(),
                     ),),
                   textAlign: TextAlign.center,
                   style: TextStyle(color: Colors.black26, fontSize: 16.0),
                   controller: phoneController,
                   validator: (value){
                     if(value.isEmpty){
                       return 'Please enter Phone';
                     }
                     return null;
                   },
                 ),
               ),

               Container(
                 padding: EdgeInsets.all(12),
                 width: 300,
                 height: 80,
                 child:    TextFormField(
                   keyboardType: TextInputType.number,
                   decoration: InputDecoration(
                     labelText: "Postcode",
                     labelStyle: TextStyle(color: Colors.lime),
                     border: new OutlineInputBorder(
                         borderRadius: new BorderRadius.circular(25.0),
                         borderSide: new BorderSide()
                     ),),
                   textAlign: TextAlign.center,
                   style: TextStyle(color: Colors.black26, fontSize: 16.0),
                   controller: postcodeController,
                   validator: (value){
                     if(value.isEmpty){
                       return 'Please enter Postcode';
                     }
                     return null;
                   },
                 ),
               ),

               Container(
                 padding: EdgeInsets.all(12),
                 width: 100,
                 height: 200 ,
                 child:TextFormField(
                     keyboardType: TextInputType.multiline,
                     maxLines: null,
                     expands: true,
                     textInputAction: TextInputAction.newline,
                     decoration: InputDecoration(

                       labelText: "Detail",
                       labelStyle: TextStyle(color: Colors.lime),
                       border: new OutlineInputBorder(
                           borderRadius: new BorderRadius.circular(25.0),
                           borderSide: new BorderSide()
                       ),),
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.black26, fontSize: 16.0),
                     controller: detailController,
                     validator: (value){
                       if(value.isEmpty){
                         return 'Please enter Detail';
                       }
                       return null;
                     }
                 ),
               ),

               MyStatefulWidget(),
               Padding(padding:EdgeInsets.all(5.0) ),
               RaisedButton(
                 color: Colors.lime,
                 textColor: Colors.black,
                 onPressed: ()=>{
                   setState(() {
                     _selectDate();
                     if(dcondition==true){dcondition=false;}else{dcondition=true;}
                   })
                 },

                 child: Text('Date Picker'),
               ),
               Padding(padding:EdgeInsets.all(5.0) ),
               Text(
                 newDate,
                 style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18 ),
                 textAlign: TextAlign.center,
               ),
               Padding(padding:EdgeInsets.all(5.0) ),
               RaisedButton(
                 color: Colors.lime,
                 textColor: Colors.black,
                 onPressed: ()=>{
                   setState(() {
                     if(tcondition==true){tcondition=false;}else{tcondition=true;}
                     print(tcondition);
                   })
                 },
                 child: Text('Time Picker'),
               ),
               if(tcondition==true) TimeRange(
                 fromTitle: Text('From', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black26),),
                 toTitle: Text('To', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black26),),
                 titlePadding: 20,
                 textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.lightGreen),
                 activeTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                 borderColor: Colors.black26,
                 backgroundColor: Colors.transparent,
                 activeBackgroundColor: Colors.lime,
                 firstTime: TimeOfDay(hour: 6, minute: 00),
                 lastTime: TimeOfDay(hour: 20, minute: 00),
                 timeStep: 30,
                 timeBlock: 30,
                 onRangeCompleted: (range) => setState(() => {
                   start=range.start.hour.toString()+":"+range.start.minute.toString(),
                   end= range.end.hour.toString()+":"+range.end.minute.toString(),
                   tvisibility=true
                 }
                 ),
               ),

               Visibility(
                   visible: tvisibility,
                   child:Container(
                     padding: EdgeInsets.all(10.0),
                     child: Text(
                       'From:'+start+" To:"+ end,
                       style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18 ),
                       textAlign: TextAlign.center,


                     ),)
               ),
               Padding(padding:EdgeInsets.all(10.0)),
        Container(
          child: GestureDetector(
            onTap: () {
              _showPicker(context);
            },
              child:Center(
                child:Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(0)),
                width: 150,
                height: 200,
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.grey[800],
                ),
              ),)
            ),
           ),

               Padding(padding:EdgeInsets.all(10.0) ),
               filelist.isNotEmpty?pictureSection:Container(),
               Padding(padding:EdgeInsets.all(10.0) ),
              Align(
                 alignment: Alignment.center,
                 child: ElevatedButton(
                     child: Text('Add my profile'),
                     style: ElevatedButton.styleFrom(
                       primary: Colors.lime,
                       padding: EdgeInsets.all(15.0),
                       textStyle: TextStyle(
                         color: Colors.white,
                         fontSize: 20,
                         //fontStyle: FontStyle.normal
                       ),
                     ),
                     onPressed: () {
                       _showMyDialog();
                     }),
               ),
               Padding(padding:EdgeInsets.all(10.0) ),

             ],
           )),
     )
   );

  }


  /// Get from gallery
  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50
    );
    setState(() {
      _image = image;
      filelist.add(_image);
    });

  }

  _imgFromGallery() async {
    File image = await  ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50
    );
      setState(() {
        _image = image;
        filelist.add(_image);
    });


  }

  ////////////////
  uploadFiles(List _images) async {
    try{
    var imageUrls = await Future.wait(_images.map((_image) =>
        uploadFileList(_image)));

    setState(() {
      this.imageUrls=imageUrls;
    });
    print("1");
    await _handleNewItemEntry();
    await  addNewTodo(nameController.text,phoneController.text,postcodeController.text,detailController.text,sports,newDate,'From:'+start+" To:"+ end,filestring);
    }on firebase_storage.FirebaseException catch (e){
      e.code == 'canceled';
    }
  }


  Future<String> uploadFileList(File _image) async {

    try {
     await firebase_storage.FirebaseStorage.instance
          .ref('uploads/'+_image.toString())
          .child('posts/${Path.basename(_image.path)}').putFile(_image);
      print("Picture uploaded");
     return await firebase_storage.FirebaseStorage.instance
          .ref('uploads/'+_image.toString())
          .getDownloadURL();

    } on firebase_storage.FirebaseException catch (e) {
         e.code == 'canceled';
    }

  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }


  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Approve'),
              onPressed: () {
                if(photos()==true)uploadFiles(filelist);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


}














/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget() : super();

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}
var sport='';
List<String> sportlist=new List<String>();
/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  //SingingCharacter _character = SingingCharacter.lafayette;
  bool _isBadmintonChecked = false;
  bool _isBasketballChecked = false;
  bool _isBaseballChecked = false;
  bool _isTennisChecked= false;
  bool _isPickballChecked= false;
  bool _isSoccerChecked =false;
  bool _isTabletennisChecked= false;



  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
    CheckboxListTile(
    title: const Text('Badminton'),
  //  subtitle: const Text('A programming blog'),
    secondary: const Icon(Icons.sports_tennis),
    activeColor: Colors.lime,
    checkColor: Colors.black26,
    selected: _isBadmintonChecked,
    value: _isBadmintonChecked,
    onChanged: (bool value) {
    setState(() {
      _isBadmintonChecked = value;
      value==true?sportlist.add('Badminton'):sportlist.remove('Badminton');
    });
    },
    ),
    CheckboxListTile(
    title: const Text('Basketball'),
    //  subtitle: const Text('A programming blog'),
    secondary: const Icon(Icons.sports_basketball),
    activeColor: Colors.lime,
    checkColor: Colors.black26,
    selected: _isBasketballChecked,
    value: _isBasketballChecked,
    onChanged: (bool value) {
    setState(() {
      _isBasketballChecked = value;
      value==true?sportlist.add('Basketball'):sportlist.remove('Basketball');
      print(sportlist);
    });
    },
    ),
    CheckboxListTile(
    title: const Text('Baseball'),
    //  subtitle: const Text('A programming blog'),
    secondary: const Icon(Icons.sports_baseball),
    activeColor: Colors.lime,
    checkColor: Colors.black26,
    selected:_isBaseballChecked,
    value: _isBaseballChecked,
    onChanged: (bool value) {
    setState(() {
      _isBaseballChecked = value;
      value==true?sportlist.add('Baseball'):sportlist.remove('Baseball');
      print(sportlist);
    });
    },
    ),
        CheckboxListTile(
          title: const Text('Tennis'),
          //  subtitle: const Text('A programming blog'),
          secondary: const Icon(Icons.sports_tennis),
          activeColor: Colors.lime,
          checkColor: Colors.black26,
          selected: _isTennisChecked,
          value: _isTennisChecked,
          onChanged: (bool value) {
            setState(() {
              _isTennisChecked = value;
              value==true?sportlist.add('Tennis'):sportlist.remove('Tennis');
              print(sportlist);
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Pick Ball'),
          //  subtitle: const Text('A programming blog'),
          secondary: const Icon(Icons.sports_cricket),
          activeColor: Colors.lime,
          checkColor: Colors.black26,
          selected: _isPickballChecked,
          value: _isPickballChecked,
          onChanged: (bool value) {
            setState(() {
              _isPickballChecked = value;
              value==true?sportlist.add('Pickball'):sportlist.remove('Pickball');
              print(sportlist);
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Table Tennis'),
          //  subtitle: const Text('A programming blog'),
          secondary: const Icon(Icons.sports_tennis),
          activeColor: Colors.lime,
          checkColor: Colors.black26,
          selected: _isTabletennisChecked,
          value: _isTabletennisChecked,
          onChanged: (bool value) {
            setState(() {
              _isTabletennisChecked = value;
              value==true?sportlist.add('Table Tennis'):sportlist.remove('Table Tennis');
              print(sportlist);
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Soccer'),
          //  subtitle: const Text('A programming blog'),
          secondary: const Icon(Icons.sports_soccer),
          activeColor: Colors.lime,
          checkColor: Colors.black26,
          selected: _isSoccerChecked,
          value: _isSoccerChecked,
          onChanged: (bool value) {
            setState(() {
              _isSoccerChecked = value;
              value==true?sportlist.add('Soccer'):sportlist.remove('Soccer');
              print(sportlist);
            });
          },
        ),
      ],
    );
  }
}



// A widget that displays the picture taken by the user.
