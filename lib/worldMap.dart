import 'dart:math';
import 'dart:ui';

import 'package:BattleCaptain_Map/game.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';

class WorldMap {
  static const double MapSize = 17;
  static const double TileSize = 32;
  final List<Sprite> waterTiles = List<Sprite>();
  final BattleCaptain game;

  WorldMap(this.game);

  Future initMap() async {
    for (var y = 0; y < 3; ++y) {
      for (var x = 0; x < 3; ++x) {
        waterTiles.add(await Sprite.loadSprite('water_tileset.png',
            x: x * TileSize,
            y: y * TileSize,
            height: TileSize,
            width: TileSize));
      }
    }
  }

  Sprite getTile(int column, int row) {
    return waterTiles[min(column, 8)];
  }

  void render(Canvas canvas) {
    final cam = game.camera;
    for (var c = cam.startCol; c <= cam.endCol; c++) {
      for (var r = cam.startRow; r <= cam.endRow; r++) {
        if (c >= 0 && c < MapSize && r >= 0 && r < MapSize) {
          var tile = getTile(c, r);
          var x = (c - cam.startCol) * cam.scaleValue(TileSize) + cam.offsetX;
          var y = (r - cam.startRow) * cam.scaleValue(TileSize) + cam.offsetY;
          tile.renderPosition(canvas, Position.fromInts(x.floor(), y.floor()),
              size: Position(TileSize * cam.scale, TileSize * cam.scale));
        }
      }
    }
  }
}
