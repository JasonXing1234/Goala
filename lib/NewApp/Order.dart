class Order {
  String? id;
  String? title;
  String? photoUrl;
  String? instruction;
  String? deviceToken;
  String? userName;
  late bool isDelivered;
  late bool isOutForDelivery;
  late bool isTransit;
  late bool isShipped;

  Order({
    required this.id,
    required this.title,
    required this.photoUrl,
    required this.isDelivered,
    required this.isOutForDelivery,
    required this.isTransit,
    required this.isShipped,
    required this.instruction,
    required this.deviceToken,
    required this.userName

  });

  factory Order.fromMap(String id, Map<String, dynamic> data) {
    return Order(
      id: data['orderID'] as String,
      title: data['title'] as String,
      photoUrl: data['photoUrl'] as String,
        isDelivered: data['isDelivered'] as bool,
      isOutForDelivery: data['isOutForDelivery'] as bool,
      isTransit: data['isTransit'] as bool,
      isShipped: data['isShipped'] as bool,
      instruction: data['instruction'] as String,
      deviceToken: data['deviceToken'] as String,

    );
  }

  Order.fromJson(Map<dynamic, dynamic> map) {
    id = map['orderID'];
    title = map['title'];
    photoUrl = map['photoUrl'];
    isDelivered = map['isDelivered'];
    isOutForDelivery = map['isOutForDelivery'];
    isTransit = map['isTransit'];
    isShipped = map['isShipped'];
    instruction = map['instruction'];
    deviceToken = map['deviceToken'];
  }
}