import 'dart:math';
import 'package:doodle_dash/game/managers/game_manager.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import '../managers/InGameConst.dart';
import '../managers/GameManagerVariables.dart';

class PhysObject {
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
  bool boundNet = false;
  Vector2 size = Vector2(100, 100);
  Vector2 position = Vector2(0, 0);

  Init(Vector2 _size) {
    // 사이즈 지정.
    size = _size;
    landY = InGameConst.landY - size.y / 2; // 사이즈보다 조금 더 크게 landY 초기화
    PutInitDataToManager();
  }

  double abs(double x) {
    if (x < 0)
      return -x;
    else
      return x;
  }

  void startParabola(Vector2 startPos, double startSpeed, double direction) {
    if (startPos.y > landY) startPos.y = landY;

    if (abs(startPos.x - InGameConst.netX) <= 22 && boundNet) {
      if (startSpeed * cos(direction) > 0)
        startPos.x = InGameConst.netX + 22;
      else
        startPos.x = InGameConst.netX - 22;

      boundNet = false;
    }

    this.startPos = startPos;
    this.speed = startSpeed;
    this.direction = direction;

    endPos = getParabolaEnd(this.startPos, this.direction, this.speed);
    physStartTime = InGameConst.globalTime;
    physEndTime = physStartTime + getPhysEndTime();

    // print("physStartTime : ${physStartTime} , physEndTime ${physEndTime}");
    checkHitObject(); // 지금의 공 궤도로 다음 오브젝트에 언제 부딪힐지 계산한다.
    PutAllDataToManager();
  }

  // 언제 벽에 도달할지 계산하는 함수를 작성 한다.
  void checkHitObject() {
    double hs = speed * cos(direction);
    boundTime = InGameConst.INF;
    double newBoundTime = InGameConst.INF;
    if (endPos.x > InGameConst.windowSizeX) {
      // 공의 끝지점이 화면 끝보다 클 경우.
      // 화면 끝에 도달하는데 걸리는 시간 계산
      double takeTimeToRightWall =
          (InGameConst.windowSizeX - size.x / 2 - startPos.x) / hs;

      newBoundTime =
          InGameConst.globalTime + takeTimeToRightWall; // 이 시간 이후에 부딪힌다.
      if (newBoundTime < boundTime) {
        SetBoundTime(newBoundTime, 0.7, 90); // 1의 강도로 90도 벽에 부딪힌다.
      }
    } else if (endPos.x < 0) {
      // 공의 끝지점이 화면 끝보다 클 경우.
      // 화면 끝에 도달하는데 걸리는 시간 계산
      double takeTimeToLeftWall = (size.x / 2 - startPos.x) / hs;
      newBoundTime = InGameConst.globalTime + takeTimeToLeftWall;
      if (newBoundTime < boundTime) {
        SetBoundTime(newBoundTime, 0.7, 90);
      }
    }
    if ((startPos.x <= endPos.x &&
            InGameConst.netX >= startPos.x &&
            InGameConst.netX <= endPos.x) ||
        (startPos.x > endPos.x &&
            InGameConst.netX >= endPos.x &&
            InGameConst.netX <= startPos.x)) {
      double hs = cos(direction) * speed;
      double time = (InGameConst.netX - startPos.x) / hs;

      if (getNowPos(physStartTime + time).y >= InGameConst.netY) {
        // 네트보다 낮게 있으면.
        if (physStartTime + time < boundTime) {
          SetBoundTime(physStartTime + time, 1, 90, boundNet: true);
        }
      }
    }
    if (physEndTime < boundTime) {
      SetBoundTime(physEndTime, 0.9, 0);
    }
    print("boundTime : ${boundTime} ,${physEndTime} , boundDir ${boundDir}");
  }

  void SetBoundTime(double boundTime, double boundIntense, double boundDir,
      {bool boundNet = false}) {
    this.boundTime = boundTime;
    this.boundIntense = boundIntense;
    this.boundDir = boundDir;
    this.boundNet = boundNet;
  }

  double getFlightMaxHeight(Vector2 startPos, double direction, double speed) {
    double vs = sin(direction) * speed;
    return (landY - startPos.y) + pow(vs, 2) / (2 * InGameConst.gravity);
  }

  //현재 위치를 계산 한다.
  Vector2 getNowPos(double globalTime) {
    double vs = -speed * sin(direction); // vs값을 flip한다. (y 좌표계가 다르므로.)
    double hs = speed * cos(direction);
    double nowTime =
        (globalTime - physStartTime) / (physEndTime - physStartTime);
    if (nowTime >= 1) nowTime = 1;
    double changedX = (endPos.x - startPos.x) * nowTime;
    double changedY = changedX * (vs / hs) +
        0.5 * InGameConst.gravity * pow(changedX / hs, 2);
    SetNowDirection(startPos.x + changedX - position.x,
        startPos.y + changedY - position.y); // (현재 x,y변화량을 통해 각도를 계산 한다.)
    return Vector2(startPos.x + changedX, startPos.y + changedY);
  }

