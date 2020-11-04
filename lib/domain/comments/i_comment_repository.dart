import 'package:boorusama/domain/comments/comment.dart';

abstract class ICommentRepository {
  Future<List<Comment>> getCommentsFromPostId(int postId);
}