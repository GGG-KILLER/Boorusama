// Package imports:
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/search/query_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/core/application/list_state_notifier.dart';

part 'search_state.dart';
part 'search_state_notifier.freezed.dart';

final searchStateNotifierProvider =
    StateNotifierProvider<SearchStateNotifier>((ref) {
  return SearchStateNotifier(ref);
});

class SearchStateNotifier extends StateNotifier<SearchState> {
  SearchStateNotifier(
    ProviderReference ref,
  )   : _postRepository = ref.watch(postProvider),
        _listStateNotifier = ListStateNotifier<Post>(),
        _ref = ref,
        super(SearchState.initial());

  final IPostRepository _postRepository;
  final ListStateNotifier<Post> _listStateNotifier;

  final ProviderReference _ref;

  void search() async {
    _listStateNotifier.refresh(
      callback: () async {
        final completedQueryItems =
            _ref.watch(queryStateNotifierProvider.state).completedQueryItems;
        final query = completedQueryItems.join(' ');
        final posts = await _postRepository.getPosts(query, 1);

        return posts;
      },
      onStateChanged: (state) {
        if (mounted) {
          this.state = this.state.copyWith(
                posts: state,
              );
        }
      },
    );
  }

  void getMoreResult() async {
    _listStateNotifier.getMoreItems(
      callback: () async {
        final nextPage = state.posts.page + 1;
        final completedQueryItems =
            _ref.watch(queryStateNotifierProvider.state).completedQueryItems;
        final query = completedQueryItems.join(' ');
        final posts = await _postRepository.getPosts(query, nextPage);

        posts
          ..removeWhere((post) {
            final p = state.posts.items.firstWhere(
              (sPost) => sPost.id == post.id,
              orElse: () => null,
            );
            return p?.id == post.id;
          });

        return posts;
      },
      onStateChanged: (state) => this.state = this.state.copyWith(
            posts: state,
          ),
    );
  }

  void clear() {
    state = SearchState.initial();
  }
}
