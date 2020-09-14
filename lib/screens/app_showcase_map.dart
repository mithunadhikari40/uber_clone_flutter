import 'dart:async';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as Location;
import 'package:uber_clone/models/search_suggestion.dart';
import 'package:uber_clone/screens/reusable/animation/custom_animation.dart';
import 'package:uber_clone/screens/reusable/auto_complete_text_view.dart';
import 'package:uber_clone/utils/distance_calculator.dart';
import 'package:uber_clone/utils/firebase_realtime_db_transaction.dart';
import 'package:uber_clone/utils/google_maps_requests.dart';

class AppShowCaseMap extends StatefulWidget {
  @override
  _AppShowCaseMapState createState() => _AppShowCaseMapState();
}

class _AppShowCaseMapState extends State<AppShowCaseMap> {
  GoogleMapController mapController;
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();

  Completer<GoogleMapController> _completer = Completer<GoogleMapController>();
  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  GlobalKey<AutoCompleteTextFieldState<SearchSuggestion>> _destinationKey =
      GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<SearchSuggestion>> _pickupKey =
      GlobalKey();

  GlobalKey _mapKey = GlobalKey();

  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  Set<Marker> _markers = {};

  final Set<Polyline> _polyLines = {};

  List<SearchSuggestion> _suggestions = [];
  String _selectedLocation;

  AutoCompleteTextView _autoCompleteTextView;
  var doubleRE = RegExp(r"-?(?:\d*\.)?\d+(?:[eE][+-]?\d+)?", multiLine: true);

  Location.Location _location = Location.Location();

  Firestore _fireStore = Firestore.instance;
  Geoflutterfire _geoFlutterFire = Geoflutterfire();

  FireBaseRealTimeDbTransaction _fireBaseRealTimeDbTransaction =
      FireBaseRealTimeDbTransaction();

  @override
  void initState() {
    super.initState();
    _getUserLocation();

    _fireBaseRealTimeDbTransaction.initState();
    _fireBaseRealTimeDbTransaction.getDbReference.onValue.listen((Event event) {
      DataSnapshot snapshot = event.snapshot;
      var data = snapshot.value;
      print("The real time real thing data are $data");
    });

    // _location
    //     .onLocationChanged(
    //     .listen((Location.LocationData currentLocation) {
    //   _updateLocation(currentLocation);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return _initialPosition == null
        ? Container(
            alignment: Alignment.center,
            child: Center(
              child: CustomAnimation.spinKitWaveMiddleRed,
            ),
          )
        : Stack(
            children: <Widget>[
              buildGoogleMap(),
              buildPickUpLocationTextField(),
              buildDestinationTextField(),
              buildUpdateMapSection(),
            ],
          );
  }

  Positioned buildUpdateMapSection() {
    return Positioned(
      bottom: 15.0,
      right: 15.0,
      child: Padding(
          child: FlatButton.icon(
            onPressed: () {
              updateMap();
            },
            icon: Icon(Icons.update),
            label: Text('+'),
          ),
          padding: EdgeInsets.all(8.0)),
    );
  }

