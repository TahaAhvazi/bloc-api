import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:infinity_list/posts/bloc/post_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinity_list/widgets/postListItem.dart';

import 'btmLoader.dart';

class PostList extends StatefulWidget {
  const PostList({Key? key}) : super(key: key);

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    _scrollController.addListener(onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        switch (state.status) {
          case PostStatus.failure:
            return const Center(
              child: Text("Eror occured"),
            );
          case PostStatus.success:
            if (state.posts.isEmpty) {
              return const Center(
                child: Text('No POSTS'),
              );
            }
            return ListView.builder(
              itemBuilder: (context, index) {
                return index >= state.posts.length
                    ? BottomLoader()
                    : PostListItem(post: state.posts[index]);
              },
              itemCount: state.hasReachedMax
                  ? state.posts.length
                  : state.posts.length + 1,
              controller: _scrollController,
            );
          default:
            return const Center(
              child: CircularProgressIndicator(),
            );
        }
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController
      ..removeListener(onScroll)
      ..dispose();
    super.dispose();
  }

  void onScroll() {
    if (_isBottom) {
      context.read<PostBloc>().add(PostFetched());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) {
      return false;
    }
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
