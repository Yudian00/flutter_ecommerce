import 'package:flutter/material.dart';

class AdminFullImage extends StatefulWidget {
  final String productName;
  final String photoURL;

  AdminFullImage({
    @required this.productName,
    @required this.photoURL,
  });

  @override
  _AdminFullImageState createState() => _AdminFullImageState();
}

class _AdminFullImageState extends State<AdminFullImage> {
  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.productName),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 50),
        child: Image.network(
          widget.photoURL,
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
