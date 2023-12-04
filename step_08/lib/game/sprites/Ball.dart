// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../managers/InGameConst.dart';
import '../doodle_dash.dart';
import 'dart:math';
import './PhysObject.dart';

class Ball extends SpriteComponent
    with HasGameRef<AnimalVolleyball>, CollisionCallbacks {
  final hitbox = RectangleHitbox();

  PhysObject physObject = PhysObject();
  Ball(Vector2 _position)
      : super(
            size: Vector2.all(100),
            position: _position,
            priority: 2,
            anchor: Anchor.center) {
    physObject.Init(size);
    physObject.startParabola(
        Vector2(1042, 680), 133, InGameConst.GetRadianDirection(135));
  }
  Vector2 pos = Vector2(0, 0);

  // 공의 움직임을 주어진 식에 따라 변환한다.
  @override
  void update(double dt) {
    InGameConst.globalTime += InGameConst.timeFlowSpeed * dt;
    position = physObject.UpdatePosition(InGameConst.globalTime);
    physObject.CheckBoundTime();
    angle += physObject.GetHS() * InGameConst.timeFlowSpeed * dt / 29;
    super.update(dt);
  }

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('game/sp_ball.png');
    size = Vector2(100, 100);

    await super.onLoad();
    await add(hitbox);
  }
}
