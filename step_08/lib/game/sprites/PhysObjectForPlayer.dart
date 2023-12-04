import 'dart:math';
import 'package:doodle_dash/game/sprites/PhysObject.dart';
import 'package:flame/components.dart';
import '../managers/InGameConst.dart';

class PhysObjectForPlayer extends PhysObject {
  double landY = 0;
  double speed = 0;
  double physStartTime = 0;
  double physEndTime = 0;
  Vector2 startPos = Vector2(0, 0);
  Vector2 endPos = Vector2(0, 0);
  double direction = 0;
  double nowDirection = 0;
  double boundDir = 0;
  double boundTime = InGameConst.INF;
  double boundIntense = 1;
  Vector2 size = Vector2(100, 100);
  Vector2 position = Vector2(0, 0);

  double linearSpeed = 0;

  Init(Vector2 _size) {
    print("SIZE : ${size}");
    // 사이즈 지정.
    size = _size;
    landY = InGameConst.landY - size.y / 2; // 사이즈보다 조금 더 크게 landY 초기화
  }

  @override
  void startParabola(Vector2 startPos, double startSpeed, double direction) {
    if (startPos.y > landY) startPos.y = landY;
    this.startPos = startPos;
    this.speed = startSpeed;
    this.direction = direction;

    endPos = getParabolaEnd(this.startPos, this.direction, this.speed);
    physStartTime = InGameConst.globalTime;
    physEndTime = physStartTime + getPhysEndTime();
  }

  bool IsEndParabola() {
    if (InGameConst.globalTime > physEndTime) {
      return true;
    } else
      return false;
  }

  Vector2 UpdatePlayer(double dt, double time) {
    startPos.x += linearSpeed * dt * InGameConst.timeFlowSpeed;
    endPos.x += linearSpeed * dt * InGameConst.timeFlowSpeed;
    position = getNowPos(InGameConst.globalTime);
    return position;
  }

  void Jump(double _jp) {
    if (IsEndParabola()) {
      print("${getNowPos(InGameConst.globalTime)}");
      startParabola(getNowPos(InGameConst.globalTime), _jp,
          InGameConst.GetRadianDirection(90));
    }
  }

  void linearMove(double speed) {
    linearSpeed = speed;
  }
}
