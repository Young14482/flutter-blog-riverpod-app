import 'package:flutter/material.dart';
import 'package:flutter_blog/_core/utils/my_http.dart';
import 'package:flutter_blog/data/repository/user_repository.dart';
import 'package:flutter_blog/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class SessionUser {
  int? id;
  String? username;
  String? accessToken;
  bool? isLogin;

  SessionUser({this.id, this.username, this.accessToken, this.isLogin});
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
    dio.options.headers = {
      "Authorization": accessToken,
    };
    Logger().d(dio.options.headers);

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

  Future<void> logout() async {}

  Future<void> autoLogin() async {
    Future.delayed(
      Duration(seconds: 3),
      () {
        Navigator.popAndPushNamed(mContext, "/login");
      },
    );
  }
}

final sessionProvider = NotifierProvider<SessionGVM, SessionUser>(() {
  return SessionGVM();
});
