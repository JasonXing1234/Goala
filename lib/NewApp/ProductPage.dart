import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/user.dart';
import '../state/authState.dart';

class ProductPage extends StatefulWidget {
  @override
  _GridViewPageState createState() => _GridViewPageState();
}

class _GridViewPageState extends State<ProductPage> {
  // Sample data for the grid view tiles
  final List<Map<String, String>> gridItems = [
    {'title': 'Title 1', 'image': 'assets/images/Backhoe.jpeg'},
    {'title': 'Title 2', 'image': 'assets/images/Dozer.jpeg'},
    {'title': 'Title 3', 'image': 'assets/images/Excavator.jpeg'},
    {'title': 'Title 4', 'image': 'assets/images/Grader.jpeg'},
    {'title': 'Title 5', 'image': 'assets/images/SkidSteer.jpeg'},
    {'title': 'Title 6', 'image': 'assets/images/TrackLoader.jpeg'},
    {'title': 'Title 7', 'image': 'assets/images/Truck.jpeg'},
    {'title': 'Title 8', 'image': 'assets/images/WheelLoader.jpeg'},
  ];

  // List to track the clicked state of each button
  List<bool> _buttonClicked = List.generate(8, (_) => false);


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Equipments'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of tiles per row
            crossAxisSpacing: 8.0, // Space between columns
            mainAxisSpacing: 8.0, // Space between rows
            childAspectRatio: 3 / 4, // Aspect ratio of the tiles
          ),
          itemCount: gridItems.length,
          itemBuilder: (context, index) {
            return _buildGridTile(gridItems[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildGridTile(Map<String, String> item, int index) {
    var state = Provider.of<AuthState>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Stack(
        children: [
          // Title at the bottom left
          Positioned(
            bottom: 8.0,
            left: 8.0,
            child: Text(
              item['title']!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.black54,
              ),
            ),
          ),
          // Button at the bottom right
          Positioned(
            bottom: 8.0,
            right: 8.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: state.userModel!.equipmentList!.contains(index) ? Colors.green : Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () async {
                final DatabaseReference tempDatabase = FirebaseDatabase.instance.ref();
                var state = Provider.of<AuthState>(context, listen: false);
                var event = await tempDatabase.child('profile').child(state.userModel!.userId!).once();

                final map = event.snapshot.value as Map?;
                UserModel tempModel = UserModel.fromJson(map);
                List<String> tempList = tempModel.equipmentList!;
                tempList.add(index.toString());
                tempDatabase
                    .child('profile')
                    .child(tempModel.userId!)
                    .child('equipmentList')
                    .set(tempList);

                final orderId = tempDatabase.child('orders').push().key;
                final order = {
                  'isShipped': false,
                  'isTransit': false,
                  'isOutForDelivery': false,
                  'isDelivered': false,
                  'orderID': orderId,
                  'title': item['title'],
                  'customerID': tempModel.userId,
                  'photoUrl': 'https://via.placeholder.com/150',
                  'instruction': 'N/A',
                  'deviceToken': state.userModel!.deviceToken,
                  'userName': state.userModel!.displayName
                };

                await tempDatabase.child('orders/$orderId').set(order);
                setState(() {
                  _buttonClicked[index] = true; // Change state to indicate button is clicked
                });
              },
              child: Text(
                state.userModel!.equipmentList!.contains(index) ? 'Clicked' : 'Click Me',
                style: TextStyle(
                  color: state.userModel!.equipmentList!.contains(index) ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          Image.asset(item['image']!)
        ],
      ),
    );
  }
}
