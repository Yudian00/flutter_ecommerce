import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce/repositories/DatabaseServices.dart';
import 'package:flutter_ecommerce/ui/widgets/adminWidget/add_more_photos.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

class EditProduct extends StatefulWidget {
  final DocumentSnapshot snapshot;

  EditProduct({
    @required this.snapshot,
  });

  @override
  EditProductState createState() => EditProductState();
}

class EditProductState extends State<EditProduct> {
  TextEditingController nameController = TextEditingController();
  TextEditingController hargaController = TextEditingController();
  TextEditingController stokController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();
  TextEditingController diskonController = TextEditingController();
  TextEditingController diskonPercentController = TextEditingController();

  bool _checked;
  bool _isSelected = false;
  List _selectedPhotos = [];
  final _formKey = GlobalKey<FormState>();

  String _dropDownValue;

  void initState() {
    super.initState();
    textController();

    _checked = widget.snapshot['onDiscount'];
    _dropDownValue = widget.snapshot['kategori'];
  }

  void dispose() {
    super.dispose();
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void changeSelected() {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Produk',
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        // ignore: missing_return
        onNotification: (overscroll) {
          overscroll.disallowGlow();
        },
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Stack(
              children: [
                Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.35,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(
                              widget.snapshot['url'],
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      AddMorePhotos(
                        snapshot: widget.snapshot,
                        selectedPhoto: _selectedPhotos,
                        currentState: _isSelected,
                        changeSelected: changeSelected,
                      ),
                      textField('Nama Barang', nameController),
                      textFieldNumber('Harga Barang', hargaController),
                      textFieldNumber('Stok Barang', stokController),
                      dropDownCategory(),
                      multiLineTextField(
                          'Deskripsi Barang', deskripsiController),
                      discountOption(),
                      submitButton(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                    ],
                  ),
                ),
                AnimatedPositioned(
                  duration: Duration(milliseconds: 500),
                  bottom: _isSelected
                      ? MediaQuery.of(context).size.height * 0.01
                      : -MediaQuery.of(context).size.height * 0.1,
                  left: 50,
                  right: 50,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              changeSelected();
                              _selectedPhotos.clear();
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.1,
                              width: MediaQuery.of(context).size.width * 0.3,
                              color: Colors.transparent,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.close_sharp,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Kembali',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          thickness: 2,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_selectedPhotos.isEmpty) {
                                showAlert(context);
                              } else {
                                showAlertDialog(
                                  context,
                                );
                              }
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.1,
                              width: MediaQuery.of(context).size.width * 0.3,
                              color: Colors.transparent,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Hapus Foto',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget textField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 30,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.black38,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        TextFormField(
          controller: controller,
          validator: Validators.required('Field tidak boleh kosong'),
          style: TextStyle(fontSize: 12),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget textFieldNumber(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 30,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.black38,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        TextFormField(
          validator: Validators.compose([
            Validators.required('Field tidak boleh kosong'),
          ]),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 12),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget dropDownCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 30,
        ),
        Text(
          'Kategori Produk',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black38,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: StreamBuilder<Object>(
              stream: FirebaseFirestore.instance
                  .collection('categories')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  List<String> categoryList = [];
                  QuerySnapshot data = snapshot.data;

                  for (var i = 0; i < data.docs.length; i++) {
                    categoryList.add(data.docs[i]['category_name']);
                  }

                  return DropdownButton(
                    hint: _dropDownValue == null
                        ? Text('Pilih Kategori')
                        : Text(
                            _dropDownValue,
                            style: TextStyle(color: Colors.blue, fontSize: 12),
                          ),
                    isExpanded: true,
                    iconSize: 30.0,
                    style: TextStyle(color: Colors.black87),
                    items: ['Wanita', 'Pria', 'Hijab', 'Lain-lain'].map(
                      (val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      },
                    ).toList(),
                    onChanged: (val) {
                      setState(
                        () {
                          _dropDownValue = val;
                        },
                      );
                    },
                  );
                }
              }),
        ),
      ],
    );
  }

  Widget multiLineTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 30,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.black38,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        TextFormField(
          controller: controller,
          style: TextStyle(fontSize: 12),
          validator: Validators.compose([
            Validators.required('Field tidak boleh kosong'),
          ]),
          keyboardType: TextInputType.multiline,
          maxLines: 5,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget discountOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: Text(
            'Berlaku Diskon',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black,
            ),
          ),
          contentPadding: EdgeInsets.only(left: 0),
          controlAffinity: ListTileControlAffinity.leading,
          value: _checked,
          onChanged: (bool value) {
            setState(() {
              _checked = value;
            });
          },
          activeColor: Colors.blue,
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
          child: TextFormField(
            enabled: _checked,
            controller: diskonPercentController,
            style: TextStyle(fontSize: 12),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: Validators.compose([
              Validators.min(0, 'format tidak sesuai'),
              Validators.max(90, 'Maksimal diskon 90%'),
            ]),
            decoration: InputDecoration(
              hintText: '0 %',
              suffixText: '%',
              border: OutlineInputBorder(
                borderSide: BorderSide(width: 100),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget submitButton() {
    return Column(
      children: [
        SizedBox(
          height: 30,
        ),
        ElevatedButton(
          onPressed: () => submit(),
          style: ElevatedButton.styleFrom(
            primary: adminMainColor,
            minimumSize: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 0.070,
            ),
          ),
          child: Center(
            child: Text(
              'Simpan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "Tidak",
        style: TextStyle(
          color: Colors.black45,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Container(
        height: 30,
        width: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.red,
        ),
        child: Center(
          child: Text(
            "Hapus",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      onPressed: () {
        deletePhoto();
        _selectedPhotos.clear();
        setState(() {});
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Peringatan"),
      content: Text("Hapus foto yang sudah ditandai?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlert(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "Ok",
        style: TextStyle(
          color: Colors.black45,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Oops!"),
      content: Text("Tandai foto yang ingin dihapus terlebih dahulu"),
      actions: [
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void deletePhoto() {
    print('delete list : ' + _selectedPhotos.toString());
    DatabaseServices.deleteProductPhoto(widget.snapshot.id, _selectedPhotos);
    Navigator.pop(context);
  }

  void doEdit() {
    final snackBar = SnackBar(
      content: Text('Produk sudah diupdate'),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    DatabaseServices.updateProductInformation(
      id: widget.snapshot.id,
      nama: nameController.text,
      harga: hargaController.text,
      stokBarang: int.parse(stokController.text),
      deskripsi: deskripsiController.text,
      diskon: _checked,
      kategori: _dropDownValue,
      persenDiskon: int.parse(diskonPercentController.text),
    );
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void doWarning() {
    final snackBar = SnackBar(
      content: Text('Minimal Diskon 10%'),
      backgroundColor: Colors.red,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void submit() {
    if (_formKey.currentState.validate()) {
      if (nameController.text.isNotEmpty) {
        if (_checked) {
          if (int.parse(diskonPercentController.text) < 10) {
            doWarning();
          } else {
            doEdit();
          }
        } else {
          doEdit();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nama barang tidak boleh kosong')));
      }
    }
  }

  void textController() {
    widget.snapshot['nama'] == null
        ? nameController.text = ''
        : nameController.text = widget.snapshot['nama'];

    //===

    widget.snapshot['harga'] == null
        ? hargaController.text = ''
        : hargaController.text = widget.snapshot['harga'];

    //===

    widget.snapshot['stok barang'] == null
        ? stokController.text = ''
        : stokController.text = widget.snapshot['stok barang'].toString();

    //===

    widget.snapshot['deskripsi'] == null
        ? deskripsiController.text = ''
        : deskripsiController.text = widget.snapshot['deskripsi'].toString();

    //===

    widget.snapshot['discount_percent'] == null
        ? diskonPercentController.text = ''
        : diskonPercentController.text =
            widget.snapshot['discount_percent'].toString();
  }
}