  Positioned buildDestinationTextField() {
    return Positioned(
      top: 105.0,
      right: 15.0,
      left: 15.0,
      child: Container(
        width: double.infinity,
        height: 60,
        margin: EdgeInsets.only(top: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.0),
          color: Colors.white,
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                  child: new Container(
                      child: getDestinationAutoCompleteTextView()),
                  padding: EdgeInsets.all(8.0)),
            ),
          ],
        ),
      ),
    );
  }

  Positioned buildPickUpLocationTextField() {
    return Positioned(
      top: 50.0,
      right: 15.0,
      left: 15.0,
      child: Container(
        height: 60.0,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey,
                offset: Offset(1.0, 5.0),
                blurRadius: 10,
                spreadRadius: 3)
          ],
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                  child: Container(child: getPickupAutoCompleteTextView()),
                  padding: EdgeInsets.all(8.0)),
            ),
          ],
        ),
      ),
    );
  }

  GoogleMap buildGoogleMap() {
    return GoogleMap(
      key: _mapKey,
      initialCameraPosition:
          CameraPosition(target: _initialPosition, zoom: 16.0),
      onMapCreated: onCreated,
      myLocationEnabled: true,
      onTap: _onMapTap,
      mapType: MapType.normal,
      compassEnabled: true,
      markers: _markers,
      onCameraMove: _onCameraMove,
      polylines: _polyLines,
    );
  }

  AutoCompleteTextView getDestinationAutoCompleteTextView() {
    _suggestions.clear();
    _autoCompleteTextView = AutoCompleteTextView(
      autoCompleteKey: _destinationKey,
      textSubmitted: (String text) {
        setState(() {

        });
        sendRequest(text);
      },
      onChangeFocus: (bool isFocused){
        if(isFocused && _destinationKey.currentState.currentText==''){
          print("The focus is gained and the text is empty for now");

          addDefaultSuggestions();

        }
      },
      suggestions: _suggestions,
      onItemSubmitted: (SearchSuggestion suggestion) {
        print("The user selected addresss is ${suggestion.address}");


        setState(() {
          _selectedLocation = suggestion.address;
        });
      },
      controller: destinationController,
      textChange: (String text) {
        addSuggestion(text);
      },
      hintText: "Destination?",
    );

    return _autoCompleteTextView;
  }

  AutoCompleteTextView getPickupAutoCompleteTextView() {
    _suggestions.clear();
    _autoCompleteTextView = AutoCompleteTextView(
      autoCompleteKey: _pickupKey,
      textSubmitted: (String text) {
        sendRequest(text);
      },
      onChangeFocus: (bool hasFocus) {
        if (hasFocus) {
          _pickupKey.currentState.focusNode.unfocus();
          _selectPickupLocation();
        }
      },
      suggestions: _suggestions,
      onItemSubmitted: (SearchSuggestion suggestion) {
        Fluttertoast.showToast(msg:"The user wants to go to ${suggestion.address}");
        setState(() {
          _selectedLocation = suggestion.address;
        });
      },
      controller: locationController,
      textChange: (String text) {
//        addSuggestion(text);
      },
      hintText: "Pick up from?",
    );
    return _autoCompleteTextView;
  }

  void onCreated(GoogleMapController controller) {
    _completer.complete(controller);
    setState(() {
      mapController = controller;
    });
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _lastPosition = position.target;
    });
  }

  void _addMarker(LatLng location, String address) {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(_lastPosition.toString()),
          position: location,
          infoWindow: InfoWindow(title: address, snippet: "go here"),
          icon: BitmapDescriptor.defaultMarker));
    });
  }

/*
  void createRoute(String encondedPoly) {
    setState(() {
      _polyLines.add(Polyline(
          polylineId: PolylineId(_lastPosition.toString()),
          width: 10,
          points: convertToLatLng(decodePoly(encondedPoly)),
          color: Colors.black));
    });
  }*/

  void createRoute(List<LatLng> route) {
    setState(() {
      _polyLines.add(Polyline(
          polylineId: PolylineId(_lastPosition.toString()),
          width: 10,
          points: route,
          color: Colors.black));
    });
  }

