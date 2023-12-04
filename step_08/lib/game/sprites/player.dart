// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';
import 'package:doodle_dash/game/sprites/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import '../managers/InGameConst.dart';
import '../doodle_dash.dart';
import 'sprites.dart';
import './PhysObjectForPlayer.dart';
import '../managers/GameManagerVariables.dart';

enum PlayerState { sit, hit, idle, walk }

class Player extends SpriteGroupComponent<PlayerState>
    with HasGameRef<AnimalVolleyball>, KeyboardHandler, CollisionCallbacks {
  PhysObjectForPlayer physObject = PhysObjectForPlayer();
  final int movingLeftInput = -1;
  final int movingRightInput = 1;
  Vector2 _velocity = Vector2.zero();
  bool get isMovingDown => _velocity.y > 0;
  Character character;
  bool isLand = false;
  bool leftSide = false;
  bool nowMove = false;
  int faceDir = 1;
  double moveSpeed = 100;
  bool jumpReady = false;
  double maxJumpPower = 100;
  double hitDelayTime = 0;
  double nowJumpPower = 0;
  double elapsedTime = 0;
  Ball ball = Ball(Vector2(0, 0));
  SpriteAnimationComponent? pop;
  Player({
    required this.ball,
    required this.pop,
    super.position,
    required this.character,
    this.leftSide = false,
    current = PlayerState.idle,
  }) : super(
          size: Vector2(79, 109),
          anchor: Anchor.center,
          priority: 1,
        ) {
    physObject = new PhysObjectForPlayer();
    physObject.Init(size);
    if (leftSide) {
      physObject.startParabola(
          Vector2(112, 680), 20, InGameConst.GetRadianDirection(45));
    } else {
      physObject.startParabola(
          Vector2(1342, 680), 20, InGameConst.GetRadianDirection(45));
    }
  }
  double abs(double x) {
    if (x < 0)
      return -x;
    else
      return x;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(CircleHitbox());
    await _loadCharacterSprites();
    current = PlayerState.idle;
  }

  @override
  void update(double dt) {
    elapsedTime += dt;
    scale.x = (2 + sin(elapsedTime * 2) * 0.05) * faceDir;
    scale.y = (2 + cos(elapsedTime * 2) * 0.05);
    position = physObject.UpdatePlayer(dt, InGameConst.globalTime);
    ReadyJump(dt);
    super.update(dt);
    if (hitDelayTime > InGameConst.globalTime) {
      elapsedTime += 7 * dt;
      scale.x = (2 + cos(elapsedTime * 2) * 0.35) * faceDir;
      scale.y = (2 + sin(elapsedTime * 2) * 0.4);
      current = PlayerState.hit;
    } else if (jumpReady) {
      current = PlayerState.sit;
    } else if (nowMove && !physObject.IsEndParabola()) {
      current = PlayerState.walk;
    } else {
      if (nowMove) elapsedTime += dt * 10;
      current = PlayerState.idle;
    }
  }

  void ReadyJump(double dt) {
    if (jumpReady) {
      if (nowJumpPower < maxJumpPower) {
        nowJumpPower += 55 * InGameConst.timeFlowSpeed * dt;
      } else
        nowJumpPower = maxJumpPower;
      scale.x = (2 + (nowJumpPower / maxJumpPower) * 0.3) * faceDir;
      scale.y = (2 - (nowJumpPower / maxJumpPower) * 0.4);
    }
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!leftSide) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        faceDir = 1;
        nowMove = true;
        physObject.linearMove(-moveSpeed);
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        physObject.linearMove(moveSpeed);
        nowMove = true;
        faceDir = -1;
      } else {
        nowMove = false;
        physObject.linearMove(0);
      }

      if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
        if (physObject.IsEndParabola())
          jumpReady = true;
        else
          jumpReady = false;
      } else {
        if (jumpReady) {
          physObject.Jump(nowJumpPower);
          nowJumpPower = 0;
          jumpReady = false;
        }
      }

      if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
        DoHitBall();
      }
    } else {
      if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
        faceDir = 1;
        nowMove = true;
        physObject.linearMove(-moveSpeed);
      } else if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
        physObject.linearMove(moveSpeed);
        nowMove = true;
        faceDir = -1;
      } else {
        nowMove = false;
        physObject.linearMove(0);
      }

      if (jumpReady) {
        physObject.linearMove(0);
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
        if (physObject.IsEndParabola())
          jumpReady = true;
        else
          jumpReady = false;
      } else {
        if (jumpReady) {
          physObject.Jump(nowJumpPower);
          nowJumpPower = 0;
          jumpReady = false;
        }
      }

      if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
        DoHitBall();
      }
    }
    return true;
  }

  void DoHitBall() {
    if (hitDelayTime > InGameConst.globalTime) return;
    double dir = leftSide ? 1 : -1;
    GameManagerVariables.ball_position;
    if (InGameConst.IsCollisionRectangle(position, size * 2.3,
        GameManagerVariables.ball_position, GameManagerVariables.ball_size)) {
      if (physObject.IsEndParabola()) {
        // 땅에 붙어있을 경우.
        double dis = abs(position.x - ball.x);
        if (position.x < ball.x)
          ball.physObject.ForceBall(100, 90 - 1 * dis);
        else
          ball.physObject.ForceBall(100, 90 + 1 * dis);
      } else {
        double dir = atan2(ball.y - position.y, 5 * (ball.x - position.x));
        dir = InGameConst.GetDegreeDirection(dir);

        print(
            "${position.y - ball.y} /  ${ball.x - position.x} / dir : ${dir}");

        ball.physObject.ForceBall(170, dir);
      }
      pop?.animation?.reset();
      pop?.animation?.loop = false;
      pop?.x = ball.x;
      pop?.y = ball.y;
    }
    elapsedTime = 0;
    hitDelayTime = InGameConst.globalTime + 1;
  }

  void resetPosition() {
    position = Vector2(
      (gameRef.size.x - size.x) / 2,
      (gameRef.size.y - size.y) / 2,
    );
  }

  Future<void> _loadCharacterSprites() async {
    // Load & configure sprite assets
    final cat = await gameRef.loadSprite('game/sp_cat.png');
    final catSit = await gameRef.loadSprite('game/sp_cat_sit.png');
    final catJump = await gameRef.loadSprite('game/sp_cat_jump.png');
    final catWalk = await gameRef.loadSprite('game/sp_cat_walk.png');

    sprites = <PlayerState, Sprite>{
      PlayerState.idle: cat,
      PlayerState.walk: catWalk,
      PlayerState.hit: catJump,
      PlayerState.sit: catSit,
    };
  }
}
