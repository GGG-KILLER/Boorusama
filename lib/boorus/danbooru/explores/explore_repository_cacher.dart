// Project imports:
import 'package:boorusama/boorus/danbooru/explores/explores.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/core/datetimes/datetimes.dart';
import 'package:boorusama/core/posts/post_repository.dart';
import 'package:boorusama/functional.dart';

class ExploreRepositoryCacher implements ExploreRepository {
  ExploreRepositoryCacher({
    required this.repository,
    required this.popularStaleDuration,
    required this.mostViewedStaleDuration,
    required this.hotStaleDuration,
  });

  final ExploreRepository repository;
  final Duration popularStaleDuration;
  final Duration mostViewedStaleDuration;
  final Duration hotStaleDuration;

  final Map<String, (DateTime, List<DanbooruPost>)> _cache = {};

  DateTime _truncateToDate(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  bool _isCached(String key, Duration staleDuration) {
    if (_cache.containsKey(key)) {
      final entry = _cache[key]!;
      if (DateTime.now().difference(entry.$1) <= staleDuration) {
        return true;
      }
    }
    return false;
  }

  @override
  DanbooruPostsOrError getPopularPosts(
    DateTime date,
    int page,
    TimeScale scale, {
    int? limit,
  }) {
    final truncatedDate = _truncateToDate(date);
    final name = 'popular-$truncatedDate-$page-$scale-$limit';

    if (_isCached(name, popularStaleDuration)) {
      return TaskEither.of(_cache[name]!.$2.toResult());
    }

    return repository
        .getPopularPosts(date, page, scale, limit: limit)
        .flatMap((r) => TaskEither(() async {
              _cache[name] = (DateTime.now(), r.posts);
              return Either.of(r);
            }));
  }

  @override
  DanbooruPostsOrError getMostViewedPosts(DateTime date) {
    final truncatedDate = _truncateToDate(date);
    final name = 'mostViewed-$truncatedDate';

    if (_isCached(name, mostViewedStaleDuration)) {
      return TaskEither.of(_cache[name]!.$2.toResult());
    }

    return repository
        .getMostViewedPosts(date)
        .flatMap((r) => TaskEither(() async {
              _cache[name] = (DateTime.now(), r.posts);
              return Either.of(r);
            }));
  }

  @override
  DanbooruPostsOrError getHotPosts(
    int page, {
    int? limit,
  }) {
    final name = 'hot-$page-$limit';

    if (_isCached(name, hotStaleDuration)) {
      return TaskEither.of(_cache[name]!.$2.toResult());
    }

    return repository
        .getHotPosts(page, limit: limit)
        .flatMap((r) => TaskEither(() async {
              _cache[name] = (DateTime.now(), r.posts);
              return Either.of(r);
            }));
  }
}
