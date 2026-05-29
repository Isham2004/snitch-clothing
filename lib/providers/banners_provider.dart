import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class BannerItem {
  final String title;
  final String subtitle;
  final String image;
  final String tag;

  BannerItem({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.tag,
  });

  factory BannerItem.fromMap(Map<String, dynamic> data) {
    return BannerItem(
      title: (data['title'] ?? '') as String,
      subtitle: (data['subtitle'] ?? '') as String,
      image: (data['image'] ?? '') as String,
      tag: (data['tag'] ?? '') as String,
    );
  }
}

class BannersProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _sub;

  List<BannerItem> _all = [];
  bool _loaded = false;

  List<BannerItem> get all => List.unmodifiable(_all);
  bool get hasLoaded => _loaded;

  void start() {
    _sub ??= _firestore
        .collection('banners')
        .orderBy('order')
        .snapshots()
        .listen((snap) {
      _all = snap.docs.map((d) => BannerItem.fromMap(d.data())).toList();
      _loaded = true;
      notifyListeners();
    }, onError: (e) {
      debugPrint('[BannersProvider] stream error: $e');
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
