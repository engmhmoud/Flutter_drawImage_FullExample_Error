import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:image/image.dart' as ImageLib;

class Sign extends StatefulWidget {
  Sign({Key key}) : super(key: key);

  @override
  _SignState createState() => _SignState();
}

class _WatermarkPaint extends CustomPainter {
  final String price;
  final String watermark;

  // final _bloc;
  _WatermarkPaint(this.price, this.watermark);

  @override
  void paint(ui.Canvas canvas, ui.Size Size) {
    // canvas.drawCircle(Offset(Size.width / 2, Size.height / 2), 10.8,
    //     Paint()..color = Colors.blue);
  }

  @override
  bool shouldRepaint(_WatermarkPaint oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WatermarkPaint &&
          runtimeType == other.runtimeType &&
          price == other.price &&
          watermark == other.watermark;

  @override
  int get hashCode => price.hashCode ^ watermark.hashCode;
}

class _SignState extends State<Sign> {
  ByteData _img = ByteData(0);
  final _sign = GlobalKey<SignatureState>();

  Color _chosedColor = Colors.redAccent;
  ColorSwatch _tempMainColor = Colors.blue;
  Color _tempShadeColor = Colors.blue;

  ColorSwatch _mainColor = Colors.blue;
  Color _shadeColor = Colors.blue[800];

  double _thickness = 5;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Signature(
                  color: _tempShadeColor,
                  key: _sign,
                  onSign: () {
                    final sign = _sign.currentState;
                    debugPrint('${sign.points.length} points in the signature');
                  },
                  // backgroundPainter: _WatermarkPaint("2.0", "2.0"),
                  strokeWidth: _thickness,
                ),
              ),
              color: Colors.black12,
            ),
          ),
          _img.buffer.lengthInBytes == 0
              ? Container()
              : LimitedBox(
                  maxHeight: 100.0,
                  child: Image.memory(_img.buffer.asUint8List(),
                      color: _tempShadeColor)),
          Container(
            height: 100,
            child: Row(
              // alignment: WrapAlignment.spaceBetween,
              // crossAxisAlignment: WrapCrossAlignment.center,

              // direction: Axis.horizontal,

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: MaterialButton(
                      color: Colors.blue,
                      onPressed: () async {
                        final sign = _sign.currentState;
                        //retrieve image data, do whatever you want with it (send to server, save locally...)
                        final image = await sign.getData();

                        var data = await image.toByteData(
                            format: ui.ImageByteFormat.png);

                        // File file = File.fromRawPath(data.buffer.asUint8List());
                        sign.clear();
                        String encoded =
                            base64.encode(data.buffer.asUint8List());
                        if (mounted)
                          setState(() {
                            _img = data;
                          });
                        debugPrint("onPressed " + encoded);
                        ImageLib.Image mySign = ImageLib.Image.fromBytes(
                            image.width,
                            image.height,
                            data.buffer.asUint8List());
                        Navigator.pop(context, mySign);
                      },
                      child: Text("Save")),
                ),
                Container(
                  child: MaterialButton(
                      color: Colors.green,
                      onPressed: () {
                        final sign = _sign.currentState;
                        sign.clear();
                        if (mounted)
                          setState(() {
                            _img = ByteData(0);
                          });
                        debugPrint("cleared");
                      },
                      child: Text("Clear")),
                ),
                // Container(
                //   width: 40,
                //   height: 40,
                //   child: InkWell(
                //     child: CircleAvatar(
                //       radius: 40,
                //       backgroundColor: _tempShadeColor,
                //     ),
                //     onTap: () => _openColorPicker(),
                //   ),
                // ),
                Container(
                  child: MaterialButton(
                      onPressed: () {},
                      child: DropdownButton<int>(
                        icon: Icon(Icons.filter_list),
                        items: <int>[1, 2, 3, 4, 5, 6, 4, 8, 9, 10]
                            .map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Divider(
                              height: value.toDouble(),
                              color: _chosedColor,
                              thickness: value.toDouble(),
                            ),
                          );
                        }).toList(),
                        onChanged: (_) {
                          if (mounted)
                            setState(() {
                              _thickness = _.toDouble();
                            });
                        },
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _openDialog(String title, Widget content) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text(title),
          content: content,
          actions: [
            FlatButton(
              child: Text('CANCEL'),
              onPressed: Navigator.of(context).pop,
            ),
            FlatButton(
              child: Text('SUBMIT'),
              onPressed: () {
                Navigator.of(context).pop();
                if (mounted) if (mounted)
                  setState(() {
                    _mainColor = _tempMainColor;
                    _shadeColor = _tempShadeColor;
                  });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // _sign.currentState.clear();
    // _sign.currentContext.widg();
    super.dispose();
  }
}
