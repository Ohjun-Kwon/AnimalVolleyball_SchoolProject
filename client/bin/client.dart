import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';


void main(List<String> arguments) async {
  print("게임을 시작하겠습니까?(Y/N)");
  print("Y");
  print("----------------");
  print("현재 서버 시각 : 0");
  print("현재 공의 위치 : (13 , 12)");
  
  while (true) {
    print('방 조회하기 : 1, 방 만들기: 2, 방 접속하기 : 3');
    String input = stdin.readLineSync() ?? '';

    switch (input) {
      case '1':
        await getRoomList();
        break;
      case '2':
        await createRoom();
        break;
      case '3':
        await joinRoom();
        break;
      default:
        print('올바른 숫자를 입력하세요.');
        break;
    }
  }
}

Future connectServer() async {
  final socket = await WebSocket.connect('ws://localhost:4040/ws');
  print('Connected to server!');

  // Read a line from the console
  print('Enter your username: ');
  final username = stdin.readLineSync();

  // Send a message to the server
  socket.add('Hello, server! My name is $username');

  // Listen for incoming messages from the server
  socket.listen((message) {
    print('Received message: $message');
  });


}

Future<void> getRoomList() async {
  var url = Uri.parse('http://localhost:4040/rooms');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> rooms = json.decode(response.body);
    print('현재 존재하는 방:');
    rooms.forEach((room) {
      print(
          '방 이름: ${room['name']}, 인덱스: ${room['roomIndex']}, 잠김: ${room['locked']}');
    });
  } else {
    print('방 목록을 가져오는 데 실패했습니다.');
  }
}

Future<void> createRoom() async {
  print('방 이름을 입력하세요:');
  String? name = stdin.readLineSync();
  print('방에 비밀번호를 설정하시겠습니까? (Y/N)');
  String? lockedInput = stdin.readLineSync();
  bool locked = lockedInput?.toUpperCase() == 'Y';
  String? pwd = '';

  if (locked) {
    print('비밀번호를 입력하세요:');
    pwd = stdin.readLineSync();
  }

  var url = Uri.parse('http://localhost:4040/create');
  var response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'name': name,
      'locked': locked,
      'pwd': pwd,
    }),
  );

  if (response.statusCode == 201) {
    print('방이 성공적으로 만들어졌습니다.');
  } else {
    print('방을 만드는 데 실패했습니다.');
  }
}

Future<void> joinRoom() async {
  print('접속할 방의 인덱스를 입력하세요:');
  String? roomId = stdin.readLineSync();
  var url = Uri.parse('http://localhost:4040/join');

  var socket = await WebSocket.connect('ws://localhost:4040/join?roomId=$roomId');
  socketListen(socket);
  InRoomLoop();
}

void InRoomLoop() {
  while(true) {
    print('방 나가기 : 1, 게임 시작하기 : 2');
    String input = stdin.readLineSync() ?? '';

    switch (input) {
      case '1': //방 나가기
        break;
      case '2': // 시작하기.
        break;
      default:
        print('올바른 숫자를 입력하세요.');
        break;
    }
  }
}
void socketListen(WebSocket socket) {
  socket.listen(
    (data) {
      print('Received data: $data');
    },
    onDone: () {
      print('Connection closed.');
    },
  );  
}