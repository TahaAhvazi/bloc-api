import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:infinity_list/posts/posts.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final http.Client httpClient;
  PostBloc({required this.httpClient}) : super(const PostState()) {
    on<PostFetched>(
      (event, emit) async {
        // TODO: implement event handler
        if (state.hasReachedMax) return;
        try {
          if (state.status == PostStatus.initial) {
            final posts = await _fetchPosts();
            return emit(
              state.copyWith(
                status: PostStatus.success,
                posts: posts,
                hasReachedMax: false,
              ),
            );
          }
          final posts = await _fetchPosts(state.posts.length);
          emit(posts.isEmpty
              ? state.copyWith(hasReachedMax: true)
              : state.copyWith(
                  status: PostStatus.success,
                  posts: List.of(state.posts)..addAll(posts),
                  hasReachedMax: false,
                ));
        } catch (_) {
          emit(state.copyWith(status: PostStatus.failure));
        }
      },
    );
  }
  Future<List<Post>> _fetchPosts([int startIndex = 0]) async {
    final response = await httpClient.get(
      Uri.https(
        'jsonplaceholder.typicode.com',
        '/posts',
        <String, String>{'_start': '$startIndex', '_limit': '20'},
      ),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as List;
      return body.map((dynamic json) {
        return Post(
            id: json['id'] as int,
            title: json['title'] as String,
            body: json['body'] as String);
      }).toList();
    }
    throw Exception('Eror occured while fetching posts');
  }
}
