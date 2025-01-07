import 'package:flutter/material.dart';
import 'package:flutter_blog/data/model/post.dart';
import 'package:flutter_blog/data/repository/post_repository.dart';
import 'package:flutter_blog/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PostListModel {
  bool isFirst;
  bool isLast;
  int pageNumber;
  int size;
  int totalPage;
  List<Post> posts;

  PostListModel({
    required this.isFirst,
    required this.isLast,
    required this.pageNumber,
    required this.size,
    required this.totalPage,
    required this.posts,
  });

  PostListModel copyWith(
      {bool? isFirst,
      bool? isLast,
      int? pageNumber,
      int? size,
      int? totalPage,
      List<Post>? posts}) {
    return PostListModel(
      isFirst: isFirst ?? this.isFirst,
      isLast: isLast ?? this.isLast,
      pageNumber: pageNumber ?? this.pageNumber,
      size: size ?? this.size,
      totalPage: totalPage ?? this.totalPage,
      posts: posts ?? this.posts,
    );
  }

  PostListModel.fromMap(Map<String, dynamic> map)
      : isFirst = map["isFirst"],
        isLast = map["isLast"],
        pageNumber = map["pageNumber"],
        size = map["size"],
        totalPage = map["totalPage"],
        posts = (map["posts"] as List<
                dynamic>) // map["posts"] >> dynamic인 상태 >> list라고 인식 시키고
            .map((e) => Post.fromMap(e)) // list 내부의 원소들을 Post 객체로 인식 시키고
            .toList(); // List화
}

class PostList_Post {}

class PostList_User {}

final postListProvider = NotifierProvider<PostListVM, PostListModel?>(() {
  return PostListVM();
});

class PostListVM extends Notifier<PostListModel?> {
  final refreshCtrl = RefreshController();
  final mContext = navigatorKey.currentContext!; // !는 상황에 맞게
  PostRepository postRepository = const PostRepository();

  @override
  PostListModel? build() {
    init();
    return null;
  }

  // init은 초기화의 책임을 가짐
  Future<void> init() async {
    Map<String, dynamic> responseBody = await postRepository.findAll(page: 0);
    if (!responseBody["success"]) {
      ScaffoldMessenger.of(mContext).showSnackBar(
        SnackBar(
            content: Text("게시글 목록 보기 실패 : ${responseBody["errorMessage"]}")),
      );
      return;
    }
    state = PostListModel.fromMap(responseBody["response"]);
    refreshCtrl.refreshCompleted();
  }

  void remove(int id) {
    PostListModel model = state!; // 얕은 복사

    model.posts = model.posts.where((p) => p.id != id).toList(); // 깊은 복사 발생

    state = state!.copyWith(posts: model.posts); // 기존 값을 유지한 채 바꾸고 싶은 값만 넣어서 변경
  }

  void add(Post post) {
    PostListModel model = state!;

    model.posts = [post, ...model.posts];

    state = state!.copyWith(posts: model.posts);
  }

  // 페이징
  Future<void> nextList() async {
    PostListModel model = state!;
    if (model.isLast) {
      await Future.delayed(Duration(milliseconds: 500));
      refreshCtrl.loadComplete();
      return;
    }

    Map<String, dynamic> responseBody =
        await postRepository.findAll(page: state!.pageNumber + 1);
    if (!responseBody["success"]) {
      ScaffoldMessenger.of(mContext).showSnackBar(
        SnackBar(content: Text("게시글 로드 실패 : ${responseBody["errorMessage"]}")),
      );
      return;
    }
    PostListModel prevModel = state!;
    PostListModel nextModel = PostListModel.fromMap(responseBody["response"]);

    // nextModel을 기준으로 복사해야 posts이외의 정보를 담을 수 있음
    state = nextModel.copyWith(posts: [...prevModel.posts, ...nextModel.posts]);
    refreshCtrl.loadComplete();
  }
}