  //현재 포물선 이동의 종료 시간을 계산 한다.
  double getPhysEndTime() {
    double hs = speed * cos(direction);
    return (endPos.x - startPos.x) / hs;
  }

  double GetHS() {
    return speed * cos(direction);
  }

  double GetVS() {
    return speed * sin(direction);
  }

  //현재 움직임 변화에 따른 각도를 저장한다.
  void SetNowDirection(double changedX, double changedY) {
    //라디안 각도로 변환
    nowDirection = atan2(-changedY, changedX);
  }

  // 현재 포물선 이동의 이동 시간을 계산 한다.
  double getFlightMaxTime(Vector2 startPos, double direction, double speed) {
    double flightMaxHeight = getFlightMaxHeight(startPos, direction, speed);
    double vs = sin(direction) * speed;
    // print(
    //     "flightMaxHeight ${flightMaxHeight} time : ${(vs / InGameConst.gravity) + sqrt(2 * flightMaxHeight / InGameConst.gravity)}");
    return (vs / InGameConst.gravity) +
        sqrt(2 * flightMaxHeight / InGameConst.gravity);
  }

  // 현재 포물선 이동의 종료 지점을 계산 한다.
  Vector2 getParabolaEnd(Vector2 startPos, double direction, double speed) {
    double hs = cos(direction) * speed;
    double T = getFlightMaxTime(startPos, direction, speed);

    double endPosX = startPos.x + hs * T;
    double endPosY = landY;
    return Vector2(endPosX, endPosY);
  }

  //부딪힌 각도를 입력하면, 현재 각도에서 해당 각도를 기준으로 어느 방향으로 튕길지 결정한다.
  double BoundDirection(double WallAngle) {
    double dir = InGameConst.GetDegreeDirection(nowDirection);
    double reflectAngle = WallAngle - (dir - WallAngle);
    return reflectAngle; // 튕길 각도.
  }

  void CheckBoundTime() {
    if (InGameConst.globalTime > boundTime) {
      if (boundNet) {
        // boundNet에 의해서일 경우.
        if (startPos.x < InGameConst.netX) {
        } else {}
      }
      // 바운드 시간이 지날 경우.
      BoundBall(boundDir, boundIntense);
    }
  }

  void ForceBall(double forcedSpeed, double forcedDirection) {
    forcedDirection = InGameConst.GetRadianDirection(forcedDirection);
    double forceHS = cos(forcedDirection) * forcedSpeed;
    double forceVS = sin(forcedDirection) * forcedSpeed;
    double originalHS = cos(nowDirection) * speed;
    double originalVS = sin(nowDirection) * speed;

    double newHS = (forceHS - originalHS * 0.1);
    double newVS = (forceVS - originalVS * 0.1);
    double newSpeed = sqrt(pow(newHS, 2) + pow(newVS, 2));
    double newDirection = atan2(newVS, newHS);
    print("originalHS${originalHS} , originalVS${originalVS}");
    print(
        "forceHS : ${forceHS} forceVS ${forceVS} , newSpeed ${newSpeed} newDirection ${InGameConst.GetDegreeDirection(newDirection)}");
    startParabola(getNowPos(InGameConst.globalTime), newSpeed, newDirection);
  }

  void BoundBall(double wallAngle, double intense) {
    double newDirection = BoundDirection(wallAngle); // 바운드 각도 지정.
    boundTime = InGameConst.INF; // 바운드 시간 초기화.
    startParabola(getNowPos(InGameConst.globalTime), speed * intense,
        InGameConst.GetRadianDirection(newDirection)); // 바운드 시작.
  }

  void PutAllDataToManager() {
    //언제 튕길지.
    GameManagerVariables.ball_boundDir = boundDir;
    GameManagerVariables.ball_boundIntense = boundIntense;
    GameManagerVariables.ball_boundTime = boundTime;
    GameManagerVariables.ball_boundNet = boundNet;

    //시작 물리값
    GameManagerVariables.ball_direction = direction;
    GameManagerVariables.ball_endPos = endPos;
    GameManagerVariables.ball_startPos = startPos;
    GameManagerVariables.ball_physEndTime = physEndTime;
    GameManagerVariables.ball_physStartTime = physStartTime;
  }

  void PutInitDataToManager() {
    //시작 물리 값
    GameManagerVariables.ball_landY = landY;
    GameManagerVariables.ball_size = size;
  }

  void PutNowDataToManager() {
    //현재 물리값
    GameManagerVariables.ball_nowDirection = nowDirection;
    GameManagerVariables.ball_position = position;
  }

  Vector2 UpdatePosition(double time) {
    position = getNowPos(InGameConst.globalTime);
    PutNowDataToManager();
    return position;
  }
}
