// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Project imports:
import 'package:boorusama/core/feats/settings/settings.dart';
import 'firebase/firebase.dart';

enum AppErrorType {
  failedToLoadBooruConfig,
  booruConfigNotFound,
  cannotReachServer,
  failedToParseJSON,
  loadDataFromServerFailed,
  unknown,
}

sealed class BooruError extends Error {}

class AppError extends BooruError with EquatableMixin {
  AppError({
    required this.type,
  });

  final AppErrorType type;

  @override
  String toString() => 'Error: $type';

  @override
  List<Object?> get props => [type];
}

class ServerError extends BooruError with EquatableMixin {
  ServerError({
    required this.httpStatusCode,
    required this.message,
  });

  final int? httpStatusCode;
  final dynamic message;

  @override
  String toString() => 'HTTP error with status code $httpStatusCode';

  @override
  List<Object?> get props => [httpStatusCode];
}

class UnknownError extends BooruError {
  UnknownError({
    required this.error,
  }) : super();

  final Object error;

  @override
  String toString() => error.toString();
}

extension ServerErrorX on ServerError {
  bool get isNotFound => httpStatusCode == 404;
  bool get isForbidden => httpStatusCode == 403;
  bool get isUnauthorized => httpStatusCode == 401;
  bool get isBadRequest => httpStatusCode == 400;
  bool get isInternalServerError => httpStatusCode == 500;
  bool get isServiceUnavailable => httpStatusCode == 503;
  bool get isGatewayTimeout => httpStatusCode == 504;

  bool get isClientError => httpStatusCode! >= 400 && httpStatusCode! < 500;
  bool get isServerError => httpStatusCode! >= 500 && httpStatusCode! < 600;
}

void initializeErrorHandlers(Settings settings) {
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (details) {
    if (kReleaseMode &&
        isFirebaseCrashlyticsSupportedPlatforms() &&
        settings.dataCollectingStatus == DataCollectingStatus.allow) {
      // Ignore 304 errors
      if (details.exception is DioException) {
        final exception = details.exception as DioException;
        if (exception.response?.statusCode == 304) return;
      }

      // Ignore image service errors
      if (details.library == 'image resource service') return;

      FirebaseCrashlytics.instance.recordFlutterFatalError(details);

      return;
    }

    FlutterError.presentError(details);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kReleaseMode &&
        isFirebaseCrashlyticsSupportedPlatforms() &&
        settings.dataCollectingStatus == DataCollectingStatus.allow) {
      // Ignore 304 errors
      if (error is DioException) {
        if (error.response?.statusCode == 304) return true;
      }

      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }

    return true;
  };
}

String prettyPrintJson(dynamic json) {
  if (json == null) return '';

  if (json is Map<String, dynamic>) {
    return const JsonEncoder.withIndent('  ').convert(json);
  }
  final jsonStr = json.toString();

  final jsonObj = json.decode(jsonStr);
  return const JsonEncoder.withIndent('  ').convert(jsonObj);
}

String wrapIntoJsonToCodeBlock(String json) {
  return '```json\n$json\n```';
}

String wrapIntoCodeBlock(String code) {
  return '```\n$code\n```';
}

extension StackTraceX on StackTrace {
  String prettyPrinted({int? maxFrames}) {
    Iterable<String> lines = toString().trimRight().split('\n');
    if (kIsWeb && lines.isNotEmpty) {
      lines = lines.skipWhile((String line) {
        return line.contains('StackTrace.current') ||
            line.contains('dart-sdk/lib/_internal') ||
            line.contains('dart:sdk_internal');
      });
    }
    if (maxFrames != null) {
      lines = lines.take(maxFrames);
    }

    return lines.join('\n');
  }
}
