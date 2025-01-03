import 'package:dio/dio.dart';
import 'package:flutter_blog/_core/utils/my_http.dart';

class UserRepository {
  const UserRepository();

  Future<Map<String, dynamic>> save(Map<String, dynamic> data) async {
    Response response = await dio.post(
      "/join",
      data: data,
    );

    // final 쓰지말고 타입을 적어 혼동을 피함
    Map<String, dynamic> body = response.data;
    // Logger().d(body); // test 코드 작성 - 직접해보기
    return body;
  }

  // 값을 2개 던져서 `구조 분해 할당`을 사용해 값을 받을 수 있음
  Future<(Map<String, dynamic>, String)> findByUsernameAndPassword(
      Map<String, String> data) async {
    Response response = await dio.post(
      "/login",
      data: data,
    );

    Map<String, dynamic> body = response.data;
    // Logger().d(body);

    // 토큰 받아오기 >> 잘못된 입력일 경우 header가 null이라서 try-catch를 사용하여 예외처리
    String accessToken = "";
    try {
      accessToken = response.headers["Authorization"]![0];
      // Logger().d(accessToken);
    } catch (e) {}

    return (body, accessToken);
  }
}
