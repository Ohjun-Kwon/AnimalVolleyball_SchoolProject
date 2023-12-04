// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../doodle_dash.dart';

// Overlay that appears for the main menu
class MainMenuOverlay extends StatefulWidget {
  const MainMenuOverlay(this.game, {super.key});

  final Game game;

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState2();
}

class _MainMenuOverlayState extends State<MainMenuOverlay> {
  Character character = Character.dash;

  @override
  Widget build(BuildContext context) {
    AnimalVolleyball game = widget.game as AnimalVolleyball;

    return LayoutBuilder(builder: (context, constraints) {
      final characterWidth = constraints.maxWidth / 5;
      final TextStyle titleStyle = (constraints.maxWidth > 830)
          ? Theme.of(context).textTheme.displayLarge!
          : Theme.of(context).textTheme.displaySmall!;

      // 760 is the smallest height the browser can have until the
      // layout is too large to fit.
      final bool screenHeightIsSmall = constraints.maxHeight < 760;

      return Material(
        color: Theme.of(context).colorScheme.background,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Kitty Volleyball',
                    style: titleStyle.copyWith(
                      height: .8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const WhiteSpace(),
                  Align(
                    alignment: Alignment.center,
                    child: Text('Select your character:',
                        style: Theme.of(context).textTheme.headlineSmall!),
                  ),
                  if (!screenHeightIsSmall) const WhiteSpace(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CharacterButton(
                        character: Character.dash,
                        selected: character == Character.dash,
                        onSelectChar: () {
                          setState(() {
                            character = Character.dash;
                          });
                        },
                        characterWidth: characterWidth,
                      ),
                      CharacterButton(
                        character: Character.sparky,
                        selected: character == Character.sparky,
                        onSelectChar: () {
                          setState(() {
                            character = Character.sparky;
                          });
                        },
                        characterWidth: characterWidth,
                      ),
                    ],
                  ),
                  if (!screenHeightIsSmall) const WhiteSpace(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Difficulty:',
                          style: Theme.of(context).textTheme.bodyLarge!),
                      LevelPicker(
                        level: game.mainTitle.selectedLevel.toDouble(),
                        label: game.mainTitle.selectedLevel.toString(),
                        onChanged: ((value) {
                          setState(() {
                            game.mainTitle.selectLevel(value.toInt());
                          });
                        }),
                      ),
                    ],
                  ),
                  if (!screenHeightIsSmall) const WhiteSpace(height: 50),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        game.gameManager.selectCharacter(character);
                        game.startGame();
                      },
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(
                          const Size(100, 50),
                        ),
                        textStyle: MaterialStateProperty.all(
                            Theme.of(context).textTheme.titleLarge),
                      ),
                      child: const Text('Start'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class LevelPicker extends StatelessWidget {
  const LevelPicker({
    super.key,
    required this.level,
    required this.label,
    required this.onChanged,
  });

  final double level;
  final String label;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Slider(
      value: level,
      max: 5,
      min: 1,
      divisions: 4,
      label: label,
      onChanged: onChanged,
    ));
  }
}

class _MainMenuOverlayState3 extends State<MainMenuOverlay> {
  // 방 데이터 예시. 실제 앱에서는 서버나 데이터베이스에서 가져올 것입니다.
  final List<String> roomTitles = [
    '방 제목 1',
    '방 제목 2',
    '방 제목 3',
    // 여기에 더 많은 방 제목이 올 수 있습니다.
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('방 목록')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: roomTitles.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: ListTile(
                    title: Text(roomTitles[index]),
                    // onTap 등의 다른 속성을 사용하여 상호작용 추가 가능
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // "ADD ROOM" 버튼을 눌렀을 때 할 행동
            },
            child: Text('ADD ROOM'),
            style: ElevatedButton.styleFrom(
              primary: Colors.orange,
              onPrimary: Colors.white,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // 현재 화면을 닫고 이전 화면으로 돌아감
            },
            child: Text('BACK'),
            style: ElevatedButton.styleFrom(
              primary: Colors.orange,
              onPrimary: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MainMenuOverlayState2 extends State<MainMenuOverlay> {
  Character character = Character.dash;

  @override
  Widget build(BuildContext context) {
    AnimalVolleyball game = widget.game as AnimalVolleyball;
    return Scaffold(
      body: Center(
        // 화면 중앙 정렬을 위한 Center 위젯
        child: Column(
          mainAxisSize: MainAxisSize.min, // Column의 크기를 자식들의 크기에 맞춤
          children: <Widget>[
            Image.asset(
              'assets/images/game/sp_title.png',
              height: 400,
              width: 1400,
            ),
            ElevatedButton(
              onPressed: () async {
                game.gameManager.selectCharacter(character);
                game.changeRoom();
//                game.startGame();
              },
              child: Text('GAME START'),
              style: ElevatedButton.styleFrom(
                primary: Colors.yellow, // 버튼의 배경색을 설정
                onPrimary: Colors.black, // 버튼의 텍스트 색을 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // 버튼의 모서리를 둥글게
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: 50, vertical: 15), // 패딩 설정
              ),
            ),
            SizedBox(height: 20), // 버튼 사이의 간격
            ElevatedButton(
              onPressed: () {
                // "HOW TO PLAY" 버튼이 눌렸을 때 실행될 코드
              },
              child: Text('HOW TO PLAY'),
              style: ElevatedButton.styleFrom(
                primary: Colors.yellow, // 버튼의 배경색을 설정
                onPrimary: Colors.black, // 버튼의 텍스트 색을 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // 버튼의 모서리를 둥글게
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: 50, vertical: 15), // 패딩 설정
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CharacterButton extends StatelessWidget {
  const CharacterButton(
      {super.key,
      required this.character,
      this.selected = false,
      required this.onSelectChar,
      required this.characterWidth});

  final Character character;
  final bool selected;
  final void Function() onSelectChar;
  final double characterWidth;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: (selected)
          ? ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(31, 64, 195, 255)))
          : null,
      onPressed: onSelectChar,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Image.asset(
              'assets/images/game/${character.name}_center.png',
              height: characterWidth,
              width: characterWidth,
            ),
            const WhiteSpace(height: 18),
            Text(
              character.name,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class WhiteSpace extends StatelessWidget {
  const WhiteSpace({super.key, this.height = 100});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
    );
  }
}
