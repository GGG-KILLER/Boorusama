// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'user.dart';

abstract class IUserRepository {
  Future<List<User>> getUsersByIdStringComma(
    String idComma, {
    CancelToken cancelToken,
  });
  Future<User> getUserById(int id);
}
