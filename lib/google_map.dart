import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:sportsmate/ItemDetail.dart';
import 'package:sportsmate/NewItemForm.dart';
import 'package:sportsmate/PlaceDetail.dart';

import 'authentication.dart';


const kGoogleApiKey = "AIzaSyBDz7bxf0Z328v_1OjGNC7T3kTv8vxe42Q";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);


class Home extends StatefulWidget {
  Home({Key key,this.sportlist,this.auth,this.logoutCallback,this.userId, this.title}) : super(key:key);
 final String sportlist;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String title;
  final String userId;
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController mapController;
  List<PlacesSearchResult> places = [];
  bool isLoading = false;
  String errorMessage;
  var homeaddress=new LatLng(0, 0);
  bool checkBoxValue=false;
  @override
  Widget build(BuildContext context) {
    Widget expandedChild;
    if (isLoading) {
      expandedChild = Center(child: CircularProgressIndicator(value: null));
    } else if (errorMessage != null) {
      expandedChild = Center(
        child: Text(errorMessage),
      );
    } else {
      expandedChild = buildPlacesList();
    }

    return Scaffold(
        key: homeScaffoldKey,
        appBar: AppBar(
          title: const Text("Recreation Center Near You"),
          actions: <Widget>[
            isLoading
                ? IconButton(
              icon: Icon(Icons.timer),
              onPressed: () {},
            )
                : IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                refresh();
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                _handlePressButton();
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Container(
              child: SizedBox(
                  height: 350.0,
                  child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      options: GoogleMapOptions(
                          myLocationEnabled: true,
                          cameraPosition:
                          const CameraPosition(target: LatLng(0.0, 0.0))))),
            ),
            Expanded(child: expandedChild)
          ],
        ));
  }

  void refresh() async {
    final center = await getUserLocation();

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: center == null ? LatLng(0, 0) : center, zoom: 15.0)));
    getNearbyPlaces(center);
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    refresh();
  }

  Future<LatLng> getUserLocation() async {
    var currentLocation = <String, double>{};
    final location = await LocationManager.Location().getLocation();
    try {

      final lat = location.latitude;
      final lng = location.longitude;
      final center = LatLng(lat, lng);
      homeaddress=center;
      return center;
    } on Exception {
      currentLocation = null;
      return null;
    }
  }

  void getNearbyPlaces(LatLng center) async {
    setState(() {
      this.isLoading = true;
      this.errorMessage = null;
    });

    final location = Location(center.latitude, center.longitude);
    final result = await _places.searchNearbyWithRadius(location, 5000,keyword: "Park");
    final result2=await _places.searchNearbyWithRadius(location, 5000,keyword: "Recreation");
    setState(() {
      this.isLoading = false;
      if (result.status == "OK") {

        this.places = result2.results+result.results;
        result.results.forEach((f) {
          final markerOptions = MarkerOptions(
              position:
              LatLng(f.geometry.location.lat, f.geometry.location.lng),
              infoWindowText: InfoWindowText("${f.name}", "${f.types?.first}"));
          mapController.addMarker(markerOptions);
        });
      } else {
        this.errorMessage = result.errorMessage;
      }
    });
  }

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  Future<void> _handlePressButton() async {
    try {
      final center = await getUserLocation();
      Prediction p = await PlacesAutocomplete.show(
          context: context,
          strictbounds: center == null ? false : true,
          apiKey: kGoogleApiKey,
          onError: onError,
          mode: Mode.fullscreen,
          language: "en",
          location: center == null
              ? null
              : Location(center.latitude, center.longitude),
          radius: center == null ? null : 10000);

      showDetailPlace(p.placeId);
    } catch (e) {
      return;
    }
  }

  Future<Null> showDetailPlace(String placeId) async {
    if (placeId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlaceDetailWidget(title:widget.title,placeId:placeId,auth:widget.auth,userId:widget.userId,logoutCallback:widget.logoutCallback)),
      );
    }
  }

  ListView buildPlacesList() {
    final placesWidget = places.map((f) {
      List<Widget> list = [
        Padding(
          padding: EdgeInsets.only(bottom: 4.0),
          child: Text(
            f.name,
            style: Theme.of(context).textTheme.subtitle,
          ),
        )
      ];


      if (f.formattedAddress != null) {
        list.add(
            Padding(
                padding: EdgeInsets.only(bottom: 4.0),
            child: Text(f.formattedAddress)
              )
        );
      }

      if (f.vicinity != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child:Text(
            f.vicinity,
            style: Theme.of(context).textTheme.body1,
          ),
        ));
      }



      if (f.types?.first != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            f.types.contains("gym")?"gym":f.types.contains("park")?"park":"health",

            style: Theme.of(context).textTheme.caption,
          ),
        ));
      }

      // show the dialog



      if (f.types?.first != null) {
        double distanceInMeters = Geolocator.distanceBetween(homeaddress.latitude, homeaddress.longitude ,f.geometry.location.lat, f.geometry.location.lng);
        double distanceInMiles=(distanceInMeters/1600).roundToDouble();
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text("Distance to you Location:  "+distanceInMiles.toString()+"  miles")
        ));
      }







      return Padding(
        padding: EdgeInsets.only(top: 4.0, bottom: 4.0, left: 8.0, right: 8.0),
        child: Card(
          child: InkWell(
            onTap: () {
              showDetailPlace(f.placeId);
            },
            highlightColor: Colors.lightBlueAccent,
            splashColor: Colors.red,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: list,
              ),
            ),
          ),
        ),
      );
    }).toList();

    return ListView(shrinkWrap: true, children: placesWidget);
  }
}