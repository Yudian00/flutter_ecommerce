import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/repositories/DatabaseServices.dart';
import 'package:meta/meta.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit() : super(TransactionInitial());

  void payAtStore(var mapData) async {
    List itemList = [];
    List itemQty = [];
    List itemPriceList = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("transaction")
        .where('userId2', isEqualTo: mapData['userID'])
        .where('status', isEqualTo: 'Menunggu konfirmasi')
        .get();

    var list = querySnapshot.docs;

    try {
      //insert item id to list
      for (var items in mapData['mapCart'].keys) {
        itemList.add(items);
      }

      //insert item qty to list
      for (var items in mapData['mapCart'].values) {
        itemQty.add(items);
      }

      //insert item price to list
      for (var items in mapData['itemPriceList']) {
        itemPriceList.add(items);
      }

      if (list.length < 3) {
        DatabaseServices.createOrUpdateProduct(
            mapData['userID'],
            itemList,
            itemQty,
            itemPriceList,
            mapData['totalPrice'],
            mapData['username'],
            mapData['userPhoneNumber'],
            mapData['note'],
            'Bayar di toko');
        emit(TransactionEnd(isSuccess: true));
      } else {
        emit(TransactionEnd(isSuccess: false));
      }
    } catch (e) {
      print('Cant create or update data');
    }

    // emit(TransactionEnd());
  }

  void transfer(var mapData) async {
    List itemList = [];
    List itemQty = [];
    List itemPriceList = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("transaction")
        .where('userId2', isEqualTo: mapData['userID'])
        .where('status', isEqualTo: 'Menunggu konfirmasi')
        .get();

    var list = querySnapshot.docs;

    try {
      //insert item id to list
      for (var items in mapData['mapCart'].keys) {
        itemList.add(items);
      }

      //insert item qty to list
      for (var items in mapData['mapCart'].values) {
        itemQty.add(items);
      }

      //insert item price to list
      for (var items in mapData['itemPriceList']) {
        itemPriceList.add(items);
      }

      print('List Length : ' + list.length.toString());
      if (list.length < 3) {
        DatabaseServices.transferPayment(
            mapData['userID'],
            itemList,
            itemQty,
            itemPriceList,
            mapData['totalPrice'],
            mapData['username'],
            mapData['address'],
            mapData['userPhoneNumber'],
            mapData['note'],
            'Transfer');
        emit(TransactionEnd(isSuccess: true));
      } else {
        emit(TransactionEnd(isSuccess: false));
      }
      //
    } catch (e) {
      print('Cant create or update data');
    }

    // emit(TransactionEnd());
  }
}
