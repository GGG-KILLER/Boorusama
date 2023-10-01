// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/foundation/http/dio_logger_interceptor.dart';
import 'package:boorusama/foundation/http/user_agent_generator.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';

Dio dio(
  Directory dir,
  String? baseUrl,
  UserAgentGenerator generator,
  BooruConfig booruConfig,
  LoggerService logger,
) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl ?? '',
    headers: {
      'User-Agent': generator.generate(),
    },
  ));

  if (booruConfig.booruType.supportHttp2) {
    dio.httpClientAdapter = Http2Adapter(
      ConnectionManager(
        idleTimeout: const Duration(seconds: 30),
      ),
    );
  }

  dio.interceptors.add(
    DioCacheInterceptor(
      options: CacheOptions(
        store: HiveCacheStore(dir.path),
        maxStale: const Duration(days: 7),
        hitCacheOnErrorExcept: [],
      ),
    ),
  );

  dio.interceptors.add(
    LoggingInterceptor(
      logger: logger,
      booruConfig: booruConfig,
    ),
  );

  return dio;
}