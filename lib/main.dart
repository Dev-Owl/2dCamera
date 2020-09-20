import 'package:BattleCaptain_Map/game.dart';
import 'package:flame/util.dart';
import 'package:flutter/material.dart';

Util flameUtil;


void main() async {
  await setupFlame();
  runApp(MyApp());
}

Future setupFlame() async {
  WidgetsFlutterBinding.ensureInitialized(); //Since flutter upgrade this is required
  flameUtil = Util();
  await flameUtil.fullScreen();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      initialRoute: '/play',
      debugShowCheckedModeBanner: false,
      routes: {
        '/play':(context){
          return GameWidget();
        }
      },
    );
  }
}


