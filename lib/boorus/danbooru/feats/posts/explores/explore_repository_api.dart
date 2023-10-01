// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/feats/types.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/types/types.dart' as danbooru;
import 'package:boorusama/foundation/http/http_utils.dart';
import 'package:boorusama/functional.dart';

class ExploreRepositoryApi
    with SettingsRepositoryMixin
    implements ExploreRepository {
  const ExploreRepositoryApi({
    required this.client,
    required this.postRepository,
    required this.settingsRepository,
    this.shouldFilter,
  });

  final DanbooruPostRepository postRepository;
  final DanbooruClient client;
  @override
  final SettingsRepository settingsRepository;
  final bool Function(DanbooruPost post)? shouldFilter;

  @override
  DanbooruPostsOrError getHotPosts(
    int page, {
    int? limit,
  }) =>
      postRepository.getPosts(
        'order:rank',
        page,
        limit: limit,
      );

  @override
  DanbooruPostsOrError getMostViewedPosts(
    DateTime date,
  ) =>
      TaskEither.Do(($) async {
        final dtos = await $(tryFetchRemoteData(
          fetcher: () => client.getMostViewedPosts(date: date),
        ));

        final data = dtos.map(postDtoToPost).toList();

        return shouldFilter != null
            ? data.whereNot(shouldFilter!).toList()
            : data;
      });

  @override
  DanbooruPostsOrError getPopularPosts(
    DateTime date,
    int page,
    TimeScale scale, {
    int? limit,
  }) =>
      TaskEither.Do(($) async {
        final dtos = await $(tryFetchRemoteData(
          fetcher: () => getPostsPerPage().then((lim) => client.getPopularPosts(
                date: date,
                scale: switch (scale) {
                  TimeScale.day => danbooru.TimeScale.day,
                  TimeScale.week => danbooru.TimeScale.week,
                  TimeScale.month => danbooru.TimeScale.month,
                },
                page: page,
                limit: limit ?? lim,
              )),
        ));

        final data = dtos.map(postDtoToPost).toList();

        return shouldFilter != null
            ? data.whereNot(shouldFilter!).toList()
            : data;
      });
}