import 'package:firebase_database/firebase_database.dart';

class TrackingService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<Map<dynamic, dynamic>> getTrackingStatus() async {
    final snapshot = await _database.child('orders').get();
    if (snapshot.exists) {
      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
      return data;
    } else {
      return {
        "orderReceived": false,
        "inTransit": false,
        "outForDelivery": false,
        "delivered": false,
      };
    }
  }
}