import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/order_model.dart';

class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userOrders(String uid) =>
      _firestore.collection('users').doc(uid).collection('orders');

  Future<OrderModel> placeOrder({
    required String uid,
    required List<CartItem> items,
    required double subtotal,
    required double shipping,
    required double total,
    required String address,
    required String paymentMethod,
  }) async {
    final docRef = _userOrders(uid).doc();
    final humanId =
        'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final order = OrderModel(
      id: humanId,
      date: DateTime.now(),
      items: items,
      subtotal: subtotal,
      shipping: shipping,
      total: total,
      status: 'Confirmed',
      address: address,
      paymentMethod: paymentMethod,
    );
    final payload = {
      ...order.toMap(),
      'orderId': humanId,
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final batch = _firestore.batch();
    batch.set(docRef, payload);
    batch.set(_firestore.collection('orders').doc(docRef.id), payload);
    try {
      await batch.commit();
    } catch (e) {
      debugPrint('[Order] Failed to save order: $e');
      rethrow;
    }
    return order;
  }

  Future<List<OrderModel>> getOrders(String uid) async {
    final snap = await _userOrders(uid).orderBy('date', descending: true).get();
    return snap.docs.map((d) {
      final data = d.data();
      final humanId = (data['orderId'] ?? d.id) as String;
      return OrderModel.fromMap(humanId, data);
    }).toList();
  }

  Stream<List<OrderModel>> watchOrders(String uid) {
    return _userOrders(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) {
              final data = d.data();
              final humanId = (data['orderId'] ?? d.id) as String;
              return OrderModel.fromMap(humanId, data);
            }).toList());
  }
}
