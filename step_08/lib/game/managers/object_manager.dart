// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flame/components.dart';

import './managers.dart';
import '../doodle_dash.dart';
import '../sprites/sprites.dart';
import '../util/util.dart';

final Random _rand = Random();

class ObjectManager extends Component with HasGameRef<AnimalVolleyball> {
  ObjectManager({
    this.minVerticalDistanceToNextPlatform = 200,
    this.maxVerticalDistanceToNextPlatform = 300,
  });

  double minVerticalDistanceToNextPlatform;
  double maxVerticalDistanceToNextPlatform;
  final probGen = ProbabilityGenerator();

  @override
  void update(double dt) {
    final screenBottom = gameRef.playerLeft.position.y +
        (gameRef.size.x / 2) +
        gameRef.screenBufferSpace;

    super.update(dt);
  }

  final Map<String, bool> specialPlatforms = {
    'spring': true, // level 1
    'broken': false, // level 2
    'noogler': false, // level 3
    'rocket': false, // level 4
    'enemy': false, // level 5
  };

  /*void _cleanupPlatforms() {
    final lowestPlat = _platforms.removeAt(0);

    lowestPlat.removeFromParent();
  }*/

  void enableSpecialty(String specialty) {
    specialPlatforms[specialty] = true;
  }

  void enableLevelSpecialty(int level) {
    switch (level) {
      case 1:
        enableSpecialty('spring');
      case 2:
        enableSpecialty('broken');
      case 3:
        enableSpecialty('noogler');
      case 4:
        enableSpecialty('rocket');
      case 5:
        enableSpecialty('enemy');
    }
  }

  void resetSpecialties() {
    for (var key in specialPlatforms.keys) {
      specialPlatforms[key] = false;
    }
  }

  void configure(int nextLevel, Difficulty config) {
    minVerticalDistanceToNextPlatform = gameRef.mainTitle.minDistance;
    maxVerticalDistanceToNextPlatform = gameRef.mainTitle.maxDistance;

    for (int i = 1; i <= nextLevel; i++) {
      enableLevelSpecialty(i);
    }
  }
}
