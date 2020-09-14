import 'dart:math' as Math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

double calculateDistanceBetweenTwoCoordinates(LatLng l1, LatLng l2) {
  var p = 0.017453292519943295; // Math.PI / 180
  var c = Math.cos;
  double a = 0.5 -
      c((l2.latitude - l1?.latitude) * p) / 2 +
      c(l1.latitude * p) *
          c(l2.latitude * p) *
          (1 - c((l2.longitude - l1?.longitude) * p)) /
          2;

  return 12742 * Math.asin(Math.sqrt(a));

/*
  List<LatLng> list =
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
