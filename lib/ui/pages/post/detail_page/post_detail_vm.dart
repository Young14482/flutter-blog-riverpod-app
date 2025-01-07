import 'package:flutter/material.dart';
import 'package:flutter_blog/data/model/post.dart';
import 'package:flutter_blog/data/repository/post_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../main.dart';
import '../list_page/post_list_vm.dart';

class PostDetailModel {
  Post post;

  PostDetailModel({required this.post});

  PostDetailModel copyWith({Post? post}) {
    return PostDetailModel(post: post ?? this.post);
  }

  PostDetailModel.fromMap(Map<String, dynamic> map) : post = Post.fromMap(map);
}

// autoDispose >> 화면이 사라지면(파괴) vm이 자동으로 사라짐
final postDetailProvider = NotifierProvider.family
    .autoDispose<PostDetailVM, PostDetailModel?, int>(() {
  return PostDetailVM();
});

class PostDetailVM extends AutoDisposeFamilyNotifier<PostDetailModel?, int> {
  final mContext = navigatorKey.currentContext!;
  PostRepository postRepository = const PostRepository();

  @override
  PostDetailModel? build(id) {
    init(id);
    return null;
  }

  Future<void> init(int id) async {
    Map<String, dynamic> responseBody = await postRepository.findById(id);
    if (!responseBody["success"]) {
      ScaffoldMessenger.of(mContext).showSnackBar(
        SnackBar(
            content: Text("게시글 상세보기 실패 : ${responseBody["errorMessage"]}")),
      );
      return;
    }
    state = PostDetailModel.fromMap(responseBody["response"]);
  }

  Future<void> deleteById(int id) async {
    Map<String, dynamic> responseBody = await postRepository.deleteById(id);
    if (!responseBody["success"]) {
      ScaffoldMessenger.of(mContext).showSnackBar(
        SnackBar(content: Text("게시글 삭제 실패 : ${responseBody["errorMessage"]}")),
      );
      return;
    }
    // listVM 상태 변경
    // ref.read(postListProvider.notifier).init(0); // list 통신 다시하기 >> 상태 관리가 아님

    // EventBus Notifier >> 상태 관리 한번에 함

    ref.read(postListProvider.notifier).remove(id); // 상태 변경용 메서드를 만들고 호출
    // 화면 파괴시 vm 같이 파괴됨
    Navigator.pop(mContext);
  }
}
