import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../helper/utility.dart';
import 'Order.dart';
import 'TrackingService.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class deliveryPage extends StatefulWidget {
  final Order order;
  const deliveryPage({required this.order});

  @override
  State<StatefulWidget> createState() => _deliveryPageState();
}

class _deliveryPageState extends State<deliveryPage>
    with SingleTickerProviderStateMixin {
  late Order? tempModel = widget.order;

  late final Completer<GoogleMapController> _controller = Completer();
  Location _location = Location();
  LatLng _currentLocation = LatLng(0, 0);

  Future<void> _getUserLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await _location.getLocation();
    setState(() {
      _currentLocation = LatLng(_locationData.latitude!, _locationData.longitude!);
    });
    final GoogleMapController _mapController = await _controller.future;
    _location.onLocationChanged.listen((LocationData currentLocation) {
      _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          zoom: 15.0,
        ),
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    _getStatusFromFirebase();
    _getUserLocation();
    getParentModel();
  }

  Future<void> _getStatusFromFirebase() async {
    TrackingService trackingService = TrackingService();
    final status = await trackingService.getTrackingStatus();
    setState(() {
    });
    await _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Tracking'),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future(() {
            setState(() {
              getParentModel();
            });
          });
        },
        child:FutureBuilder(
              future:
              getParentModel(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  // Future hasn't finished yet, return a placeholder
                  return const Center(child: CircularProgressIndicator());}
                else {
                  if (snapshot.hasData) {
                    Order? tempOrder = snapshot.data as Order?;
                    return ListView(
                      shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildTimelineTile(
                                    'Order Received', tempOrder!.isShipped),
                                _buildConnector(),
                                _buildTimelineTile(
                                    'In Transit', tempOrder.isTransit),
                                _buildConnector(),
                                _buildTimelineTile(
                                    'Out for Delivery', tempOrder.isOutForDelivery),
                                _buildConnector(),
                                _buildTimelineTile(
                                    'Delivered', tempOrder.isDelivered),
                              ],
                            ),
                          ),
                          Container(
                            width: 200,
                            height: 400,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: _currentLocation,
                                zoom: 15,
                              ),
                              onMapCreated: (GoogleMapController controller) {
                                _controller.complete(controller);
                              },
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                            ),
                          ),
                        ]);
                  }
                  else {
                    return Container();
                  }
                }
              }
          ),)
    );
  }

  Widget _buildTimelineTile(String title, bool isCompleted) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isCompleted ? Colors.orange : Colors.grey, width: 2),
                color: isCompleted ? Colors.orange : Colors.white,
              ),
              child: isCompleted
                  ? Icon(Icons.check, color: Colors.white, size: 16)
                  : SizedBox.shrink(),
            ),
          ],
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: isCompleted ? Colors.orange : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnector() {
    return Align(alignment: Alignment.centerLeft,
        child: Container(
      margin: EdgeInsets.only(left: 2),
      height: 50,
      child: VerticalDivider(
        color: Colors.orange,
        thickness: 2,
        width: 20,
      ),
    )
      );
  }

  Future<Order?> getParentModel() async {
    Order? _tweetDetail;
    var model = await kDatabase.child('orders').child(widget.order.id!).once().then(
            (DatabaseEvent event) {
          final snapshot = event.snapshot;
          if (snapshot.value != null) {
            var map = snapshot.value as Map<dynamic, dynamic>;
            _tweetDetail = Order.fromJson(map);
          }
        });
        if (model != null) {
          _tweetDetail = model;
          cprint("Fetched good value from  DB");
        } else {
        cprint("Fetched null value from  DB");
        }
      //final orderData = await kDatabase.child('orders').child(widget.order.id!).get() as Map<dynamic, dynamic>;
    //_tweetDetail = model;
    tempModel = _tweetDetail;
    return tempModel;

  }
}
