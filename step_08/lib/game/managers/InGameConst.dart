import 'package:flame/components.dart';

class InGameConst {
  // 상수 정의
  static const double landY = 780; // 땅 높이.
  static const double gravity = 14;
  static double globalTime = 0;
  static double timeFlowSpeed = 5;
  static double netX = 2333 / 2;
  static double netY = 400;
  static double windowSizeX = 2333;
  static double windowSizeY = 720;
  static double INF = 999999990;

  static double GetDegreeDirection(double radian) {
    return radian * 180 / 3.141592;
  }

  static double GetRadianDirection(double degree) {
    //각도를 완전 90도가 되지 않도록.
    if (degree == 90) degree = 90.1;
    if (degree == 270) degree = 270.1;

    return degree * 3.141592 / 180;
  }

  static bool IsCollisionRectangle(
      Vector2 obj1, Vector2 objSize, Vector2 obj2, Vector2 obj2Size) {
    if (obj1.x + objSize.x < obj2.x) return false;
    if (obj1.x > obj2.x + obj2Size.x) return false;
    if (obj1.y + objSize.y < obj2.y) return false;
    if (obj1.y > obj2.y + obj2Size.y) return false;
    return true;
  }
}
