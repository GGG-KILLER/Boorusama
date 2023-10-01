// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/functional.dart';
import 'bookmark.dart';

enum BookmarkGetError {
  nullField,
  databaseClosed,
  unknown,
}

typedef BookmarksOrError = TaskEither<BookmarkGetError, List<Bookmark>>;

abstract class BookmarkRepository {
  Future<Bookmark> addBookmark(
    int booruId,
    String booruUrl,
    Post post,
  );
  Future<List<Bookmark>> addBookmarks(
    int booruId,
    String booruUrl,
    List<Post> posts,
  );
  Future<void> removeBookmark(Bookmark favorite);
  Future<void> updateBookmark(Bookmark favorite);
  BookmarksOrError getAllBookmarks();
}