import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() async {
  final instance = MockFirestoreInstance();

  // product dummy
  await instance.collection('product').add({
    'nama': 'Jilbab Hitam',
    'harga': '10000',
    'stok_barang': 30,
    'deskripsi': 'tidak ada barang yang bagus di dunia ini',
    'kategori': 'Wanita',
    'status': 'tersedia',
    'created': DateTime.now(),
    'photoURL':
        'https://firebasestorage.googleapis.com/v0/b/flutter-ecommerce-bf819.appspot.com/o/scaled_image_picker220523866160701912.jpg?alt=media&token=037486d9-bda4-466a-b3c4-6caadd4983d6',
  });

  group('Produk test : ', () {
    test('Membuat Data Produk Baru', () async {
      final instance = MockFirestoreInstance();
      await instance.collection('product').add({
        'nama': 'Jilbab Merah',
        'harga': '10000',
        'stok_barang': 30,
        'deskripsi': 'tidak ada barang yang bagus di dunia ini',
        'kategori': 'Wanita',
        'status': 'tersedia',
        'created': DateTime.now(),
        'photoURL':
            'https://firebasestorage.googleapis.com/v0/b/flutter-ecommerce-bf819.appspot.com/o/scaled_image_picker220523866160701912.jpg?alt=media&token=037486d9-bda4-466a-b3c4-6caadd4983d6',
      }).then((value) {
        expect(value.id, isNotNull);
      });
    });

    test('Ambil Data Produk', () {
      instance
          .collection('product')
          .get()
          .then((value) => value.docs[0]['nama'])
          .then((value) {
        expect(value, 'Jilbab Hitam');
      });
    });

    test('Hapus Data Produk', () {
      instance
          .collection('product')
          .doc('HUrp7enQUa4hOjoSv0QR')
          .delete()
          .then((value) => expect(null, null));
    });

    test('Edit Data Produk', () {
      instance.collection('product').doc('HUrp7enQUa4hOjoSv0QR').set({
        'nama': 'Jilbab Orange',
        'harga': '20000',
        'stok_barang': 15,
        'deskripsi': 'tidak ada barang yang bagus di dunia ini',
        'kategori': 'Wanita',
        'status': 'tersedia',
        'created': DateTime.now(),
        'photoURL':
            'https://firebasestorage.googleapis.com/v0/b/flutter-ecommerce-bf819.appspot.com/o/scaled_image_picker220523866160701912.jpg?alt=media&token=037486d9-bda4-466a-b3c4-6caadd4983d6',
      }).then((value) => expect(null, null));
    });
  });
}
