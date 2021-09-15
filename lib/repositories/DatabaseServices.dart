import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_ecommerce/repositories/NotificationFCM.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DatabaseServices {
  static CollectionReference productCollection =
      FirebaseFirestore.instance.collection('product');
  static CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user');
  static CollectionReference transactionCollection =
      FirebaseFirestore.instance.collection('transaction');
  static CollectionReference favoriteCollection =
      FirebaseFirestore.instance.collection('favorite');
  static CollectionReference categoryCollection =
      FirebaseFirestore.instance.collection('categories');
  static CollectionReference midtransCollection =
      FirebaseFirestore.instance.collection('midtrans');
  static CollectionReference deliveryCollection =
      FirebaseFirestore.instance.collection('delivery');

  static Future<DocumentSnapshot> getUserInfo(firebaseID) async {
    return await userCollection.doc(firebaseID).get();
  }

  static Future<DocumentSnapshot> getProductInfo(productID) async {
    return await productCollection.doc(productID).get();
  }

  static Future<void> createOrUpdateProduct(
    String userid,
    List itemList,
    List itemQty,
    List itemPriceList,
    int totalPrice,
    String username,
    String noHP,
    String note,
    String metode,
  ) async {
    List documentIdList = [];

    //input data
    try {
      final docRef = await transactionCollection.add(
        {
          'userId2': userid,
          'totalPrice2': totalPrice,
          'ListQty2': itemQty,
          'note': note,
          'username': username,
          'itemBasePrice': itemPriceList,
          'noHP': noHP,
          'address': '',
          'itemList': FieldValue.arrayUnion(itemList),
          'status': 'Menunggu konfirmasi',
          'created': FieldValue.serverTimestamp(),
          'metode': metode,
          'ongkir': 0,
        },
      );
      var docSnap = await docRef.get();
      var docId = docSnap.reference.id;

      print('document ID : ' + docId.toString());
      documentIdList.add(docId);
      DatabaseServices.updateUserTransactionId(userid, documentIdList);

      userCollection.get().then((value) {
        List<QueryDocumentSnapshot> data = value.docs;
        for (var i = 0; i < data.length; i++) {
          if (data[i]['role'] == 'admin') {
            String deviceToken = data[i]['token'];
            NotificationFCM.setNotificationFCM(deviceToken,
                titleMessage: 'New Order',
                bodyMessage: 'Pesanan baru telah diterima');
          }
        }
      });
    } catch (e) {
      print('something went error when try make transaction');
    }
  }

  static Future<void> transferPayment(
    String userid,
    List itemList,
    List itemQty,
    List itemPriceList,
    int totalPrice,
    String username,
    String address,
    String noHP,
    String note,
    String metode,
  ) async {
    List documentIdList = [];

    //input data
    try {
      final docRef = await transactionCollection.add(
        {
          //this is null
          // 'idPelanggan ': userid,
          // 'totalHarga ': totalPrice,
          // 'QtyList': itemQty,

          'userId2': userid,
          'totalPrice2': totalPrice,
          'ListQty2': itemQty,
          'note': note,
          'username': username,
          'itemBasePrice': itemPriceList,
          'noHP': noHP,
          'address': address,

          'itemList': FieldValue.arrayUnion(itemList),
          'status': 'Menunggu konfirmasi',
          'created': FieldValue.serverTimestamp(),
          'metode': metode,
          'ongkir': 0,
        },
      );

      userCollection.get().then((value) {
        List<QueryDocumentSnapshot> data = value.docs;
        for (var i = 0; i < data.length; i++) {
          if (data[i]['role'] == 'admin') {
            String deviceToken = data[i]['token'];
            NotificationFCM.setNotificationFCM(deviceToken,
                titleMessage: 'New Order',
                bodyMessage: 'Pesanan baru telah diterima');
          }
        }
      });

      var docSnap = await docRef.get();
      var docId = docSnap.reference.id;

      print('document ID : ' + docId.toString());
      documentIdList.add(docId);
      DatabaseServices.updateUserTransactionId(userid, documentIdList);
    } catch (e) {
      print('something went error when try to input data');
    }
  }

  static Future<void> cancelOrder(String id) async {
    print('cancel order');
    await transactionCollection.doc(id).update(
      {
        'status': 'Dibatalkan',
      },
      // merge: true,
    );
  }

  static Future<void> finishOrder(String id, Map itemData,
      QueryDocumentSnapshot snapshot, Function showErrorSnakcbar) async {
    print(itemData);
    print(snapshot.data());

    Map mapData = snapshot.data();

    for (var i = 0; i < mapData['itemList'].length; i++) {
      productCollection.doc(mapData['itemList'][i]).get().then(
        (value) {
          print('=======================');

          Map productData = value.data();
          int sisaBarang;
          sisaBarang = productData['stok barang'] - mapData['ListQty2'][i];

          if (sisaBarang < 0) {
            showErrorSnakcbar();
          } else {
            print(sisaBarang);

            // update product stock after complete transaction
            productCollection.doc(mapData['itemList'][i]).update({
              'stok barang': sisaBarang,
            });

            // set status transaction to complete
            transactionCollection.doc(id).update(
              {
                'status': 'Selesai',
              },
              // merge: true,
            );
          }
        },
      );
    }

    // for (var i = 0; i < itemData.length; i++) {

    // }
  }

  static Future<void> updateUserTransactionId(
      String userid, List documentID) async {
    return await userCollection
        .doc(userid)
        .update({'recentTransactionId': FieldValue.arrayUnion(documentID)});
  }

  static Future<void> deleteTransactionData(String id) async {
    await transactionCollection.doc(id).delete();
  }

  static Future<void> addToFavorite(String userId, String productId) async {
    try {
      await favoriteCollection.add({
        'userId': userId,
        'productId': productId,
      }).then((documentId) => print(documentId.get()));
    } catch (e) {
      print(e);
    }
  }

  static Future<void> deleteFromFavorite(String id) async {
    try {
      await favoriteCollection.doc(id).delete();
    } catch (e) {
      print(e);
    }
  }

  static Future<void> onlinePay(
      String id, String midtransId, String metode) async {
    transactionCollection.doc(id).update({
      'status': 'Menunggu Pelunasan',
      'metode': metode,
      'midtransId': midtransId,
    });
  }

  static Future<void> createMidTransDataGopay(
    String midtransId,
    String qrImageUrl,
    String deepLinkUrl,
    String transactionId,
    String paymentType,
  ) async {
    midtransCollection.add({
      'midtransId': midtransId,
      'qrImageUrl': qrImageUrl,
      'deepLinkUrl': deepLinkUrl,
      'transactionId': transactionId,
      'PaymentType': paymentType,
      'PaymentStatus': 'pending',
      'transaction_time': DateTime.now(),
      'expired_time': DateTime.now().add(Duration(minutes: 15)),
    });
  }

  static Future<void> createMidTransDataBankTransfer(
    String midtransId,
    String virtualAccountNumber,
    String transactionId,
    String paymentType,
  ) async {
    midtransCollection.add({
      'midtransId': midtransId,
      'va_number': virtualAccountNumber,
      'transactionId': transactionId,
      'PaymentType': paymentType,
      'PaymentStatus': 'pending',
      'transaction_time': DateTime.now(),
      'expired_time': DateTime.now().add(Duration(hours: 24)),
    });
  }

  static Future<void> setExpireTransactionStatus(String transactionId) async {
    // Set status on expired when it's not complete

    FirebaseFirestore.instance
        .collection('transaction')
        .doc(transactionId)
        .get()
        .then((value) {
      Map<String, dynamic> data = value.data();
      if (data['status'] != 'Pembayaran Lunas') {
        FirebaseFirestore.instance
            .collection('transaction')
            .doc(transactionId)
            .update({
          'status': 'Expired',
        });
      }
    });
  }

  // ============================ ADMIN SESSION

  static Future<void> adminCancelOrder(String id, String cancelMessage) async {
    await transactionCollection.doc(id).update({
      'status': 'Ditolak',
      'cancelMessage': cancelMessage,
    });
  }

  static Future<void> adminConfirmOrder(
    String id,
    String metode,
    num totalPrice,
    num ongkir,
    List productIdList,
    Map stokProductList,
    List orderQty,
  ) async {
    if (metode == 'Bayar di toko') {
      for (var i = 0; i < productIdList.length; i++) {
        // int sisaBarang = stokProductList[productIdList[i]] - orderQty[i];

        // productCollection.doc(productIdList[i]).update({
        //   'stok barang': sisaBarang,
        // });
        transactionCollection.doc(id).update({
          'status': 'Ambil di toko',
        });
      }
    } else if (metode == 'Transfer') {
      transactionCollection.doc(id).update({
        'status': 'Menunggu Pembayaran',
        'ongkir': ongkir,
        'totalPrice2': totalPrice,
      });
    }
  }

  static Future<void> setStatusDelivery(
      String id, String deliveryStatus) async {
    await deliveryCollection.add({
      'transaction_id': id,
      'status_pengiriman ': deliveryStatus,
    });

    await transactionCollection.doc(id).update({
      'status': 'Sedang Mengirim',
    });
  }

  static Future<void> addProductPhoto(String id, List listPhoto) async {
    await productCollection
        .doc(id)
        .update({'fotoProduk': FieldValue.arrayUnion(listPhoto)});
  }

  static Future<void> deleteProductPhoto(String id, List listPhoto) async {
    await productCollection
        .doc(id)
        .update({'fotoProduk': FieldValue.arrayRemove(listPhoto)});

    for (var i = 0; i < listPhoto.length; i++) {
      String imageUrl = listPhoto[i];
      FirebaseStorage.instance.refFromURL(imageUrl).delete();
    }

    Fluttertoast.showToast(msg: 'Foto berhasil dihapus');
  }

  static Future<void> createNewProduct({
    String url,
    String nama,
    String harga,
    int stokBarang,
    String kategori,
    String deskripsi,
    bool diskon,
    int persenDiskon,
  }) async {
    if (!diskon) {
      print('discount not applied');
      persenDiskon = 0;
    }
    print(url);
    print(nama);
    print(harga);
    print(stokBarang);
    print(kategori);
    print(deskripsi);
    print(diskon);
    print(persenDiskon);

    productCollection.add({
      'nama': nama,
      'harga': harga,
      'stok barang': stokBarang,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'onDiscount': diskon,
      'discount_percent': persenDiskon,
      'url': url,
      'timestamp': DateTime.now(),
      'status': 'tersedia',
    });
  }

  static Future<void> updateProductInformation({
    String id,
    String nama,
    String harga,
    int stokBarang,
    String kategori,
    String deskripsi,
    bool diskon,
    int persenDiskon,
  }) async {
    print(id);
    print(nama);
    print(harga);
    print(stokBarang);
    print(kategori);
    print(deskripsi);
    print(diskon);
    print(persenDiskon);

    if (!diskon) {
      print('discount not applied');
      persenDiskon = 0;
    }

    productCollection.doc(id).update({
      'nama': nama,
      'harga': harga,
      'stok barang': stokBarang,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'onDiscount': diskon,
      'discount_percent': persenDiskon,
    });
  }

  static Future<void> deleteProduct(String id) async {
    await productCollection.doc(id).update({
      'status': 'DELETED',
    });
    Fluttertoast.showToast(msg: 'Produk sudah dihapus');
  }

  static Future<void> addCategory(String category, Function successSnackbar,
      Function duplicateSnackbar, Function resetController) async {
    bool isDuplicated = false;

    await categoryCollection.get().then((value) {
      // Check if there is duplicate category
      value.docs.forEach((data) {
        // print(data['category_name']);
        if (category == data['category_name']) {
          isDuplicated = true;
        }
      });
    });

    // showing snackbar
    if (isDuplicated) {
      duplicateSnackbar();
    } else {
      await categoryCollection.add({
        'category_name': category,
      });

      successSnackbar();
      resetController();
    }
  }

  static Future<void> deleteCategory(
      String categoryId, Function deleteSucessSnakcbar) async {
    await categoryCollection.doc(categoryId).delete();
    deleteSucessSnakcbar();
  }
}
