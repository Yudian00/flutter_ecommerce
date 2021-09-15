import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:flutter_ecommerce/utils/widget_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class PaymentMethod extends StatefulWidget {
  PaymentMethod({
    @required this.context,
    @required this.setTransferFunction,
    @required this.setPayAtStoreFunction,
    @required this.username,
    @required this.userPhoneNumber,
    @required this.setUsernamePickup,
    @required this.setUserPhonePickup,
    @required this.note,
    @required this.setNote,
    @required this.setAddress,
  });

  final BuildContext context;
  Function setTransferFunction;
  Function setPayAtStoreFunction;
  Function setUsernamePickup;
  Function setUserPhonePickup;
  Function setNote;
  Function setAddress;
  String username;
  String userPhoneNumber;
  String note;

  @override
  _PaymentMethodState createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  // ignore: unused_field
  bool _isTransferSelected = false;
  bool _isPayAtStoreSelected = false;
  // ignore: unused_field
  bool _isLoading = false;

  bool checkBoxValue = false;
  int group;

  List<String> provinsiList = [];
  List<String> kabupatenList = [];
  List<String> kecamatanList = [];
  Map provinsiMap = {};
  Map kabupatenMap = {};
  Map kecamatanMap = {};

  String provinsi;
  String provinsiId;
  String kabupaten;
  String kabupatenId;
  String kecamatan;
  String kecamatanId;
  String kelurahan;
  String kelurahanId;

  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            child: Text(
              'Opsi Pengambilan',
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          RadioListTile(
            title: Text('Ambil di toko'),
            activeColor: primaryColor,
            value: 1,
            groupValue: group,
            onChanged: (value) {
              print(value);
              setState(() {
                widget.setPayAtStoreFunction();
                group = value;
                _isPayAtStoreSelected = true;
                _isTransferSelected = false;
                clearAddress();
              });
            },
          ),
          RadioListTile(
            title: Text('Antar Barang'),
            activeColor: primaryColor,
            value: 2,
            groupValue: group,
            onChanged: (value) {
              print(value);
              setState(() {
                group = value;
                widget.setTransferFunction();
                _isPayAtStoreSelected = false;
                _isTransferSelected = true;
              });
            },
          ),
          _isPayAtStoreSelected
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                      child: Text(
                        'Informasi Pengambilan',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: TextFormField(
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Masukkan nama penerima',
                          labelText: 'Nama Penerima',
                        ),
                        initialValue: widget.username,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Isi nama terlebih dahulu';
                          } else {
                            widget.setUsernamePickup(value);
                          }

                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: TextFormField(
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Masukkan No.HP penerima',
                          labelText: 'Nama No.HP Penerima',
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: widget.userPhoneNumber,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Isi Nomor Telephone terlebih dahulu';
                          } else {
                            widget.setUserPhonePickup(value);
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                      child: Text(
                        'Catatan Pembelian',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: TextFormField(
                        onChanged: (value) => widget.setNote(value),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Masukkan Catatan',
                          labelText: 'Catatan Pembelian',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                      ),
                      child: Text(
                        'Catatan Pemesanan dapat dikosongkan jika tidak ada tambahan atau permintaan khusus',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 10,
                          height: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                    ),
                  ],
                )
              : Container(),
          _isTransferSelected
              ? ListView(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                      child: Text(
                        'Daerah Pengiriman',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: provinsiList.isNotEmpty
                            ? provinsiDropdown(provinsiList, provinsiMap)
                            : FutureBuilder(
                                future: getProvinsiList(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return loadingAnimation();
                                  } else {
                                    // Add result to list
                                    provinsiList = [];
                                    provinsiMap = {};
                                    for (var i = 0;
                                        i < snapshot.data.length;
                                        i++) {
                                      provinsiList.add(
                                          snapshot.data[i]['nama'].toString());
                                      provinsiMap.putIfAbsent(
                                          snapshot.data[i]['id'].toString(),
                                          () => snapshot.data[i]['nama']);
                                    }
                                    final List<String> _items =
                                        provinsiList.toList();
                                    return provinsiDropdown(
                                        _items, provinsiMap);
                                  }
                                },
                              ),
                      ),
                    ),
                    provinsiId == null
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.all(20.0),
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: kabupatenList.isNotEmpty
                                  ? kabupatenDropdown(
                                      kabupatenList, kabupatenMap)
                                  : FutureBuilder(
                                      future: getKotaList(provinsiId),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return loadingAnimation();
                                        } else {
                                          // Add result to list
                                          kabupatenList = [];
                                          kabupatenMap = {};
                                          for (var i = 0;
                                              i < snapshot.data.length;
                                              i++) {
                                            kabupatenList.add(snapshot.data[i]
                                                    ['nama']
                                                .toString());
                                            kabupatenMap.putIfAbsent(
                                                snapshot.data[i]['id']
                                                    .toString(),
                                                () => snapshot.data[i]['nama']);
                                          }
                                          List<String> _kab =
                                              kabupatenList.toList();

                                          return kabupatenDropdown(
                                              _kab, kabupatenMap);
                                        }
                                      },
                                    ),
                            ),
                          ),
                    kabupatenId == null
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.all(20.0),
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: kecamatanList.isNotEmpty
                                  ? kecamatanDropdown(
                                      kecamatanList, kecamatanMap)
                                  : FutureBuilder(
                                      future: getKecamatanList(kabupatenId),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.waiting &&
                                            kabupatenId != null) {
                                          return loadingAnimation();
                                        } else {
                                          // Add result to list
                                          kecamatanList = [];
                                          kecamatanMap = {};
                                          for (var i = 0;
                                              i < snapshot.data.length;
                                              i++) {
                                            kecamatanList.add(snapshot.data[i]
                                                    ['nama']
                                                .toString());
                                            kecamatanMap.putIfAbsent(
                                                snapshot.data[i]['id']
                                                    .toString(),
                                                () => snapshot.data[i]['nama']);
                                          }
                                          List<String> _kec =
                                              kecamatanList.toList();

                                          return kecamatanDropdown(
                                              _kec, kecamatanMap);
                                        }
                                      },
                                    ),
                            ),
                          ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }

  Widget kecamatanDropdown(List<String> _kec, Map kecamatanMap) {
    return InputDecorator(
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          style: TextStyle(color: Colors.black54),
          value: kecamatan,
          icon: Icon(
            Icons.arrow_drop_down_outlined,
          ),
          isExpanded: true,
          iconSize: 30,
          hint: Text('Pilih Kecamatan'),
          items: _kec.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            kecamatanId = kecamatanMap.keys.firstWhere(
                (k) => kecamatanMap[k] == value,
                orElse: () => null);

            setKecamatan(value, kecamatanId);
            print('kecamatan : ' + value);
            print('id kecamatan ' + kecamatanId.toString());
            widget.setAddress(provinsi, kabupaten, kecamatan);
          },
        ),
      ),
    );
  }

  Widget kabupatenDropdown(List<String> _kab, Map kabupatenMap) {
    return InputDecorator(
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          style: TextStyle(color: Colors.black54),
          value: kabupaten,
          icon: Icon(
            Icons.arrow_drop_down_outlined,
          ),
          isExpanded: true,
          iconSize: 30,
          hint: Text('Pilih Kabupaten'),
          items: _kab.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            kabupatenId = kabupatenMap.keys.firstWhere(
                (k) => kabupatenMap[k] == value,
                orElse: () => null);

            setKabupaten(value, kabupatenId);
            print('kabupaten : ' + value);
            print('id kabupaten ' + kabupatenId.toString());
          },
        ),
      ),
    );
  }

  Widget provinsiDropdown(List<String> _items, Map provinsiMap) {
    return InputDecorator(
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          style: TextStyle(color: Colors.black54),
          value: provinsi,
          icon: Icon(
            Icons.arrow_drop_down_outlined,
          ),
          isExpanded: true,
          iconSize: 30,
          hint: Text('Pilih Provinsi'),
          items: _items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            provinsiId = provinsiMap.keys
                .firstWhere((k) => provinsiMap[k] == value, orElse: () => null);

            setProvinsi(value, provinsiId);
            print('provinsi : ' + value);
            print('id provinsi ' + provinsiId.toString());
          },
        ),
      ),
    );
  }

  void setKecamatan(String kecamatanValue, String kecamatanId) {
    setState(() {
      kecamatan = kecamatanValue;
      kecamatanId = kecamatanId;
    });
  }

  void setKabupaten(String kabupatenValue, String kabupatenId) {
    setState(() {
      kabupaten = kabupatenValue;
      kabupatenId = kabupatenId;
      kecamatan = null;
      kecamatanId = null;
    });
  }

  void setProvinsi(String provinsiValue, String provinsiId) {
    setState(() {
      provinsi = provinsiValue;
      provinsiId = provinsiId;
      kabupaten = null;
      kabupatenId = null;
      kecamatan = null;
      kecamatanId = null;
    });
  }

  void clearAddress() {
    setState(() {
      provinsi = null;
      provinsiId = null;
      kabupaten = null;
      kabupatenId = null;
      kecamatan = null;
      kecamatanId = null;
      kelurahan = null;
      kelurahanId = null;
    });
  }

  //GET API LIST
  //

  Future<List> getProvinsiList() async {
    var provinsiAPI =
        Uri.parse('https://dev.farizdotid.com/api/daerahindonesia/provinsi');
    var response = await http.get(
      provinsiAPI,
    );

    final Map bodyResponse = json.decode(response.body);

    return bodyResponse['provinsi'];
  }

  Future<List> getKotaList(String pronvisiId) async {
    var cityListAPI = Uri.parse(
        'https://dev.farizdotid.com/api/daerahindonesia/kota?id_provinsi=' +
            pronvisiId);
    var response = await http.get(
      cityListAPI,
    );

    final Map bodyResponse = json.decode(response.body);

    return bodyResponse['kota_kabupaten'];
  }

  Future<List> getKecamatanList(String kabupatenId) async {
    var url = Uri.parse(
        'https://dev.farizdotid.com/api/daerahindonesia/kecamatan?id_kota=' +
            kabupatenId);
    var response = await http.get(
      url,
    );

    final Map bodyResponse = json.decode(response.body);

    return bodyResponse['kecamatan'];
  }
}
