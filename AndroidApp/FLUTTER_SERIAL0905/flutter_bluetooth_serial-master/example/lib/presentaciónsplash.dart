import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'MainPage.dart';
import 'dart:ui';


class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ecualizador de Audio'),
        centerTitle: true,
       /* leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Image.asset(
            "images/LogoUTN.png",
          ),
        ),*/
      ),
      body: new Stack(children: <Widget>[
        Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/Caratula.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        )
      ]),
    );
  }
}
