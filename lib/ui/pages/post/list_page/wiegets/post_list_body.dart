import 'package:flutter/material.dart';
import 'package:flutter_blog/ui/pages/post/detail_page/post_detail_page.dart';
import 'package:flutter_blog/ui/pages/post/list_page/post_list_vm.dart';
import 'package:flutter_blog/ui/pages/post/list_page/wiegets/post_list_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostListBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    PostListModel? model = ref.watch(postListProvider);

    // separated >> builder랑 비슷한 역할. 하나 생성후 줄을 그어줌
    if (model == null) {
      return Center(child: CircularProgressIndicator());
    } else {
      return ListView.separated(
        itemCount: model.posts.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                  // 페이지 넘어가는 부분인데 라우터(주소)로 설계 안한 이유? >> 매개변수를 던져야 해서
                  context,
                  MaterialPageRoute(
                      builder: (_) => PostDetailPage(model.posts[index].id!)));
            },
            child: PostListItem(post: model.posts[index]),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
      );
    }
  }
}
