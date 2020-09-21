import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:vector_math/vector_math_64.dart';
import 'game.dart';
import 'worldMap.dart';

class Camera {
  static const int MaxScale = 4;
  double x;
  double y;
  double scale = 1;

  final BattleCaptain game;
  double get width => game.screenSize?.width ?? 0;
  double get height => game.screenSize?.height ?? 0;
  Offset scalePoint = Offset.zero;
  int startCol;
  int endCol;
  int startRow;
  int endRow;
  int offsetX;
  int offsetY;

  Camera(this.game, {this.x = 0, this.y = 0}) {
    moveToPoint(x, y);
  }

  double scaleValue(double value) => value * scale;

  void moveByAndScale(double xDelta, double yDelta, double newScale) {
    changeScale(newScale, changeCam: false);
    moveToPoint(x + xDelta, y + yDelta);
  }

  double _toSafeScale(double newScale) =>
      max(min(MaxScale.toDouble(), newScale), 1);

  void changeScale(double newScale, {bool changeCam = true}) {
    if (newScale == scale) return;
    scale = _toSafeScale(newScale);
    if (changeCam) moveToPoint(x, y);
  }

  void moveBy(double xDelta, double yDelta) {

    xDelta = xDelta / scale;
    yDelta = yDelta / scale;

    moveToPoint(x + xDelta, y + yDelta);
  }

  Matrix4 getMagic() {
    /*
    final scaleMatrix = Matrix4.diagonal3(scaleVec);
    final originTranslationMatrix = Matrix4.translation(originTranslation);
    final originTranslationBackMatrix = Matrix4.translation(originTranslationBack);
    final rotationMatrix = Matrix4.rotationZ(rotationDeg);
    final translationMatrix = Matrix4.translation(translation);

    final transformationMatrix = translationMatrix * originTranslationBackMatrix * rotationMatrix * originTranslationMatrix * scaleMatrix;

    //debugPrint("Position: X: $x Y: $y");
    //return Matrix4.compose(translation, rotation, scaleVec);
    return transformationMatrix;
    */
    final screenCenter = game.screenRect.bottomRight;
    final zeroOffset = Offset.zero;
    final oneOffset = Offset(1, 1);
    final transform = Matrix4Transform()
      .translate(x: x.toDouble(), y: y.toDouble())
      .rotateDegrees(0, origin: scalePoint)
      .scaleBy(x: 1 / scale, y: 1 / scale, origin: scalePoint);

    return transform.matrix4;
  }

  Vector2 screenToWorld(Vector3 screen) {
     screen.applyMatrix4(getMagic());
     return Vector2(screen.x,screen.y);
  }

  Vector2 worldToScreen(Vector3 world) {
    final Matrix4 viewportMatrixInverted = new Matrix4.zero();
    viewportMatrixInverted.copyInverse(getMagic());
    world.applyMatrix4(viewportMatrixInverted);
    return Vector2(world.x,world.y);
  }

  void moveToPoint(double x, double y) {
  
   
    this.x = x;
    this.y = y;
  /*  startCol = (x / scaleValue(WorldMap.TileSize)).floor();
    endCol = max(WorldMap.MapSize.toInt(),
        startCol + (width / scaleValue(WorldMap.TileSize)).floor() + 1);
    startRow = (y / scaleValue(WorldMap.TileSize)).floor();
    endRow = max(WorldMap.MapSize.toInt(),
        startRow + (height / scaleValue(WorldMap.TileSize)).floor() + 1);
    offsetX = (-x + startCol * scaleValue(WorldMap.TileSize)).floor();
    offsetY = (-y + startRow * scaleValue(WorldMap.TileSize)).floor();
    */
  }

  void render(Canvas c) {}
}
