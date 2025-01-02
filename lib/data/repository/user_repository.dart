import 'package:dio/dio.dart';
import 'package:flutter_blog/_core/utils/my_http.dart';
import 'package:logger/logger.dart';

class UserRepository {
  const UserRepository();

  Future<Map<String, dynamic>> save(Map<String, dynamic> data) async {
    Response response = await dio.post(
      "/join",
      data: data,
    );

    // final 쓰지말고 타입을 적어 혼동을 피함
    Map<String, dynamic> body = response.data;
    Logger().d(body); // test 코드 작성 - 직접해보기
    return body;
  }
}
