import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadAvatar(String uid, File file) async {
    final ext = file.path.split('.').last.toLowerCase();
    final ref = _storage
        .ref()
        .child('avatars')
        .child(uid)
        .child('avatar_${DateTime.now().millisecondsSinceEpoch}.$ext');
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/$ext'),
    );
    return await task.ref.getDownloadURL();
  }

  Future<String> uploadProductImage(String productId, File file) async {
    final ext = file.path.split('.').last.toLowerCase();
    final ref = _storage
        .ref()
        .child('products')
        .child(productId)
        .child('image_${DateTime.now().millisecondsSinceEpoch}.$ext');
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/$ext'),
    );
    return await task.ref.getDownloadURL();
  }
}
