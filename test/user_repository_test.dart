import 'package:flutter_blog/data/repository/user_repository.dart';

// 통신 테스트
void main() async {
  UserRepository userRepository = const UserRepository();
  await userRepository
      .findByUsernameAndPassword({"username": "ssar", "password": "1234"});
}
