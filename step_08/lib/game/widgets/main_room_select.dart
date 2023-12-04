// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../doodle_dash.dart';

// Overlay that appears for the main menu
class RoomSelectOverlay extends StatefulWidget {
  const RoomSelectOverlay(this.game, {super.key});
  final Game game;
  @override
  State<RoomSelectOverlay> createState() => _roomSelectOverlay();
}

class _roomSelectOverlay extends State<RoomSelectOverlay> {
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
