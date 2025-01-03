import 'package:flutter/material.dart';
import 'package:flutter_blog/ui/pages/post/list_page/wiegets/post_list_body.dart';
import 'package:flutter_blog/ui/widgets/custom_navigator.dart';

class PostListPage extends StatelessWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>(); // scaffold 제어를 위한 키 설정

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: CustomNavigation(scaffoldKey),
      appBar: AppBar(
        title: Text("Blog"),
      ),
      body: PostListBody(),
    );
  }
}
