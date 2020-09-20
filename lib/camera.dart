import 'dart:math';
import 'package:flutter/widgets.dart';
import 'game.dart';
import 'worldMap.dart';

class Camera {
  static const int MaxScale = 4;
  int x;
  int y;
  double scale = 1;

  final BattleCaptain game;
  double get width => game.screenSize?.width ?? 0;
  double get height => game.screenSize?.height ?? 0;

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

  void moveByAndScale(int xDelta, int yDelta, double newScale) {
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

  void moveBy(int xDelta, int yDelta) {
    moveToPoint(x + xDelta, y + yDelta);
  }

  void moveToPoint(int x, int y) {
    if (x < 0) {
      x = 0;
    }
    if (y < 0) {
      y = 0;
    }
    final maxX =
        (scaleValue(WorldMap.TileSize) * WorldMap.MapSize - width).floor();
    final maxY =
        (scaleValue(WorldMap.TileSize) * WorldMap.MapSize - height).floor();
    if (x > maxX) {
      if (maxX < 0) {
        //the map is smaller as screen show left and right an equal part of background
        x = (maxX * 0.5).floor();
      } else {
        x = maxX;
      }
    }
    if (y > maxY) {
      if (maxY < 0) {
        //the map is smaller as screen show above and below an equal part of background
        y = (maxY * 0.5).floor();
      } else {
        y = maxY;
      }
    }
    this.x = x;
    this.y = y;
    startCol = (x / scaleValue(WorldMap.TileSize)).floor();
    endCol = max(WorldMap.MapSize.toInt(),
        startCol + (width / scaleValue(WorldMap.TileSize)).floor() + 1);
    startRow = (y / scaleValue(WorldMap.TileSize)).floor();
    endRow = max(WorldMap.MapSize.toInt(),
        startRow + (height / scaleValue(WorldMap.TileSize)).floor() + 1);
    offsetX = (-x + startCol * scaleValue(WorldMap.TileSize)).floor();
    offsetY = (-y + startRow * scaleValue(WorldMap.TileSize)).floor();
  }

  void render(Canvas c) {}
}
