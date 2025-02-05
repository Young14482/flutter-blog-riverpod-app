import 'package:flutter/material.dart';
import 'package:flutter_blog/_core/constants/size.dart';
import 'package:flutter_blog/ui/pages/post/detail_page/post_detail_vm.dart';
import 'package:flutter_blog/ui/pages/post/detail_page/widgets/post_detail_buttons.dart';
import 'package:flutter_blog/ui/pages/post/detail_page/widgets/post_detail_content.dart';
import 'package:flutter_blog/ui/pages/post/detail_page/widgets/post_detail_profile.dart';
import 'package:flutter_blog/ui/pages/post/detail_page/widgets/post_detail_title.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostDetailBody extends ConsumerWidget {
  int postId;

  PostDetailBody(this.postId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FutureProvider >> async, await 사용 가능
    // StreamProvider >> 스트림을 통해 데이터를 받음
    // StateProvider >> 전역데이터 보관 가능
    // NotifierProvider >> 위에거 다 가능
    PostDetailModel? model = ref.watch(postDetailProvider(postId));
    if (model == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          PostDetailTitle("${model.post.title}"),
          const SizedBox(height: largeGap),
          PostDetailProfile(model.post),
          PostDetailButtons(model.post),
          const Divider(),
          const SizedBox(height: largeGap),
          PostDetailContent("${model.post.content}"),
        ],
      ),
    );
  }
}
