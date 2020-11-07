import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

var Volumen = true; //No muteado
var volslider = 5.0, //Valores que manejan el slider
    agslider = 5.0,
    meslider = 5.0,
    meagslider = 5.0,
    grslider = 5.0,
    vol = 5.0, //valores reales
    med = 5.0,
    meag = 5.0,
    ag = 5.0,
    gr = 5.0,
    oldvol = vol; //Para guardar en caso de muteo

var entvol = 0; //variables de conversión
var strvol = "0";
var entag = 0;
var strag = "0";
var entmed = 0;
var strmed = "0";
var entmeag = 0;
var strmeag = "0";
var entgr = 0;
var strgr = "0";
var estilos = ['Jazz', 'Pop', 'Rock'];
var strjazz = "j";
var strRock = "r";
var strPop = "p";

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  static final clientID = 0;
  BluetoothConnection connection;
  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;

  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
          title: (isConnecting
              ? Text('Conectandose al Ecualizador...')
              : isConnected
                  ? Text('Ecualizador Conectado ')
                  : Text('DESCONECTADO!'))),
      body: Container(
          color: Colors.grey[400],
          margin: EdgeInsets.all(1.0),
          child: Column(
            children: <Widget>[
              Center(
                  child: Container(
                      color: Colors.grey[800],
                      child: Row(
                        children: <Widget>[
                          ///////////////////////COLUMNAS
                          Container(
                              margin: EdgeInsets.all(20.0),
                              width: 100.0,
                              height: 60.0,
                              child: RaisedButton(
                                child: const Text('Jazz',
                                    style: TextStyle(
                                      fontSize: 30.0,
                                    )),
                                onPressed: () {
                                  _sendMessage(strjazz);
                                  agslider = 5;
                                  meslider = 5;
                                  meagslider = 5;
                                  grslider = 5;
                                },
                                //shape: RoundedRectangleBorder(
                                // borderRadius: BorderRadius.circular(18.0),
                                //)
                              )),
                          Container(
                              margin: EdgeInsets.all(20.0),
                              width: 100.0,
                              height: 60.0,
                              child: RaisedButton(
                                child: Text('Rock',
                                    style: TextStyle(
                                      fontSize: 30.0,
                                    )),
                                onPressed: () {
                                  _sendMessage(strRock);
                                  agslider = 5;
                                  meslider = 5;
                                  meagslider = 5;
                                  grslider = 5;
                                },
                              )),
                          Container(
                              margin: EdgeInsets.all(20.0),
                              width: 100.0,
                              height: 60.0,
                              child: RaisedButton(
                                child: const Text('Pop',
                                    style: TextStyle(
                                      fontSize: 30.0,
                                    )),
                                onPressed: () {
                                  _sendMessage(strPop);
                                  agslider = 5;
                                  meslider = 5;
                                  meagslider = 5;
                                  grslider = 5;
                                },
                              ))
                        ],
                      ))),
              Divider(),
              Row(children: <Widget>[
                Column(children: <Widget>[
                  Container(
                    width: 40,
                    height: 30,
                    margin: EdgeInsets.only(top: 0, bottom: 120),
                   // color: Colors.green,
                    child: Text("+5 dB", style: TextStyle(fontSize: 17),),
                  ),
                  Container(
                    width: 40,
                    height: 120,
                    margin: EdgeInsets.only(left: 5, top: 25),
                    //color: Colors.green,
                    child: Text("0 dB", style: TextStyle(fontSize: 17),),
                  ),
                  Container(
                    width: 40,
                    height: 20,
                    margin: EdgeInsets.only(top: 40),
                    //color: Colors.green,
                    child: Text("-5 dB", style: TextStyle(fontSize: 17),),
                  ),
                ]),
                Container(
                    margin: EdgeInsets.only(
                        left: 0.0, top: 20.0, right: 35.0, bottom: 10),
                    width: 60.0,
                    height: 380.0,
                    color: Colors.grey[600],
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.black87,
                          inactiveTrackColor: Colors.black26,
                          inactiveTickMarkColor: Colors.black26,
                          activeTickMarkColor: Colors.grey,
                          tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 3),
                          trackShape: RoundedRectSliderTrackShape(),
                          //trackShape: RectangularSliderTrackShape(),
                          trackHeight: 4.0,
                          thumbColor: Colors.white,
                          thumbShape: CustomSliderThumbRect(
                              thumbHeight: 30, thumbRadius: 3, min: 0, max: 10),
                          overlayColor: Colors.red.withAlpha(32),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 28.0),
                        ),
                        child: Slider(
                          min: 0.0,
                          max: 10.0,
                          divisions: 10,
                          value: grslider,
                          onChanged: (gr) {
                            setState(() {
                              grslider = gr;
                            });
                            entgr = gr.round();
                            switch (entgr) {
                              case 0:
                                strgr = ';';
                                break;

                              case 1:
                                strgr = '<';
                                break;

                              case 2:
                                strgr = '=';
                                break;

                              case 3:
                                strgr = '>';
                                break;

                              case 4:
                                strgr = '?';
                                break;

                              case 5:
                                strgr = '@';
                                break;

                              case 6:
                                strgr = 'A';
                                break;

                              case 7:
                                strgr = 'B';
                                break;

                              case 8:
                                strgr = 'C';
                                break;

                              case 9:
                                strgr = 'D';
                                break;

                              case 10:
                                strgr = 'E';
                                break;

                              default:
                                break;
                            }
                            _sendMessage(strgr);
                          },
                        ),
                      ),
                    )),
                Container(
                    margin: EdgeInsets.only(
                        left: 0, top: 20.0, right: 20.0, bottom: 10),
                    color: Colors.grey[600],
                    width: 60.0,
                    height: 380.0,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.black87,
                          inactiveTrackColor: Colors.black26,
                          inactiveTickMarkColor: Colors.black26,
                          activeTickMarkColor: Colors.grey,
                          tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 3),
                          trackShape: RectangularSliderTrackShape(),
                          trackHeight: 4.0,
                          thumbColor: Colors.white,
                          thumbShape: CustomSliderThumbRect(
                              thumbHeight: 30, thumbRadius: 3, min: 0, max: 10),
                          overlayColor: Colors.green.withAlpha(32),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 28.0),
                        ),
                        child: Slider(
                          min: 0.0,
                          max: 10.0,
                          divisions: 10,
                          value: meslider,
                          onChanged: (med) {
                            setState(() {
                              meslider = med;
                            });
                            entmed = med.round();
                            switch (entmed) {
                              case 0:
                                strmed = 'F';
                                break;

                              case 1:
                                strmed = 'G';
                                break;

                              case 2:
                                strmed = 'H';
                                break;

                              case 3:
                                strmed = 'I';
                                break;

                              case 4:
                                strmed = 'J';
                                break;

                              case 5:
                                strmed = 'K';
                                break;

                              case 6:
                                strmed = 'L';
                                break;

                              case 7:
                                strmed = 'M';
                                break;

                              case 8:
                                strmed = 'N';
                                break;

                              case 9:
                                strmed = 'O';
                                break;

                              case 10:
                                strmed = 'P';
                                break;

                              default:
                                break;
                            }
                            _sendMessage(strmed);
                          },
                        ),
                      ),
                    )),
                VerticalDivider(),
                Container(
                    margin: EdgeInsets.only(
                        left: 5.0, top: 20.0, right: 20.0, bottom: 10),
                    width: 60.0,
                    height: 380.0,
                    color: Colors.grey[600],
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.black87,
                          inactiveTrackColor: Colors.black26,
                          inactiveTickMarkColor: Colors.black26,
                          activeTickMarkColor: Colors.grey,
                          tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 3),
                          trackShape: RectangularSliderTrackShape(),
                          trackHeight: 4.0,
                          thumbColor: Colors.white,
                          thumbShape: CustomSliderThumbRect(
                              thumbHeight: 30, thumbRadius: 3, min: 0, max: 10),
                          overlayColor: Colors.blue.withAlpha(32),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 28.0),
                        ),
                        child: Slider(
                          min: 0.0,
                          max: 10.0,
                          divisions: 10,
                          value: meagslider,
                          onChanged: (meag) {
                            setState(() {
                              meagslider = meag;
                            });
                            entmeag = meag.round();
                            switch (entmeag) {
                              case 0:
                                strag = "]";
                                break;

                              case 1:
                                strag = '^';
                                break;

                              case 2:
                                strag = '_';
                                break;

                              case 3:
                                strag = '`';
                                break;

                              case 4:
                                strag = 'a';
                                break;

                              case 5:
                                strag = 'b';
                                break;

                              case 6:
                                strag = 'c';
                                break;

                              case 7:
                                strag = 'd';
                                break;

                              case 8:
                                strag = 'e';
                                break;

                              case 9:
                                strag = 'f';
                                break;

                              case 10:
                                strag = 'g';
                                break;

                              default:
                                break;
                            }
                            _sendMessage(strag);
                          },
                        ),
                      ),
                    )),
                Container(
                    margin: EdgeInsets.only(
                        left: 20.0, top: 20.0, right: 0, bottom: 10),
                    width: 60.0,
                    height: 380.0,
                    color: Colors.grey[600],
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.black87,
                          inactiveTrackColor: Colors.black26,
                          inactiveTickMarkColor: Colors.black26,
                          activeTickMarkColor: Colors.grey,
                          tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 3),
                          trackShape: RectangularSliderTrackShape(),
                          trackHeight: 4.0,
                          thumbColor: Colors.white,
                          thumbShape: CustomSliderThumbRect(
                              thumbHeight: 30, thumbRadius: 3, min: 0, max: 10),
                          overlayColor: Colors.blue.withAlpha(32),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 28.0),
                        ),
                        child: Slider(
                          min: 0.0,
                          max: 10.0,
                          divisions: 10,
                          //label: agslider.round().toString(),
                          value: agslider,
                          onChanged: (ag) {
                            setState(() {
                              agslider = ag;
                            });
                            entag = ag.round();
                            switch (entag) {
                              case 0:
                                strag = 'Q';
                                break;

                              case 1:
                                strag = 'R';
                                break;

                              case 2:
                                strag = 'S';
                                break;

                              case 3:
                                strag = 'T';
                                break;

                              case 4:
                                strag = 'U';
                                break;

                              case 5:
                                strag = 'V';
                                break;

                              case 6:
                                strag = 'W';
                                break;

                              case 7:
                                strag = 'X';
                                break;

                              case 8:
                                strag = 'Y';
                                break;

                              case 9:
                                strag = 'Z';
                                break;

                              case 10:
                                strag = '[';
                                break;

                              default:
                                break;
                            }
                            _sendMessage(strag);
                          },
                        ),
                      ),
                    )),
              ]),
              Row(children: <Widget>[
                Container(
                    margin: EdgeInsets.only(
                        left: 46, top: 0.0, right: 0.0, bottom: 10),
                    width: 80.0,
                    height: 40.0,
                    color: Colors.grey[400],
                    child: Text(
                      "LOW",
                      style: TextStyle(fontSize: 30, color: Colors.black),
                    )),
                Container(
                    margin: EdgeInsets.only(
                        left: 17.0, top: 0.0, right: 0.0, bottom: 10),
                    width: 80.0,
                    height: 40.0,
                    color: Colors.grey[400],
                    child: Text(
                      "MED",
                      style: TextStyle(fontSize: 30, color: Colors.black),
                    )),
                Container(
                    margin: EdgeInsets.only(
                        left: 10.0, top: 0.0, right: 0.0, bottom: 10),
                    width: 100.0,
                    height: 40.0,
                    color: Colors.grey[400],
                    child: Text(
                      "MED-HI",
                      style: TextStyle(fontSize: 30, color: Colors.black),
                    )),
                Container(
                    margin: EdgeInsets.only(
                        left: 8, top: 0.0, right: 0.0, bottom: 10),
                    width: 80.0,
                    height: 40.0,
                    color: Colors.grey[400],
                    child: Text(
                      "HIGH",
                      style: TextStyle(fontSize: 30, color: Colors.black),
                    ))
              ]),
              Divider(),
              Container(
                  color: Colors.grey[800],
                  height: 100.0,
                  width: 440.0,
                  child: Row(children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(10),
                      height: 40.0, //
                      width: 40.0,
                      child: FittedBox(
                        child: FloatingActionButton(
                          heroTag: "Mutear",
                          onPressed: () {
                            if (Volumen) {
                              _sendMessage('m');
                              Volumen = false;
                              oldvol = volslider;
                              volslider = 0;
                            } else {
                              entvol = oldvol.round();
                              strvol = entvol.toString();
                              if (entvol == 10) {
                                strvol = ':';
                              }
                              _sendMessage(strvol);
                              volslider = oldvol;
                              Volumen = true;
                            }
                          },
                          child: Icon(
                              Volumen ? Icons.volume_up : Icons.volume_off),
                          backgroundColor: Volumen ? Colors.green : Colors.red,
                        ),
                        //backgroundColor: Colors.red),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.all(0),
                        width: 305.0,
                        height: 60.0,
                        color: Colors.grey[800],
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.blue[700],
                            inactiveTrackColor: Colors.blue[100],
                            trackShape: RectangularSliderTrackShape(),
                            trackHeight: 10.0,
                            thumbColor: Colors.black,
                            thumbShape: CustomSliderThumbRect(
                                thumbHeight: 30,
                                thumbRadius: 3,
                                min: 0,
                                max: 10),
                            overlayColor: Colors.blue.withAlpha(32),
                            overlayShape:
                                RoundSliderOverlayShape(overlayRadius: 28.0),
                            //axis: Axis.vertical,
                          ),
                          child: Slider(
                            min: 0.0,
                            max: 10.0,
                            //divisions: 10,
                            value: volslider,
                            onChanged: (vol) {
                              setState(() {
                                volslider = vol;
                              });
                              entvol = vol.round();
                              strvol = entvol.toString();
                              if (entvol == 10) {
                                strvol = ':';
                              }
                              if (entvol > 0) {
                                Volumen = true;
                                oldvol = vol;
                              } else {
                                Volumen = false;
                              }
                              _sendMessage(strvol);
                            },
                          ),
                        )),
                  ])),
              Container(
                  margin: EdgeInsets.all(20.0),
                  child: Text(
                    "Proyecto Final UTN-FRC-Electrónica",
                    style: TextStyle(fontSize: 20),
                  )),
            ],
          )),
    );
  }

  void _onDataReceived(Uint8List data) {
    int opint = 1000;
    double op = 1000;
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      //Actualizar pantalla
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }

      opint = data[i] - 48;
      op = opint.toDouble();
      if (op >= 0 && op < 11) {
        volslider = op;
        if (op == 0) {
          Volumen = false;
        } else {
          oldvol = op;
          Volumen = true;
        }
      } else if (op > 10 && op < 22) {
        grslider = op - 11;
        setState(() {});
      } else if (op > 21 && op < 33) {
        meslider = op - 22;
      } else if (op > 32 && op < 44) {
        agslider = op - 33;
      } else if (op > 44 && op < 57) {
        debugPrint(op.toString());
        meagslider = op - 46;
      } else {
        op = 1000;
      }
    }
    return;
    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    debugPrint("{$text}");
    text = text.trim();
    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        debugPrint("ERRRRRRRRRRRROOOOOOOOOOOOOOOOOOOOOOOR");
        setState(() {});
      }
    }
  }
}

class CustomSliderThumbRect extends SliderComponentShape {
  final double thumbRadius;
  final thumbHeight;
  final int min;
  final int max;

  const CustomSliderThumbRect({
    this.thumbRadius,
    this.thumbHeight,
    this.min,
    this.max,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
  }) {
    final Canvas canvas = context.canvas;

    final rRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: center, width: thumbHeight * .8, height: thumbHeight * 1.2),
      Radius.circular(thumbRadius * .4),
    );

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    TextSpan span = new TextSpan(
        style: new TextStyle(
            fontSize: thumbHeight * .5,
            fontWeight: FontWeight.w700,
            color: Colors.black, //sliderTheme.thumbColor,
            height: 0.9),
        text: '|'); //'${getValue(value)}');
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter =
        Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));
    canvas.drawRRect(rRect, paint);
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) {
    return ((max) * (value)).round().toString();
  }
}
