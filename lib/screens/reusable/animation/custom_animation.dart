import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomAnimation {
  static final fadingCircle = SpinKitFadingCircle(
    itemBuilder: (_, int index) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: index.isEven ? Colors.red : Colors.green,
        ),
      );
    },
  );

  static final spinKitWaveMiddleRed = SpinKitWave(
    color: Colors.blue[300],
    type: SpinKitWaveType.center,
    size: 100,
  );
  static final spinKitWave = Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      SpinKitWave(color: Colors.white, type: SpinKitWaveType.start),
      SpinKitWave(color: Colors.white, type: SpinKitWaveType.center),
      SpinKitWave(color: Colors.white, type: SpinKitWaveType.end),
    ],
  );

  static final spinKitFadingFour =
      SpinKitFadingFour(color: Colors.white, shape: BoxShape.rectangle);
}
