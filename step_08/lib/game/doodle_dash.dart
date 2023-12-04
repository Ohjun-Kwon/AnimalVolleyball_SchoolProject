// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import './world.dart';
import 'managers/managers.dart';
import 'sprites/sprites.dart';

enum Character { dash, sparky }

class AnimalVolleyball extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  AnimalVolleyball({super.children});

  final Osik_gameBack gameBack = Osik_gameBack();
  Osik_MainTitle mainTitle = Osik_MainTitle();
  GameManager gameManager = GameManager();
  int screenBufferSpace = 300;
  ObjectManager objectManager = ObjectManager();
  double netX = 2330 / 2;
  double landY = 1080;
  int leftScore = 0;
  int rightScore = 0;
  late Player playerLeft;
  late Player playerRight;
  late Ball ball;

  late SpriteAnimationComponent popEffect;
  @override
  Future<void> onLoad() async {
    await add(gameBack);
    await add(gameManager);
    overlays.add('gameOverlay');
    final pop = await images.load('game/sp_explode.png');
    var popAnimation = SpriteAnimation.fromFrameData(
        pop,
        SpriteAnimationData.sequenced(
            amount: 6, stepTime: 0.1, textureSize: Vector2(400, 400)));

    popEffect = SpriteAnimationComponent()
      ..animation = popAnimation
      ..size = Vector2(128, 128)
      ..anchor = Anchor.center;

    popEffect.animation?.loop = false;
    popEffect.priority = 2;
    add(popEffect);
    await add(mainTitle);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameManager.isGameOver) {
      return;
    }
    if (gameManager.room == RoomState.main) {
      overlays.add('mainMenuOverlay');
      return;
    } else if (gameManager.room == RoomState.select) {
      overlays.add('roomSelectOverlay');
      return;
    }

    if (gameManager.isPlaying) {
      checkLevelUp();

      final Rect worldBounds = Rect.fromLTRB(
        0,
        camera.position.y - screenBufferSpace,
        camera.gameSize.x,
        camera.position.y + gameBack.size.y,
      );
      camera.worldBounds = worldBounds;
      if (playerLeft.isMovingDown) {
        camera.worldBounds = worldBounds;
      }

      if (playerLeft.position.y >
          camera.position.y +
              gameBack.size.y +
              playerLeft.size.y +
              screenBufferSpace) {
        onLose();
      }
    }
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 241, 247, 249);
  }

  void CreateBall(Vector2 position) {
    ball = Ball(position);
    add(ball);
  }

  void initializeGameStart() {
    ResetScore();
    CreateBall(Vector2(500, 500));
    setCharacter();
    gameManager.reset();

    if (children.contains(objectManager)) objectManager.removeFromParent();

    mainTitle.reset();
    camera.worldBounds = Rect.fromLTRB(
      0,
      -gameBack.size.y, // top of screen is 0, so negative is already off screen
      camera.gameSize.x,
      gameBack.size.y +
          screenBufferSpace, // makes sure bottom bound of game is below bottom of screen
    );

    objectManager = ObjectManager(
        minVerticalDistanceToNextPlatform: mainTitle.minDistance,
        maxVerticalDistanceToNextPlatform: mainTitle.maxDistance);

    add(objectManager);

    objectManager.configure(mainTitle.level, mainTitle.difficulty);
  }

  void setCharacter() {
    playerLeft = Player(
      ball: ball,
      pop: popEffect,
      character: gameManager.character,
      leftSide: true,
      current: PlayerState.idle,
    );
    add(playerLeft);

    playerRight = Player(
      ball: ball,
      pop: popEffect,
      character: gameManager.character,
      leftSide: false,
      current: PlayerState.idle,
    );
    add(playerRight);
  }

  void ResetScore() {
    leftScore = 0;
    rightScore = 0;
  }

  int GetLeftScore() {
    return leftScore;
  }

  int GetRightScore() {
    return rightScore;
  }

  void startGame() {
    initializeGameStart();

    gameManager.state = GameState.playing;
    overlays.remove('mainMenuOverlay');
  }

  void changeRoom() {
    gameManager.room = RoomState.select;
    overlays.remove('mainMenuOverlay');
  }

  void resetGame() {
    startGame();
    overlays.remove('gameOverOverlay');
  }

  void onLose() {
    gameManager.state = GameState.gameOver;
    playerLeft.removeFromParent();
    overlays.add('gameOverOverlay');
  }

  void togglePauseState() {
    if (paused) {
      resumeEngine();
    } else {
      pauseEngine();
    }
  }

  void checkLevelUp() {
    if (mainTitle.shouldLevelUp(gameManager.score.value)) {
      mainTitle.increaseLevel();

      objectManager.configure(mainTitle.level, mainTitle.difficulty);
    }
  }
}
