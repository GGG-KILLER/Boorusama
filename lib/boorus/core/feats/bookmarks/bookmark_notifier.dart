// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/toast.dart';

final bookmarkProvider = NotifierProvider<BookmarkNotifier, BookmarkState>(
  BookmarkNotifier.new,
  dependencies: [
    bookmarkRepoProvider,
    downloadServiceProvider,
    settingsProvider,
  ],
);

class BookmarkNotifier extends Notifier<BookmarkState> {
  @override
  BookmarkState build() {
    getAllBookmarks();
    return BookmarkState(bookmarks: <Bookmark>[].lock);
  }

  BookmarkRepository get bookmarkRepository => ref.read(bookmarkRepoProvider);

  Future<void> getAllBookmarks({
    void Function(BookmarkGetError error)? onError,
  }) async {
    bookmarkRepository.getAllBookmarks().run().then(
          (value) => value.match(
            (error) => onError?.call(error),
            (bookmarks) => state = state.copyWith(
              bookmarks: bookmarks.lock,
            ),
          ),
        );
  }

  Future<void> addBookmarks(
    int booruId,
    String booruUrl,
    List<Post> posts, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      final bookmarks =
          await bookmarkRepository.addBookmarks(booruId, booruUrl, posts);
      onSuccess?.call();
      state = state.copyWith(
        bookmarks: state.bookmarks.addAll(bookmarks),
      );
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> addBookmark(
    int booruId,
    String booruUrl,
    Post post, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      final bookmark =
          await bookmarkRepository.addBookmark(booruId, booruUrl, post);
      onSuccess?.call();
      state = state.copyWith(
        bookmarks: state.bookmarks.add(bookmark),
      );
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> removeBookmark(
    Bookmark bookmark, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      await bookmarkRepository.removeBookmark(bookmark);
      onSuccess?.call();
      state = state.copyWith(
        bookmarks: state.bookmarks.remove(bookmark),
      );
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> updateBookmark(
    Bookmark bookmark, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      await bookmarkRepository.updateBookmark(bookmark);
      onSuccess?.call();
      state = state.copyWith(
        bookmarks: state.bookmarks.replaceFirstWhere(
          (item) => item.id == bookmark.id,
          (item) => bookmark,
        ),
      );
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> downloadAllBookmarks() async {
    final settings = ref.read(settingsProvider);
    final tasks = state.bookmarks
        .map((bookmark) => ref
            .read(downloadServiceProvider)
            .downloadWithSettings(
              settings,
              url: bookmark.originalUrl,
              folderName: "Bookmarks",
              fileNameBuilder: () =>
                  bookmark.md5 + extension(bookmark.originalUrl),
            )
            .run())
        .toList();
    await Future.wait(tasks);
  }
}

extension BookmarkNotifierX on WidgetRef {
  BookmarkNotifier get bookmarks => read(bookmarkProvider.notifier);
}

extension BookmarkCubitToastX on BookmarkNotifier {
  Future<void> addBookmarkWithToast(
    int booruId,
    String booruUrl,
    Post post,
  ) =>
      addBookmark(
        booruId,
        booruUrl,
        post,
        onSuccess: () => showSuccessToast('bookmark.added'.tr()),
        onError: () => showErrorToast('bookmark.failed_to_add'.tr()),
      );

  Future<void> addBookmarksWithToast(
    int booruId,
    String booruUrl,
    List<Post> posts,
  ) =>
      addBookmarks(
        booruId,
        booruUrl,
        posts,
        onSuccess: () => showSuccessToast(
          'bookmark.many_added'.tr().replaceAll('{0}', '${posts.length}'),
        ),
        onError: () => showErrorToast('bookmark.failed_to_add_many'.tr()),
      );

  Future<void> removeBookmarkWithToast(Bookmark bookmark) => removeBookmark(
        bookmark,
        onSuccess: () => showSuccessToast('bookmark.removed'.tr()),
        onError: () => showErrorToast('bookmark.failed_to_remove'.tr()),
      );

  Future<void> updateBookmarkWithToast(Bookmark bookmark) => updateBookmark(
        bookmark,
        onSuccess: () => showSuccessToast('bookmark.updated'.tr()),
        onError: () => showErrorToast('bookmark.failed_to_update'.tr()),
      );

  Future<void> getAllBookmarksWithToast() => getAllBookmarks(
        onError: (error) => showErrorToast(
            'bookmark.failed_to_load'.tr().replaceAll('{0}', error.toString())),
      );
}

class BookmarkState extends Equatable {
  final IList<Bookmark> bookmarks;
  final String error;

  const BookmarkState({
    required this.bookmarks,
    this.error = '',
  });

  BookmarkState copyWith({
    IList<Bookmark>? bookmarks,
    String? error,
  }) {
    return BookmarkState(
      bookmarks: bookmarks ?? this.bookmarks,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [bookmarks, error];
}

extension BookmarkCubitX on BookmarkState {
  // check if a post is bookmarked
  bool isBookmarked(Post post, BooruType booru) {
    return bookmarks.any((b) =>
        b.booruId == booru.toBooruId() &&
        b.originalUrl == post.originalImageUrl);
  }

  // get bookmark from Post
  Bookmark? getBookmark(Post post, BooruType booru) {
    return bookmarks.firstWhereOrNull((b) =>
        b.booruId == booru.toBooruId() &&
        b.originalUrl == post.originalImageUrl);
  }
}