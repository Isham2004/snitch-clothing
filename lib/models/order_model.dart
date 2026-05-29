import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class OrderModel {
  final String id;
  final DateTime date;
  final List<CartItem> items;
  final double subtotal;
  final double shipping;
  final double total;
  final String status;
  final String address;
  final String paymentMethod;

  OrderModel({
    required this.id,
    required this.date,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.status,
    required this.address,
    required this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'shipping': shipping,
      'total': total,
      'status': status,
      'address': address,
      'paymentMethod': paymentMethod,
      'itemCount': items.fold<int>(0, (total, i) => total + i.quantity),
    };
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['date'];
    DateTime date;
    if (ts is Timestamp) {
      date = ts.toDate();
    } else if (ts is DateTime) {
      date = ts;
    } else {
      date = DateTime.now();
    }
    return OrderModel(
      id: id,
      date: date,
      items: ((data['items'] as List?) ?? const [])
          .map((e) => CartItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      subtotal: ((data['subtotal'] ?? 0) as num).toDouble(),
      shipping: ((data['shipping'] ?? 0) as num).toDouble(),
      total: ((data['total'] ?? 0) as num).toDouble(),
      status: (data['status'] ?? 'Confirmed') as String,
      address: (data['address'] ?? '') as String,
      paymentMethod: (data['paymentMethod'] ?? 'Credit Card') as String,
    );
  }
}
