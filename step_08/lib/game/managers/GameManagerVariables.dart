import 'package:flame/components.dart';
import './InGameConst.dart';

class GameManagerVariables {
  static double ball_landY = 0;
  static double ball_speed = 0;
  static double ball_physStartTime = 0;
  static double ball_physEndTime = 0;
  static Vector2 ball_startPos = Vector2(0, 0);
  static Vector2 ball_endPos = Vector2(0, 0);
  static double ball_direction = 0;
  static double ball_nowDirection = 0;
  static double ball_boundDir = 0;
  static double ball_boundTime = InGameConst.INF;
  static double ball_boundIntense = 1;
  static bool ball_boundNet = false;
  static Vector2 ball_size = Vector2(100, 100);
  static Vector2 ball_position = Vector2(0, 0);
}
