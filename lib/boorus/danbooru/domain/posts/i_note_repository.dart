import 'note.dart';

abstract class INoteRepository {
  Future<List<Note>> getNotesFrom(int postId);
}