import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'Order.dart';

class updateOrderStatusPage extends StatefulWidget {
  final Order order;

  updateOrderStatusPage({required this.order});

  @override
  _OrderChecklistPageState createState() => _OrderChecklistPageState();
}

class _OrderChecklistPageState extends State<updateOrderStatusPage> {
  final _database = FirebaseDatabase.instance.reference();
  final _storage = FirebaseStorage.instance;
  bool checkBox1 = false;
  bool checkBox2 = false;
  bool checkBox3 = false;
  bool checkBox4 = false;
  bool showAdditionalFields = false;
  String? description;
  XFile? image;


  @override
  void initState() {
    super.initState();
    _loadCheckboxStates();
  }

  void _loadCheckboxStates() async {
    DataSnapshot snapshot = await _database.child('orders/${widget.order.id}').get();
    if (snapshot.exists) {
      final orderData = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        checkBox1 = orderData['isShipped'] ?? false;
        checkBox2 = orderData['isTransit'] ?? false;
        checkBox3 = orderData['isOutForDelivery'] ?? false;
        checkBox4 = orderData['isDelivered'] ?? false;
        showAdditionalFields = checkBox4;
      });
    }
  }

  void _updateCheckboxState(int index, bool value) {
    setState(() {
      switch (index) {
        case 1:
          checkBox1 = value;
          _database.child('orders/${widget.order.id}/isShipped').set(value);
          break;
        case 2:
          checkBox2 = value;
          _database.child('orders/${widget.order.id}/isTransit').set(value);
          break;
        case 3:
          checkBox3 = value;
          _database.child('orders/${widget.order.id}/isOutForDelivery').set(value);
          break;
        case 4:
          checkBox4 = value;
          showAdditionalFields = value;
          _database.child('orders/${widget.order.id}/isDelivered').set(value);
          break;
      }
    });
  }

  Future<void> _onPressPoke(String? token, String? displayName) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
          'key=AAAAv0Rlcww:APA91bElZKaKqCu2rk6NTlubBQ93BGfB_RVbT-Gn89tgrirBzXcXt1EZpFulH2OjsTymUul9LfXnlrTdHOiab_cuwajAcvbrxWpd9P8z-9W4Ppb093v2b9v-0TCSAUf5At91l8Ybu9SK'
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': 'Goala',
              'title': '${displayName} poked you!',
            },
            "notification": <String, dynamic>{
              'title': 'Goala',
              'body': '${displayName} poked you!',
              'android_channel_id': 'dbfood'
            },
            "to": token,
          },
        ),
      );
      print('good');
    } catch (e) {
      print('error');
    }
    var state = Provider.of<FeedState>(context, listen: false);
    state.addPokeNoti(tempModel!, displayName!);
    /*try {
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendPokeNotification');
      final result = await callable.call({
        "data": {
          'token': token,
          'user': displayName
        }
      });
      print('Function result: ${result.data}');
    } on FirebaseFunctionsException catch (e) {
      print(e);
    }*/
  }

  Future<void> _submitData() async {
    if (description != null && description!.isNotEmpty && image != null) {
      // Upload the image to Firebase Storage
      final File imageFile = File(image!.path);
      final String imageFileName = 'orders/${widget.order.id}/${DateTime.now().millisecondsSinceEpoch}.png';
      final Reference storageRef = _storage.ref().child(imageFileName);
      final UploadTask uploadTask = storageRef.putFile(imageFile);

      // Get the download URL of the uploaded image
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      final String imageUrl = await snapshot.ref.getDownloadURL();

      // Save description and image URL to Firebase Database
      _database.child('orders/${widget.order.id}/instruction').set(description);
      _database.child('orders/${widget.order.id}/photoUrl').set(imageUrl);

      // Show a success message or handle any post-submit logic
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data submitted successfully!')));
    } else {
      // Show an error message if description or image is missing
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please provide a description and an image.')));
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = pickedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Checklist'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CheckboxListTile(
              title: Text('Order Received'),
              value: checkBox1,
              onChanged: (bool? value) {
                if (value != null) _updateCheckboxState(1, value);
              },
            ),
            CheckboxListTile(
              title: Text('In Transit'),
              value: checkBox2,
              onChanged: (bool? value) {
                if (value != null) _updateCheckboxState(2, value);
                _onPressPoke(widget.order.deviceToken, widget.order.userName);
              },
            ),
            CheckboxListTile(
              title: Text('Out For Delivery'),
              value: checkBox3,
              onChanged: (bool? value) {
                if (value != null) _updateCheckboxState(3, value);
              },
            ),
            CheckboxListTile(
              title: Text('Delivered'),
              value: checkBox4,
              onChanged: (bool? value) {
                if (value != null) _updateCheckboxState(4, value);
              },
            ),
            if (showAdditionalFields) ...[
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (text) {
                  setState(() {
                    description = text;
                  });
                },
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              if (image != null)
                Image.file(
                  File(image!.path),
                  height: 100,
                  width: 100,
                ),
              ElevatedButton(
                onPressed: _submitData,
                child: Text('Submit'),
              ),
            ],
              ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}