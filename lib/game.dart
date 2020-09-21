import 'dart:math';
import 'dart:ui';
import 'package:BattleCaptain_Map/worldMap.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wakelock/wakelock.dart';

import 'camera.dart';

class GameWidget extends StatefulWidget {
  @override
  _GameWidgetState createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  BattleCaptain game;

  _GameWidgetState() {
    game = new BattleCaptain();
  }

  @override
  void initState() {
    super.initState();
    game.pop = () {
      Navigator.pop(context);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        game.widget,
      ]),
    );
  }
}

class BattleCaptain extends Game with TapDetector, ScaleDetector {
  final bgPainter = Paint();
  //Scale factore for our world
  final int scale = 2;
  //Size of the screen from the resize event
  Size screenSize;
  //Rectangle based on the size, easy to use
  Rect _screenRect;
  Rect get screenRect => _screenRect;
  bool pauseGame = false;
  bool blockResize = false;
  bool ready = false;

  Camera camera;
  WorldMap map;
  BattleCaptain() {
    initialize();
  }

  //Initialize all things we need, devided by things need the size and things without
  Future initialize() async {
    bgPainter.color = Color(0xFF0050d1);
    //Call the resize as soon as flutter is ready
    resize(await Flame.util.initialDimensions());
    camera = Camera(this);
    map = WorldMap(this);
    await map.initMap();
    ready = true;
    
  }

  void resize(Size size) {
    if (blockResize && screenSize != null) {
      return;
    }
    //Store size and related rectangle
    screenSize = size;
    _screenRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    //This should reset the cam
    camera?.moveBy(0, 0);
    super.resize(size);
  }

  @override
  void render(Canvas canvas) {
    if (!ready) {
      return;
    }
    //If no size information -> leave
    if (screenSize == null || pauseGame) {
      return;
    }
    canvas.drawRect(screenRect, bgPainter);
    map.render(canvas);
  }

  @override
  void update(double t) {
    if (!ready) {
      return;
    }
    if (screenSize == null || pauseGame) {
      return;
    }
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      pauseGame = true;
      Wakelock.disable();
    } else {
      Wakelock.enable();
      pauseGame = false;
    }
  }

  Function() pop;
  
  var lastTapDown = 0;

  //The default double tap doesnt have a position, so the below is a "self made" double tap
  @override
  void onTapDown(TapDownDetails details) {
    var now = DateTime.now().millisecondsSinceEpoch;
    debugPrint(details.globalPosition.toString());
    if (now - lastTapDown < 250) {
      debugPrint('double tap');
      camera.scalePoint = details.globalPosition;
      
      camera.changeScale(max(1, (camera.scale + 1) % (Camera.MaxScale + 1)));
    }
    lastTapDown = now;
  }

  Offset _referencePoint;
  double _prevScale;

  @override
  void onScaleStart(ScaleStartDetails details) {
    _referencePoint = details.focalPoint;
    _prevScale = 1;
  }

  @override
  void onScaleEnd(ScaleEndDetails details) {
    _prevScale = null;
  }

  @override
  void onScaleUpdate(ScaleUpdateDetails details) {
    if (!ready) {
      return;
    }
    final delta = _referencePoint - details.focalPoint;
    _referencePoint = details.focalPoint;
    //Slow down the zoom to a max speed for both in/out zoom
    var scaleDiff = (details.scale - _prevScale);
    if (scaleDiff.abs() > 0.03) {
      scaleDiff = scaleDiff.isNegative ? -0.03 : 0.03;
    }
    if (scaleDiff != 0) {
      camera.scalePoint = details.focalPoint;
      camera.changeScale(camera.scale + scaleDiff);
    } else {
      camera.moveBy(delta.dx, delta.dy);
    }
  }
}
