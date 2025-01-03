import 'package:flutter_blog/data/model/user.dart';

class Post {
  int? id;
  String? title;
  String? content;
  DateTime? createdAt;
  DateTime? updatedAt;

  int? bookmarkCount;
  User? user;
  bool? isBookmark;

  Post.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        title = map["title"],
        content = map["content"],
        createdAt = map["createdAt"],
        updatedAt = map["updatedAt"],
        bookmarkCount = map["bookmarkCount"],
        user = User.fromMap(map["user"]),
        isBookmark = map["isBookmark"];
}
