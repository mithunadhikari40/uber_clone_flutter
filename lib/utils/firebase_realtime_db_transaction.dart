import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FireBaseRealTimeDbTransaction {
  DatabaseReference _databaseReference;
  StreamSubscription<Event> _subscription;
  FirebaseDatabase database = FirebaseDatabase();
  static final FireBaseRealTimeDbTransaction _instance =
      FireBaseRealTimeDbTransaction._internal();
  Map<dynamic, dynamic> data;

  void dispose() {
    _subscription.cancel();
  }

  FireBaseRealTimeDbTransaction._internal();

  factory FireBaseRealTimeDbTransaction() {
    return _instance;
  }

  void initState() {
    _databaseReference =
        FirebaseDatabase.instance.reference().child('location');

    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(1024 * 100);
    _databaseReference.keepSynced(true);

    _subscription = _databaseReference.onValue.listen((event) {


      data = event.snapshot.value ?? null;
    }, onError: (o) {
      //todo initialize the errror to this value
    });
  }

  Map<dynamic, dynamic> get getData => data;

  addLocation(Map map) async {
    try {
      final TransactionResult _transactionResult = await _databaseReference
          .runTransaction((MutableData mutableData) async {
        mutableData.value = mutableData.value ?? null;
        return mutableData;
      });
      if (_transactionResult.committed) {
        _databaseReference.push().set(<dynamic, dynamic>{
          "position": map["position"],
          "senderId": map["senderId"],
          "receiverId": map["receiverId"],
          "updatedTime": DateTime.now().toString(),
        });
        print("Published to the firebase realtime db");
      } else {
        Fluttertoast.showToast(msg: "Transaction could not be completed");
        DatabaseError some = _transactionResult.error;
        print(
            "Database error message ${some.message} and detail is ${some.details} and the code is ${some.code}");
      }
    } on Exception catch (e) {
      print("Error during the firebase upload to the server $e");
    }
  }

  deleteData(Map data) async {
    String id = data["id"];
    await _databaseReference.child(id).remove();
  }

  updateData(Map data) async {
    await _databaseReference.child(data["id"]).update({
      "position": data["position"],
      "senderId": data["senderId"],
      "receiverId": data["receiverId"],
      "updatedTime": DateTime.now(),
    });
  }

  getRealLiveData(){
    _databaseReference.onValue.listen((event){
      DataSnapshot snapshot = event.snapshot.value;
    });

  }

  DatabaseReference get getDbReference => _databaseReference;

}
