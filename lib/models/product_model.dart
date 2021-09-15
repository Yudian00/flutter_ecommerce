import 'package:meta/meta.dart';

class Product {
  var deskripsi;
  var harga;
  var kategori;
  var nama;
  var stok;
  var timeStamp;

  Product({
    @required this.nama,
    @required this.harga,
    @required this.deskripsi,
    @required this.stok,
    @required this.kategori,
    @required this.timeStamp,
  });
}
