import 'package:Goala/NewApp/NewPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'Order.dart';

class OrderListPage extends StatefulWidget {
  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        String userId = user.uid;
        final ordersRef = _database.child('orders').orderByChild('customerID').equalTo(userId);
        final snapshot = await ordersRef.once();

        if (snapshot.snapshot.value != null) {
          final ordersData = snapshot.snapshot.value as Map<dynamic, dynamic>;
          final List<Order> orders = [];

          ordersData.forEach((orderId, orderData) {
            final orderMap = Map<String, dynamic>.from(orderData as Map);
            orders.add(Order.fromMap(orderId as String, orderMap));
          });

          setState(() {
            _orders = orders;
          });
        } else {
          print('No orders found for this user.');
        }
      } else {
        print('User not authenticated.');
      }
    } catch (error) {
      print('Error fetching orders: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: _orders.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return ListTile(
            title: Text(order.title!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => deliveryPage(order: order),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class OrderDetailPage extends StatelessWidget {
  final Order order;

  OrderDetailPage({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(order.title!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.title!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Add more details here as needed
          ],
        ),
      ),
    );
  }
}