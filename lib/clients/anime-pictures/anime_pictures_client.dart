// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

const _basePath = '/api/v3';

class AnimePicturesClient {
  AnimePicturesClient({
    Dio? dio,
    required String baseUrl,
  }) {
    _dio = dio ?? Dio();

    var url = baseUrl;

    if (url.startsWith('https://anime-pictures')) {
      url = url.replaceFirst('https://', 'https://api.');
    }

    _dio.options = _dio.options.copyWith(
      baseUrl: url,
    );
  }

  late final Dio _dio;

  Future<List<PostDto>> getPosts({
    List<String>? tags,
    int? page,
    int? limit,
  }) async {
    final isEmpty = tags?.join(' ').isEmpty ?? true;

    final response = await _dio.get(
      '$_basePath/posts',
      queryParameters: {
        if (!isEmpty) 'search_tag': tags!.join(' '),
        'page': (page ?? 1) - 1,
        if (limit != null) 'posts_per_page': limit,
      },
    );

    final results = response.data['posts'] as List;

    return results
        .map((item) => PostDto.fromJson(
              item,
              _dio.options.baseUrl,
            ))
        .toList();
  }

  Future<PostDetailsDto> getPostDetails({
    required int id,
  }) async {
    final response = await _dio.get(
      '$_basePath/posts/$id',
      queryParameters: {
        'extra': 'similar_pictures',
      },
    );

    return PostDetailsDto.fromJson(
      response.data,
      _dio.options.baseUrl,
    );
  }

  Future<List<AutocompleteDto>> getAutocomplete({
    required String query,
  }) async {
    final response = await _dio.get(
      '$_basePath/tags:autocomplete',
      queryParameters: {
        'tag': query,
      },
    );

    final results = response.data['tags'] as List;

    return results.map((item) => AutocompleteDto.fromJson(item)).toList();
  }

  final _downloadUrlCache = <int, AnimePicturesDownloadUrlData>{};

  Future<AnimePicturesDownloadUrlData?> getDownloadUrl(int postId) async {
    if (_downloadUrlCache.containsKey(postId)) {
      return _downloadUrlCache[postId];
    }

    final postDetails = await getPostDetails(id: postId);

    final fileUrl = postDetails.fileUrl;

    if (fileUrl == null) {
      return null;
    }

    final url = '${_dio.options.baseUrl}pictures/download_image/$fileUrl';

    final res = await _dio.get(
      url,
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status == 302,
        headers: {
          'cookie': 'sitelang=en',
        },
      ),
    );

    final location = res.headers['location']?.firstOrNull;
    final cookieValue = res.headers['set-cookie']?.firstOrNull;
    final cookie =
        cookieValue != null ? Cookie.fromSetCookieValue(cookieValue) : null;

    if (location == null || cookie == null) {
      return null;
    }

    final data = (
      url: location,
      cookie: 'sitelang=en; ${cookie.name}=${cookie.value}',
    );

    _downloadUrlCache[postId] = data;

    return data;
  }

  Future<List<PostDto>> getTopPosts({
    TopLength? length,
  }) async {
    final l = length ?? TopLength.week;

    final resp = await _dio.get(
      '$_basePath/top',
      queryParameters: {
        'length': l.name,
      },
    );

    final results = resp.data['top'] as List;

    return results
        .map((item) => PostDto.fromJson(
              item,
              _dio.options.baseUrl,
            ))
        .toList();
  }
}

typedef AnimePicturesDownloadUrlData = ({
  String url,
  String cookie,
});
