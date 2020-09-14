import 'dart:convert';
import 'dart:math' as Math;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uber_clone/files/json_sample.dart';
import 'package:uber_clone/models/search_place.dart';
import 'package:uber_clone/models/search_suggestion.dart';
import 'package:uber_clone/utils/distance_calculator.dart';

const _googleRouteKey = "AIzaSyCFm47UjymATQWyde9mVp9R_FWiaf68B-c";
const _googlePlaceKey = "AIzaSyBEIn6FzWN0wgsPpVCteAL0Ag-vMZSbIEA";

class GoogleMapsServices {
  Future<String> getRouteCoordinates(LatLng l1, LatLng l2) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$_googleRouteKey";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    return values["routes"][0]["overview_polyline"]["points"];
  }

  Future<List<LatLng>> getRouteCoordinatesFromMapBox(
      LatLng l1, LatLng l2) async {
    String url =
        "https://api.mapbox.com/directions/v5/mapbox/driving/${l1.longitude},${l1.latitude};${l2.longitude},${l2.latitude}?geometries=geojson&access_token=pk.eyJ1IjoiYWRoaWthcmktbWl0aHVuIiwiYSI6ImNqeWU5MzZ6bjB6YXozbnM1YWcxdW1nNmoifQ.HrgzxoSLBUjpdiMIS0Kusg";
    http.Response response = await http.get(url);

    Map values = jsonDecode(response.body);

    List<dynamic> other =
        values["routes"][0]["geometry"]["coordinates"] as List<dynamic>;

    List<LatLng> list = [];

    other?.forEach((val) {
      if (val != null) list.add((LatLng(val[1], val[0])));
    });

    return list;
  }

  Future<List<SearchSuggestion>> getSearchSuggestions(
      String text, LatLng currentLocation) async {
    List<SearchPlaces> _searchPlaceFromText = await getSearchedPlaces(text);

    List<SearchSuggestion> _sug = [];

    _searchPlaceFromText.forEach((SearchPlaces place) {
      double distance = double.parse(
          getCollectiveDistance(currentLocation, LatLng(place.lat, place.lon))
              .toStringAsFixed(2));
      /* print(
          "The current location is $currentLocation and the place is ${LatLng(place.lat, place.lon)}"
              "and the distance we got is $distance");*/

      final index = place.formattedAddress.toLowerCase().
      indexOf(text.toLowerCase())+ text.length;
      final realAddress = place.formattedAddress;
      SearchSuggestion suggestion = SearchSuggestion(
          id: place.id,
          address: place.address,
          formattedAddress: realAddress,
          distance: distance,
          matchedText: realAddress.substring(0,index),
          remainingText: realAddress.substring(index),
          icon: place.icon);

      if (suggestion != null) _sug.add(suggestion);
    });

    print("The list size from the google api ${_sug.length}");
    return _sug;
  }

  Future<List<SearchPlaces>> getSearchedPlaces(String text) async {
    //todo replace this line with the real api search results next line of course
    Map<String, dynamic> map = getJsonSampleForSatdobato();
    List<SearchPlaces> list = [];
    print("The map from the search is ${map["results"]}");

    map["results"].forEach((json) {
      SearchPlaces places = SearchPlaces.fromJson(json);
      if (places != null) list.add(places);
    });
    return list;
  }

  double getDistaceBetweenCoordinates(LatLng l1, LatLng l2) {}

  double getCollectiveDistance(LatLng currentLocation, LatLng latLng) {
    return calculateDistanceBetweenTwoCoordinates(currentLocation, latLng);

    var p = 0.017453292519943295; // Math.PI / 180
    var c = Math.cos;
    double a = 0.5 -
        c((latLng.latitude - currentLocation?.latitude) * p) / 2 +
        c(currentLocation.latitude * p) *
            c(latLng.latitude * p) *
            (1 - c((latLng.longitude - currentLocation?.longitude) * p)) /
            2;

    return 12742 * Math.asin(Math.sqrt(a));

    /*List<LatLng> list =
        await getRouteCoordinatesFromMapBox(currentLocation, latLng);

    double distance = 0.0;

    list.reduce((LatLng firstVal, LatLng nextVal) {
      if (firstVal != null && nextVal != null) {
        var p = 0.017453292519943295; // Math.PI / 180
        var c = Math.cos;
        double a = 0.5 -
            c((nextVal.latitude - firstVal?.latitude) * p) / 2 +
            c(firstVal.latitude * p) *
                c(nextVal.latitude * p) *
                (1 - c((nextVal.longitude - firstVal?.longitude) * p)) /
                2;

        distance += 12742 * Math.asin(Math.sqrt(a));
      }
    });
    return distance;*/
  }
}