/*
* [12.12, 312.2, 321.3, 231.4, 234.5, 2342.6, 2341.7, 1321.4]
* (0-------1-------2------3------4------5-------6-------7)
* */

  void _getUserLocation() async {
    bool _isServiceEnabled = await Location.Location().serviceEnabled();
    if (_isServiceEnabled) {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemark = await Geolocator()
          .placemarkFromCoordinates(position.latitude, position.longitude);
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        locationController.text = placemark[0].name;
      });
    } else {
      bool some = await Location.Location().requestService();
      if (some)
        _getUserLocation();
      else
        Fluttertoast.showToast(
          msg: "App could not perform if location is not enabled",
          toastLength: Toast.LENGTH_SHORT,
        );
    }
  }

  void addSuggestions(String text) async {
    List<SearchSuggestion> sugg =
        await GoogleMapsServices().getSearchSuggestions(text, _lastPosition);

    setState(() => _suggestions = sugg);

    _autoCompleteTextView.updateSuggestion(_suggestions);
  }

  void sendRequest(String intendedLocation) async {
    List<Placemark> placemark =
        await Geolocator().placemarkFromAddress(intendedLocation);

    double latitude = placemark[0].position.latitude;
    double longitude = placemark[0].position.longitude;
    LatLng destination = LatLng(latitude, longitude);
    //we got the latitude and longitude
    _addMarker(destination, intendedLocation);
    /*String route = await _googleMapsServices.getRouteCoordinates(_initialPosition, destination);
    createRoute(route);*/
    List<LatLng> route = await _googleMapsServices
        .getRouteCoordinatesFromMapBox(_initialPosition, destination);

    createRoute(route);
  }

  void addSuggestion(String text) async {
    Fluttertoast.showToast(msg: "The user is typing $text");
    List<SearchSuggestion> list =
        await GoogleMapsServices().getSearchSuggestions(text, _initialPosition);
    setState(() => _suggestions = list);
    _autoCompleteTextView.updateSuggestion(_suggestions);
  }

  void _updateLocation(Location.LocationData currentLocation) {
    if (currentLocation != null && _initialPosition != null) {
      double distance = calculateDistanceBetweenTwoCoordinates(_initialPosition,
              LatLng(currentLocation.latitude, currentLocation.longitude)) *
          1000;
      if (distance > 100) {
        setState(() {
          _initialPosition =
              LatLng(currentLocation.latitude, currentLocation.longitude);
        });
      }
    }
  }

  Future<DocumentReference> _addGeoPoint(LatLng location) async {
    try {
      GeoFirePoint _point = _geoFlutterFire.point(
          latitude: location.latitude, longitude: location.longitude);

      return _fireStore
          .collection('locations')
          .add({'position': _point.data, 'name': 'Yay I can be queried'});
    } on Exception catch (e) {
      print("There was an erro while uploading location $e");
      return null;
    }
  }

  addLocationDataToFireBaseRealTimeDb(LatLng location) {
    try {
      GeoFirePoint _point = _geoFlutterFire.point(
          latitude: location.latitude, longitude: location.longitude);
      Map<dynamic, dynamic> data = {
        "position": {
          "latitude": location.latitude,
          "longitude": location.longitude,
          "hash": _point.hash.toString()
        },
        "senderId": "12334567890",
        "receiverId": "0987654321",
      };

      _fireBaseRealTimeDbTransaction.addLocation(data);
    } on Exception catch (e) {
      print("There was an error encountered $e");
    }
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    try {
      setState(() {
        _markers = {};
      });
      Set<Marker> _set = {};
      documentList.forEach((DocumentSnapshot document) {
        GeoPoint pos = document.data['position']['geopoint'];

        double distance = document.data['distance'] as double;

        _set.add(Marker(
            markerId: MarkerId(LatLng(pos.latitude, pos.longitude).toString()),
            position: LatLng(pos.latitude, pos.longitude),
            infoWindow: InfoWindow(title: "Magic marker", snippet: '$distance'),
            icon: BitmapDescriptor.defaultMarker));
      });

      setState(() {
        _markers = _set;
      });
    } on Exception catch (e) {
      print("There was an error while updating the map $e");
    }
  }

  updateMap() async {
    try {
      /*  DatabaseReference a = _fireBaseRealTimeDbTransaction.getDbReference;
      DataSnapshot snapshot = await a.once();
      var data = snapshot.value;
      print("Firebase realtime db is $data");*/

      DatabaseReference db =
          FirebaseDatabase.instance.reference().child('location');

      db.once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        print("The firebase realtime db $values");
      });
    } on Exception catch (e) {
      print("There was an error while fetching data $e");
    }

    /* CollectionReference ref = _fireStore.collection('locations');
    Location.LocationData _location = await Location.Location().getLocation();
    GeoFirePoint center = _geoflutterfire.point(
        latitude: _location.latitude, longitude: _location.longitude);

    _geoflutterfire
        .collection(collectionRef: ref)
        .within(
            center: center, radius: 120.0, field: 'position', strictMode: true)
        .listen((List<DocumentSnapshot> shot) {
      _updateMarkers(shot);
    });*/
  }

  void _onMapTap(LatLng argument) async {
//    DocumentReference reference = await _addGeoPoint(argument);

    addLocationDataToFireBaseRealTimeDb(argument);
  }

  void _onPickupLocationTap() {
    Fluttertoast.showToast(msg: "Clicked");
  }

  void _selectPickupLocation() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext ctx) {
          return Container(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Select pick up location",
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  Text("How would you like us to pick up you"),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey[200],
                            style: BorderStyle.solid,
                            width: 2.0)),
                    width: double.infinity,
                    child: RaisedButton(
                      color: Color.fromRGBO(255, 255, 255, 0.9),
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        "Choose from map",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  Container(
                    width: double.infinity,
                    child: RaisedButton(
                      color: Color.fromARGB(128, 0, 0, 0),
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        "Choose from my address",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  Container(
                    width: double.infinity,
                    child: RaisedButton(
                      color: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        "Search for locations",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void addDefaultSuggestions() {


  }

/*
  void _selectPickupLocation() {
    showModalBottomSheet<void>(

      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Select pickup location",
                style: TextStyle(
                  fontSize: 20.0,
                ),
                textAlign: TextAlign.start,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
              ),
              Text("How would you like to selct your pickup location? "),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.grey[200], style: BorderStyle.solid, width: 2.0),
                ),
                width: double.infinity,
                child: RaisedButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

                  padding: EdgeInsets.all(0.0),
                  color: Color.fromRGBO(255, 255, 255, 0.9),
                  child: Text(
                    "Choose from map",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey[200],
                        style: BorderStyle.solid,
                        width: 2.0)),
                width: double.infinity,
                child: RaisedButton(
                  padding: EdgeInsets.all(0.0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

                  color: Color.fromRGBO(255, 255, 255, 0.9),
                  child: Text(
                    "Choose from my addresses",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey[200],
                        style: BorderStyle.solid,
                        width: 2.0)),
                width: double.infinity,
                child: RaisedButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.all(0.0),
                  color: Color.fromRGBO(255, 255, 255, 0.9),
                  child: Text(
                    "Search for locations",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
*/
}
