part of 'comment_bloc.dart';

@freezed
abstract class CommentState with _$CommentState {
  const factory CommentState.empty() = _Empty;
  const factory CommentState.error() = _Error;
  const factory CommentState.addedSuccess() = _AddedSuccess;
  const factory CommentState.loading() = _Loading;
  const factory CommentState.fetched({@required List<Comment> comments}) =
      _Fetched;
}
