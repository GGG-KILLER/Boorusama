// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/functional.dart';

DownloadPathOrError downloadUrl({
  required Dio dio,
  required DownloadNotifications notifications,
  required String url,
  required DownloadFileNameBuilder fileNameBuilder,
  bool enableNotification = true,
}) =>
    TaskEither.Do(($) async {
      final dir = await $(
          tryGetDownloadDirectory().mapLeft((error) => GenericDownloadError(
                message: error.name,
                fileName: fileNameBuilder(),
                savedPath: none(),
              )));

      final path = await $(joinDownloadPath(fileNameBuilder(), dir));

      return _wrapWithNotification(
        () => $(downloadWithDio(dio, url: url, path: path)),
        notifications: notifications,
        path: path,
        enableNotification: enableNotification,
      );
    });

DownloadPathOrError downloadUrlCustomLocation({
  required Dio dio,
  required DownloadNotifications notifications,
  required String path,
  required String url,
  required DownloadFileNameBuilder fileNameBuilder,
  bool enableNotification = true,
}) =>
    TaskEither.Do(($) async {
      final dir = await $(tryGetCustomDownloadDirectory(path)
          .mapLeft((error) => GenericDownloadError(
                message: error.name,
                fileName: fileNameBuilder(),
                savedPath: none(),
              )));

      final filePath = await $(joinDownloadPath(fileNameBuilder(), dir));

      return _wrapWithNotification(
        () => $(downloadWithDio(dio, url: url, path: filePath)),
        notifications: notifications,
        path: filePath,
        enableNotification: enableNotification,
      );
    });

DownloadPathOrError downloadWithDio(
  Dio dio, {
  required String url,
  required String path,
}) =>
    TaskEither.tryCatch(
      () async => dio.download(url, path).then((value) => path),
      (error, stackTrace) {
        final fileName = basename(path);

        return switch (error) {
          FileSystemException e => FileSystemDownloadError(
              savedPath: some(path),
              fileName: fileName,
              error: e,
            ),
          DioException e => HttpDownloadError(
              savedPath: some(path),
              fileName: fileName,
              exception: e,
            ),
          _ => GenericDownloadError(
              savedPath: some(path),
              fileName: fileName,
              message: error.toString(),
            ),
        };
      },
    );

DownloadPathOrError joinDownloadPath(
  String fileName,
  Directory directory,
) =>
    TaskEither.fromEither(Either.of(join(directory.path, fileName)));

Future<String> _wrapWithNotification(
  Future<String> Function() fn, {
  required DownloadNotifications notifications,
  required String path,
  bool enableNotification = true,
}) async {
  final fileName = path.split('/').last;

  if (enableNotification) {
    await notifications.showInProgress(fileName, path);
  }

  final result = await fn();
  if (enableNotification) {
    await notifications.showCompleted(fileName, path);
  }

  return result;
}