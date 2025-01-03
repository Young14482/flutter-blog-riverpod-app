import 'package:flutter/material.dart';
import 'package:flutter_blog/_core/utils/my_http.dart';
import 'package:flutter_blog/data/repository/user_repository.dart';
import 'package:flutter_blog/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionUser {
  int? id;
  String? username;
  String? accessToken;
  bool? isLogin;

  SessionUser({this.id, this.username, this.accessToken, this.isLogin = false});
}

class SessionGVM extends Notifier<SessionUser> {
  // TODO 2. TODO1 가져오기
  final mContext = navigatorKey.currentContext!; // !는 상황에 맞게
  UserRepository userRepository = const UserRepository();

  @override
  SessionUser build() {
    return SessionUser(
        id: null, username: null, accessToken: null, isLogin: false);
  }

  Future<void> login(String username, String password) async {
    final body = {
      "username": username,
      "password": password,
    };

    // 구조 분해 할당 사용
    var (responseBody, accessToken) =
        await userRepository.findByUsernameAndPassword(body);

    // 응답 예외처리
    if (!responseBody["success"]) {
      ScaffoldMessenger.of(mContext!).showSnackBar(
        SnackBar(content: Text("로그인 실패 : ${responseBody["errorMessage"]}")),
      );
      return;
    }

    // 1. accessToken을 Storage에 저장
    await secureStorage.write(
      key: "accessToken",
      value: accessToken,
    ); // I/O 라서 await 걸어야 함

    // 2. SessionUser 상태 갱신
    Map<String, dynamic> data = responseBody["response"];
    state = SessionUser(
      id: data["id"],
      username: data["username"],
      accessToken: accessToken,
      isLogin: true,
    );

    // 3. Dio에 토큰 세팅
    dio.options.headers["Authorization"] = accessToken;
    // Logger().d(dio.options.headers);

    Navigator.popAndPushNamed(mContext, "/post/list");
  }

  Future<void> join(String username, String email, String password) async {
    // 레포지토리에 요청
    final body = {
      "username": username,
      "email": email,
      "password": password,
    };

    Map<String, dynamic> responseBody = await userRepository.save(body);
    // 응답 예외처리
    if (!responseBody["success"]) {
      ScaffoldMessenger.of(mContext!).showSnackBar(
        SnackBar(content: Text("회원가입 실패 : ${responseBody["errorMessage"]}")),
      );
      return;
    }
    // 정상 처리 (login 페이지로)
    Navigator.pushNamed(mContext, "/login");
  }

  Future<void> logout() async {
    // 1. Storage에서 Token 삭제
    await secureStorage.delete(key: "accessToken");

    // 2. 상태 갱신
    // 값을 비우면 null또는 기본값이 들어감
    state = SessionUser();

    // 3. dio Token 삭제
    dio.options.headers["Authorization"] = "";

    // 4. 화면 이동
    Navigator.popAndPushNamed(mContext, "/login");
  }

  // 절대 SessionUser가 있을 수 없는 상태
  Future<void> autoLogin() async {
    // 1. Storage에서 Token 가져오기
    String? accessToken = await secureStorage.read(key: "accessToken");
    // 2. Token이 비어있으면 로그인 화면으로
    if (accessToken == null) {
      Navigator.popAndPushNamed(mContext, "/login");
      return;
    }
    // 3. Token이 있으면 통신
    Map<String, dynamic> responseBody =
        await userRepository.autoLogin(accessToken);
    // 4. 통신 결과가 실패면 로그인 화면으로 >> Token이 유효하지 않을 경우
    if (!responseBody["success"]) {
      Navigator.popAndPushNamed(mContext, "/login");
      return;
    }
    // 5. 통신 성공시 상태 갱신 후 메인 화면
    Map<String, dynamic> data = responseBody["response"];
    state = SessionUser(
      id: data["id"],
      username: data["username"],
      accessToken: accessToken,
      isLogin: true,
    );

    dio.options.headers["Authorization"] = accessToken;

    Navigator.popAndPushNamed(mContext, "/post/list");
  }
}

final sessionProvider = NotifierProvider<SessionGVM, SessionUser>(() {
  return SessionGVM();
});
