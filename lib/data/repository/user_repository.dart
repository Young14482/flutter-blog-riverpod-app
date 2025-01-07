import 'package:dio/dio.dart';

import '../../_core/utils/my_http.dart';

class UserRepository {
  const UserRepository();

  Future<Map<String, dynamic>> save(Map<String, dynamic> data) async {
    Response response = await dio.post("/join", data: data);

    final body = response.data;
    // Logger().d(body);
    return body;
  }

  Future<(Map<String, dynamic>, String)> findByUsernameAndPassword(
      Map<String, String> data) async {
    Response response = await dio.post("/login", data: data);

    Map<String, dynamic> body = response.data;
    // Logger().d(body);

    String accessToken = "";
    try {
      accessToken = response.headers["Authorization"]![0];
      // Logger().d(accessToken);
    } catch (e) {}

    return (body, accessToken);
  }

  Future<Map<String, dynamic>> autoLogin(String? accessToken) async {
    Response response = await dio.post(
      "/auto/login",
      options: Options(headers: {"Authorization": accessToken}),
    );

    Map<String, dynamic> body = response.data;

    return body;
  }
}
