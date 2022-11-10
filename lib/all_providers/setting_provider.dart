import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingProvider {
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;

  SettingProvider({
    required this.firebaseStorage,
    required this.firebaseFirestore,
    required this.prefs,
  });

  String getPrefs(String key) {
    return prefs.getString(key) ?? "";
  }

  Future<bool> setPrefs(String key, String value) async {
    return await prefs.setString(key, value);
  }

  UploadTask uploadFile(String filename, File image) {
    Reference reference = firebaseStorage.ref().child(filename);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String path, Map<String, String> dataNeedUpdate) async{
    firebaseFirestore.collection(collectionPath).doc(path).update(dataNeedUpdate);
  }
}
