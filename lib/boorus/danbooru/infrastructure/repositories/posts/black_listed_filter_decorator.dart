// Package imports:
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';

class BlackListedFilterDecorator implements IPostRepository {
  BlackListedFilterDecorator(
      {@required IPostRepository postRepository,
      @required Future<ISettingRepository> settingRepository})
      : _postRepository = postRepository,
        _settingRepository = settingRepository;

  final IPostRepository _postRepository;
  final Future<ISettingRepository> _settingRepository;

  @override
  Future<List<Post>> getCuratedPosts(
      DateTime date, int page, TimeScale scale) async {
    final posts = await _postRepository.getCuratedPosts(date, page, scale);
    final filtered = await _filter(posts);
    return filtered;
  }

  @override
  Future<List<Post>> getMostViewedPosts(DateTime date) async {
    final posts = await _postRepository.getMostViewedPosts(date);
    final filtered = await _filter(posts);
    return filtered;
  }

  @override
  Future<List<Post>> getPopularPosts(
      DateTime date, int page, TimeScale scale) async {
    final posts = await _postRepository.getPopularPosts(date, page, scale);
    final filtered = await _filter(posts);
    return filtered;
  }

  @override
  Future<List<Post>> getPosts(
    String tagString,
    int page, {
    int limit = 100,
    CancelToken cancelToken,
    bool skipFavoriteCheck = false,
  }) async {
    final posts = await _postRepository.getPosts(tagString, page,
        limit: limit,
        cancelToken: cancelToken,
        skipFavoriteCheck: skipFavoriteCheck);
    final filtered = await _filter(posts);
    return filtered;
  }

  Future<List<Post>> _filter(List<Post> posts) async {
    final settingsRepo = await _settingRepository;
    final settings = await settingsRepo.load();

    final tagRule = settings.blacklistedTags.split("\n");

    final filtered = posts.where((dto) {
      return dto.tagString
          .toString()
          .split(' ')
          .toSet()
          .intersection(tagRule.toSet())
          .isEmpty;
    }).toList();

    return filtered;
  }
}