import 'package:entry/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_ecommerce/repositories/DatabaseServices.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

class DeliveryDetail extends StatefulWidget {
  final String transactionId;

  DeliveryDetail({
    @required this.transactionId,
  });

  @override
  _DeliveryDetailState createState() => _DeliveryDetailState();
}

class _DeliveryDetailState extends State<DeliveryDetail> {
  String _selectedMethod = '';
  String _selectedDate = '';
  TextEditingController _namaEkspedisiController = TextEditingController();
  TextEditingController _noResiController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Detail Pengiriman',
          style: GoogleFonts.roboto(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                'Pilih Metode Pengiriman : ',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 12,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              RadioListTile(
                value: 'Antar Sendiri',
                contentPadding: EdgeInsets.all(0),
                groupValue: _selectedMethod,
                activeColor: primaryColor,
                title: Text(
                  'Antar Sendiri',
                  style: TextStyle(fontSize: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedMethod = value;
                  });
                },
              ),
              RadioListTile(
                value: 'Gunakan Ekspedisi',
                contentPadding: EdgeInsets.all(0),
                groupValue: _selectedMethod,
                activeColor: primaryColor,
                title: Text(
                  'Gunakan Ekspedisi',
                  style: TextStyle(fontSize: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedMethod = value;
                  });
                },
              ),
              SizedBox(
                height: 30,
              ),
              _selectedMethod == 'Gunakan Ekspedisi'
                  ? _ekspedisiOption()
                  : _selectedMethod == 'Antar Sendiri'
                      ? _antarSendiriOption()
                      : Container()
            ],
          ),
        ),
      ),
    );
  }

  Widget _antarSendiriOption() {
    return Entry.opacity(
      duration: Duration(seconds: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tentukan tanggal pengiriman : ',
            style: TextStyle(
              color: Colors.black45,
              fontSize: 12,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(
                EdgeInsets.all(0),
              ),
            ),
            onPressed: () {
              DatePicker.showDateTimePicker(
                context,
                showTitleActions: true,
                locale: LocaleType.id,
                minTime: DateTime.now(),
                onChanged: (date) {
                  print('change $date in time zone ' +
                      date.timeZoneOffset.inHours.toString());
                },
                onConfirm: (date) {
                  print('confirm $date');
                  final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');
                  final String formatted = formatter.format(date);

                  setState(() {
                    _selectedDate = formatted;
                  });
                },
                currentTime: DateTime.now(),
              );
            },
            child: _selectedDate.isEmpty
                ? Text(
                    'Pilih Tanggal',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  )
                : Text(
                    'Perkiraan Waktu Pengiriman : ' + _selectedDate,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
          ),
          SizedBox(
            height: 30,
          ),
          _selectedDate.isEmpty
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = '';
                        });
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.red[300]),
                      child: Text(
                        'Reset',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String deliveryStatus =
                            'Perkiraan Waktu Pengiriman : ' + _selectedDate;
                        processToDeliveryAlert(context, deliveryStatus);
                      },
                      style: ElevatedButton.styleFrom(primary: primaryColor),
                      child: Text(
                        'Proses',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _ekspedisiOption() {
    return Entry.opacity(
      duration: Duration(seconds: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ekspedisi Detail : ',
            style: TextStyle(
              color: Colors.black45,
              fontSize: 12,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            style: TextStyle(fontSize: 12),
            controller: _namaEkspedisiController,
            decoration: InputDecoration(
              hintText: 'Nama Ekspedisi (ex : JNE, JNT, dll.)',
              hintStyle: TextStyle(color: Colors.black45, fontSize: 12),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            style: TextStyle(fontSize: 12),
            controller: _noResiController,
            decoration: InputDecoration(
              hintText: 'No.Resi',
              hintStyle: TextStyle(color: Colors.black45, fontSize: 12),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                checkController();
              },
              style: ElevatedButton.styleFrom(primary: primaryColor),
              child: Text(
                'Proses',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void checkController() {
    if (_namaEkspedisiController.text.isEmpty ||
        _noResiController.text.isEmpty) {
      final snackBar = SnackBar(content: Text('Data tidak lengkap'));

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      String deliveryStatus =
          _namaEkspedisiController.text + ' ' + _noResiController.text;

      processToDeliveryAlert(context, deliveryStatus);
      FocusScope.of(context).unfocus();
    }
  }

  processToDeliveryAlert(BuildContext context, String deliveryStatus) {
    AlertDialog alert = AlertDialog(
      title: Text('Pengiriman'),
      content: Container(
        // height: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width,
        child: Text(
          'Proses pesanan ini ke pengiriman?',
          style: TextStyle(
            height: 1.5,
            fontSize: 12,
          ),
        ),
      ),
      actionsPadding: EdgeInsets.symmetric(horizontal: 30),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            "Tidak",
            style:
                TextStyle(color: Colors.black38, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: () {
            DatabaseServices.setStatusDelivery(
                widget.transactionId, deliveryStatus);
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
            Fluttertoast.showToast(msg: 'Status transaksi sudah diperbarui');
          },
          child: Text(
            "Ya",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(child: alert);
      },
    );
  }
}
