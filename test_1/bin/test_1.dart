import 'dart:io';
import 'dart:convert';

List<Room> roomList = [];

class Room {
  String name = "방제목 ";
  int roomIndex = -1;
  bool locked = false;
  String pwd = "";
  List<WebSocket> playerSockets = [];

  Room(String name, int idx, bool locked, String pwd) {
    this.name = name;
    this.roomIndex = idx;
    this.locked = locked;
    this.pwd = pwd;
  }

  void AddPlayer(WebSocket webSocket) {
    playerSockets.add(webSocket);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'roomIndex': roomIndex,
      'locked': locked,
      'pwd': locked ? pwd : '', // 비밀번호는 잠긴 방에만 포함
    };
  }
}

Future upgradeToSocket(HttpRequest req) async {
  // Upgrade an HttpRequest to a WebSocket connection
  var socket = await WebSocketTransformer.upgrade(req);
  print('Client connected!');
  // Listen for incoming messages from the client
  socket.listen((message) {
    print('Received message: $message');
    socket.add('You sent: $message');
  });
}

void handleGetRequest(HttpRequest req) {
  // #1 Retrieve an associated HttpResponse object in HttpRequst object.
  HttpResponse res = req.response;
  // #2 Do something : Example - Write text body in the response.
  String message;

  message = "${DateTime.now()} : 방 접속 성공";
  stdout.writeln(message);
  res.write('${DateTime.now()}: 방 접속!');

  // #3 Close the response and send it to the client.
  res.close();
}

void handleNotAllowedRequest(HttpRequest req) {
  // #1 Retrieve an associated HttpResponse object in HttpRequst object.
  HttpResponse res = req.response;

  // #2 Do something : Example - Write text body in the response.
  res
    ..statusCode = HttpStatus.methodNotAllowed
    ..write('${DateTime.now()}: Unsupported request: ${req.method}.');

  // #3 Close the response and send it to the client.
  res.close();
}

// Handler for HTTP Request.
Future handleHTTPRequest(HttpRequest req) async {
  // #1 Do something based on HTTP request types.
  switch (req.method) {
    case 'GET':
      if (req.uri.path == '/rooms') {
        handleRoomListRequest(req);
      } else {
        handleGetRequest(req);
      }
      break;
    case 'POST':
      if (req.uri.path == '/create') {
        handleCreateRoomRequest(req);
      } else if (req.uri.path == '/join') {
        handleJoinRoomRequest(req);
      }
      break;
    default:
      stdout.writeln("${DateTime.now()}: ${req.method} not allowed");
      handleNotAllowedRequest(req);
      break;
  }
}

Future<void> main() async {
  var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 4040);
  print('Listening on localhost:${server.port}');

  await for (HttpRequest request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      // 소켓 통신을 위한 요청일 경우.
      upgradeToSocket(request);
    } else {
      handleHTTPRequest(request);
    }
  }
}

// 서버에서 방 조회 처리 (GET)
void handleRoomListRequest(HttpRequest req) {
  HttpResponse res = req.response;
  // 방 목록을 JSON 형태로 변환하여 반환
  final roomsInfo = roomList.map((room) => room.toJson()).toList();
  res
    ..statusCode = HttpStatus.ok
    ..headers.contentType = ContentType.json
    ..write(json.encode(roomsInfo));
  res.close();
}

// 서버에서 방 생성 처리 (POST)
void handleCreateRoomRequest(HttpRequest req) async {
  final content = await utf8.decoder.bind(req).join(); // 받은 JSON 데이터
  final data = json.decode(content); // JSON 파싱
  // 새 방 객체 생성
  final newRoom = Room(
    data['name'],
    roomList.length + 1, // 다음 인덱스 할당
    data['locked'],
    data['pwd'],
  );
  roomList.add(newRoom); // 방 목록에 추가
  req.response
    ..statusCode = HttpStatus.created
    ..write('방 생성 성공: ${newRoom.name}');
  req.response.close();

  print(
      '방 생성 성공: ${newRoom.name}  ${newRoom.roomIndex} :: ${newRoom.name} / ${newRoom.locked} / ${newRoom.pwd} ');
}

// 서버에서 방 접속 처리 (POST)
void handleJoinRoomRequest(HttpRequest req) async {
  final content = await utf8.decoder.bind(req).join(); // 받은 JSON 데이터
  final data = json.decode(content); // JSON 파싱
  final roomIndex = data['roomIndex'];
  if (roomIndex != null && roomIndex < roomList.length) {
    // 방 인덱스 유효 시
    final room = roomList[roomIndex];
    req.response
      ..statusCode = HttpStatus.ok
      ..write('방 접속 성공: ${room.name}');
  } else {
    req.response
      ..statusCode = HttpStatus.badRequest
      ..write('잘못된 방 인덱스입니다.');
  }
  req.response.close();
}
