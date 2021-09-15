import 'package:flutter/material.dart';

class TermAndConditionPage extends StatefulWidget {
  @override
  _TermAndConditionPageState createState() => _TermAndConditionPageState();
}

class _TermAndConditionPageState extends State<TermAndConditionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Syarat dan Ketentuan',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 21, color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        // ignore: missing_return
        onNotification: (overscroll) {
          overscroll.disallowGlow();
        },
        child: Padding(
          padding: EdgeInsets.all(20),
          child: ListView(
            children: [
              subHeading('A. Ketentuan Umum'),
              subtance(1,
                  'Dengan menggunakan, berbelanja dan/atau mendaftarkan diri Anda di aplikasi ini, berarti Anda setuju untuk terikat dan patuh pada syarat dan ketentuan yang berlaku.'),
              subtance(2,
                  'Syarat dan ketentuan ini dapat berubah sewaktu-waktu dan kami tidak berkewajiban untuk memberitahukannya kepada Anda.'),
              subtance(3,
                  'Syarat dan ketentuan ini kami buat untuk kepentingan bersama, untuk menjaga hak dan kewajiban masing-masing pihak, dan tidak dimaksudkan untuk merugikan salah satu pihak.'),

              SizedBox(
                height: 40,
              ),

              //
              subHeading('B. Informasi Produk'),
              subtance(1,
                  'Perbedaan warna dalam foto/gambar produk yang kami tampilkan di aplikasi ini bisa diakibatkan oleh faktor pencahayaan dan setting/resolusi layar hp, dan karena itu tidak dapat dijadikan acuan.'),
              subtance(2,
                  'Harga produk dalam aplikasi ini adalah benar pada saat dicantumkan. Harga yang tercantum adalah harga produk semata, tidak termasuk ongkos kirim (jika menggunakan jasa pengiriman). Ongkos kirim akan ditambahkan setelah admin mengkonfirmasi pesanan yang masuk sesuai dengan alamat yang diberikan')
            ],
          ),
        ),
      ),
    );
  }

  Widget subHeading(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget subtance(int number, String text) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              number.toString(),
              style: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
                child: Center(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
