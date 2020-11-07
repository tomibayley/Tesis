import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

var Volumen = true;
var _value = 5.0,
    _value2 = 5.0,
    _value3 = 5.0,
    _value4 = 5.0,
    vol = 5.0,
    med = 5.0,
    ag = 5.0,
    gr = 5.0,
    oldvol = vol;

var entvol = 0;
var strvol = "0";
var entag = 0;
var strag = "0";
var entmed = 0;
var strmed = "0";
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
  var _currentItemSelected = 'Jazz';
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
              ? Text('Conectandose al ' + widget.server.name + '...')
              : isConnected
              ? Text('Ecualizador Conectado ')
              : Text('DESCONECTADO!'))),
      body: Container(
          margin: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Text(
                "Volumen",
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 40.0,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic),
              ),
              Row(

                  children:<Widget>[
                    Container(
                      height: 40.0, //PONEREN80
                      width: 40.0,
                      child: FittedBox(
                        child: FloatingActionButton(
                          heroTag: "Mutear",
                          onPressed: () {
                            if (Volumen) {
                              _sendMessage('m');
                              Volumen = false;
                              oldvol = _value;
                              _value = 0;
                            } else {
                              entvol = oldvol.toInt();
                              strvol = entvol.toString();
                              if (entvol == 10) {
                                strvol = ':';
                              }
                              _sendMessage(strvol);
                              _value = oldvol;
                              Volumen = true;
                            }
                          },
                          child:
                          Icon(Volumen ? Icons.volume_up : Icons.volume_off),
                          backgroundColor: Volumen ? Colors.green : Colors.red,
                        ),
                        //backgroundColor: Colors.red),
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.blue[700],
                        inactiveTrackColor: Colors.blue[100],
                        trackShape: RectangularSliderTrackShape(),
                        trackHeight: 4.0,
                        thumbColor: Colors.blueAccent,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                        overlayColor: Colors.blue.withAlpha(32),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                        //axis: Axis.vertical,
                      ),
                      child: Slider(
                        min: 0.0,
                        max: 10.0,
                        //divisions: 10,
                        value: _value,
                        onChanged: (vol) {
                          setState(() {
                            _value = vol;
                          });
                          entvol = vol.toInt();
                          strvol = entvol.toString();
                          if (entvol == 10) {
                            strvol = ':';
                          }
                          if (entvol > 0) {
                            Volumen = true;
                            oldvol=vol;
                          } else {
                            Volumen = false;
                          }
                          _sendMessage(strvol);
                        },
                      ),
                    ),]),
              Divider(),
              Text(
                "Agudos",
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 40.0,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.red[700],
                  inactiveTrackColor: Colors.red[100],
                  trackShape: RectangularSliderTrackShape(),
                  trackHeight: 4.0,
                  thumbColor: Colors.redAccent,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                  overlayColor: Colors.red.withAlpha(32),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                ),
                child: Slider(
                  min: 0.0,
                  max: 10.0,
                  value: _value2,
                  onChanged: (ag) {
                    setState(() {
                      _value2 = ag;
                    });
                    entag = ag.toInt();
                    switch (entag) {
                      case 0:
                        strag = ';';
                        break;

                      case 1:
                        strag = '<';
                        break;

                      case 2:
                        strag = '=';
                        break;

                      case 3:
                        strag = '>';
                        break;

                      case 4:
                        strag = '?';
                        break;

                      case 5:
                        strag = '@';
                        break;

                      case 6:
                        strag = 'A';
                        break;

                      case 7:
                        strag = 'B';
                        break;

                      case 8:
                        strag = 'C';
                        break;

                      case 9:
                        strag = 'D';
                        break;

                      case 10:
                        strag = 'E';
                        break;

                      default:
                        break;
                    }
                    _sendMessage(strag);
                  },
                ),
              ),
              Divider(),
              Text(
                "Medios",
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 40.0,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.green[700],
                  inactiveTrackColor: Colors.green[100],
                  trackShape: RectangularSliderTrackShape(),
                  trackHeight: 4.0,
                  thumbColor: Colors.greenAccent,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                  overlayColor: Colors.green.withAlpha(32),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                ),
                child: Slider(
                  min: 0.0,
                  max: 10.0,
                  value: _value3,
                  onChanged: (med) {
                    setState(() {
                      _value3 = med;
                    });
                    entmed = med.toInt();
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
              Divider(),
              Text(
                "Graves",
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 40.0,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.blue[700],
                  inactiveTrackColor: Colors.blue[100],
                  trackShape: RectangularSliderTrackShape(),
                  trackHeight: 4.0,
                  thumbColor: Colors.blueAccent,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                  overlayColor: Colors.blue.withAlpha(32),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                ),
                child: Slider(
                  min: 0.0,
                  max: 10.0,
                  value: _value4,
                  onChanged: (gr) {
                    setState(() {
                      _value4 = gr;
                    });
                    entgr = gr.toInt();
                    switch (entgr) {
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
              Divider(),
              Row(
                children: <Widget>[
                  ///////////////////////COLUMNAS
                  Container(
                      margin: EdgeInsets.all(15.0),
                      width: 100.0,
                      height: 60.0,
                      child: RaisedButton(
                          child: const Text('Jazz',
                              style: TextStyle(
                                fontSize: 35.0,
                              )),
                          onPressed: () {
                            _sendMessage(strjazz);
                            _value2 = 5;
                            _value3 = 5;
                            _value4 = 5;
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ))),
                  Container(
                      margin: EdgeInsets.all(15.0),
                      width: 100.0,
                      height: 60.0,
                      child: RaisedButton(
                          child: Text('Rock',
                              style: TextStyle(
                                fontSize: 35.0,
                              )),
                          onPressed: () {
                            _sendMessage(strRock);
                            _value2 = 5;
                            _value3 = 5;
                            _value4 = 5;
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ))),
                  Container(
                      margin: EdgeInsets.all(15.0),
                      width: 100.0,
                      height: 60.0,
                      child: RaisedButton(
                          child: const Text('Pop',
                              style: TextStyle(
                                fontSize: 35.0,
                              )),
                          onPressed: () {
                            _sendMessage(strPop);
                            _value2 = 5;
                            _value3 = 5;
                            _value4 = 5;
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          )))
                ],
              ),
              Divider(),
              /*Row(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 160, top: 30.0),
                  child: Container(
                    height: 80.0, //PONEREN80
                    width: 80.0,
                    child: FittedBox(
                      child: FloatingActionButton(
                        heroTag: "Mutear",
                        onPressed: () {
                          if (Volumen) {
                            _sendMessage('m');
                            Volumen = false;
                            oldvol = _value;
                            _value = 0;
                          } else {
                            entvol = oldvol.toInt();
                            strvol = entvol.toString();
                            if (entvol == 10) {
                              strvol = ':';
                            }
                            _sendMessage(strvol);
                            _value = oldvol;
                            Volumen = true;
                          }
                        },
                        child:
                            Icon(Volumen ? Icons.volume_up : Icons.volume_off),
                        backgroundColor: Volumen ? Colors.green : Colors.red,
                      ),
                      //backgroundColor: Colors.red),
                    ),
                  ),
                ),
              ])*/
            ],
          )),
    );
  }

  /* COMO ENVIAR
   icon: const Icon(Icons.send),
                      onPressed: isConnected
                          ? () => _sendMessage("1")
                          : null),
   */

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
      // _value=2;
      if (op >= 0 && op < 11) {
        _value = op;
        if (op == 0) {
          Volumen = false;
        } else {
          oldvol = op;
          Volumen = true;
        }
      } else if (op > 10 && op < 22) {
        _value2 = op - 11;
      } else if (op > 21 && op < 33) {
        _value3 = op - 22;
      } else if (op > 32 && op < 44) {
        _value4 = op - 33;
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
        setState(() {});
      }
    }
  }
}
