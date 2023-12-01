import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math';


List<Room> roomList = [];

class Room {
  String name = "방제목 ";
  int roomIndex = -1;
  bool locked = false;
  String pwd = "";
  List<WebSocket?> playerSockets = [];

  Room(String name, int idx, bool locked, String pwd) {
    this.name = name;
    this.roomIndex = idx;
    this.locked = locked;
    this.pwd = pwd;
  }

  void AddPlayer(WebSocket? webSocket) {
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
class Vector2 {
  double x = 0;
  double y = 0;
  Vector2(double x , double y) {
    this.x = x;
    this.y = y;
  }
}
class Ball {
  double speed = 0;
  double physStartTime = 0;
  double physEndTime = 0;
  Vector2 startPos = Vector2(0,0);
  Vector2 endPos = Vector2(0,0);

  double direction = 0;
  Vector2 pos = Vector2(0,0);
}
class Game {
  Ball ball = Ball();
  double landY = 0;
  double gravity = 0.6;
  double globalTime = 0;
  Vector2 startPos = Vector2(0,0);

  void gameStart() {

    Timer.periodic(Duration(milliseconds: 16), (Timer timer) {
      globalTime += 1;      
    });
  }
  
  void startParabola() {
    startPos = getBallPos(globalTime);

  }
  double getFlightMaxHeight(Vector2 startPos , double direction , double speed) {
    double vs = sin(direction) * speed;
    return (startPos.y - landY) + pow(vs , 2) / (2 * gravity);
  }
  
  double getFlightMaxTime(Vector2 startPos ,double direction , double speed)
  {
    double flightMaxHeight = getFlightMaxHeight(startPos , direction, speed);
    double vs = sin(direction) * speed;    
    return (vs / gravity ) + sqrt(2 * flightMaxHeight / gravity);
  }
  
  Vector2 getParabolaEnd(Vector2 startPos, double direction , double speed) {
    double hs = cos(direction) * speed;
    double T = getFlightMaxTime(startPos, direction , speed);
    double endPosX = startPos.x + hs * T; 
    double endPosY = landY;
    return Vector2 (endPosX , endPosY);
  }

  Vector2 getBallPos(double globalTime) {
    double vs = ball.speed * sin(ball.direction);
    double hs = ball.speed * cos(ball.direction);
    double nowTime = (globalTime - ball.physStartTime) / ball.physEndTime;
    double changedX = (ball.endPos.x - ball.startPos.x) * nowTime;
    double changedY = changedX * (vs / hs) - 0.5 * gravity * pow(changedX / hs , 2);
    return Vector2(ball.startPos.x +changedX , ball.startPos.y + changedY);
  }
}

Future<WebSocket?> upgradeToSocket(HttpRequest req) async {
  // Upgrade an HttpRequest to a WebSocket connection
  try {
    WebSocket socket = await WebSocketTransformer.upgrade(req);
    print('Client connected!');
    socket.add('성공적으로 방에 연결 됐습니다.');
    // Listen for incoming messages from the client
    socket.listen((message) {
      print('Received message: $message');
      socket.add('You sent: $message');
    }, onDone: () {
      print('Client disconnected');
    });
    
    return socket;
  }
  catch (e) {
    print('Client Connect Error $e');
    return null;
  }
}

void handleGetRequest(HttpRequest req) {
  if (req.uri.path == '/rooms') {
    handleRoomListRequest(req);
  }
  else {
    HttpResponse res = req.response;
    res.write('유효하지 않은 요청');
    res.close();
  }
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

Future handleHTTPRequest(HttpRequest req) async {
  switch (req.method) {
    case 'GET':
        handleGetRequest(req);
      break;
    case 'POST':
      if (req.uri.path == '/create') {
        handleCreateRoomRequest(req);
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
    if (request.uri.path == '/join') {
        handleJoinRoomRequest(request);
    }
    else
      handleHTTPRequest(request);
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
    roomList.length, // 다음 인덱스 할당
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
  print("방 접속 시도 : $req.uri.queryParameters['roomId']");
  String? data = req.uri.queryParameters['roomId'];
  int roomIndex = -1;
  if (data != null) {
    roomIndex = int.parse(data);
  }
  print(roomIndex);
  if (roomIndex >= 0 && roomIndex < roomList.length + 1) {
    // 방 인덱스 유효 시
    print("여기까지는 됐나?");
    final room = roomList[roomIndex];

    print("서버에 연결 시도...");
    WebSocket? socket = await upgradeToSocket(req);
    if (socket != null) {
      room.AddPlayer(socket);
    }
    else {
      print('방 접속 실패...');
      req.response
        ..statusCode = HttpStatus.ok
        ..write('방 접속 실패...');
    }

  } else {
    print("여기까지 안됐나");

    req.response
      ..statusCode = HttpStatus.badRequest
      ..write('잘못된 방 인덱스입니다.');
  }
  req.response.close();
}
