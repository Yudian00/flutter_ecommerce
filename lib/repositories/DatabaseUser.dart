import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';

class DatabaseUser {
  static CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user');

  static void updateProfile(
      String name, String phoneNumber, String address, String userId) async {
    try {
      await userCollection.doc(userId).update(
        {
          'username': name,
          'noHP': phoneNumber,
          'alamat': address,
        },
      );
    } catch (e) {
      print(e);
    }
  }

  static void createUser(UserRepository userRepository) {
    userRepository.getCurrentUser().then((value) async {
      try {
        await userCollection.doc(value.uid).set({
          'role': 'unknown',
          'email': value.email,
        });
      } catch (e) {
        print(e);
      }
    });
  }

  static void editUsernameAndPhoneNumber(
      String name, String phoneNumber, String address, String userId) async {
    userCollection.doc(userId).update(
      {
        'username': name,
        'noHP': phoneNumber,
        'alamat': address,
        'role': 'pengguna',
      },
    );
  }

  static void resetTokenUser(String id) {
    userCollection.doc(id).update({
      'token': '',
    });
  }

  static void createToken(String userId, String token) {
    userCollection.doc(userId).update({
      'token': token,
    });
  }

  static Future<DocumentSnapshot> getUserToken(String userId) async {
    Future<DocumentSnapshot> documentSnapshot =
        userCollection.doc(userId).get();

    return documentSnapshot;
  }
}
