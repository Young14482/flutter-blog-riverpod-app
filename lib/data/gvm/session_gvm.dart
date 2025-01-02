import 'package:flutter/material.dart';
import 'package:flutter_blog/data/repository/user_repository.dart';
import 'package:flutter_blog/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> login() async {}

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
