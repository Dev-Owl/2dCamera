import 'game.dart';

class BetterCamera
{

  final BattleCaptain game;

  BetterCamera(this.game);
  double get width => game.screenSize?.width ?? 0;
  double get height => game.screenSize?.height ?? 0;

}