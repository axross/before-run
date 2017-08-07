import 'dart:async';
import 'package:postgresql/postgresql.dart' show Connection;
import '../entity/session.dart';
import '../entity/user.dart';
import './src/deserialize.dart';

class SessionDatastore {
  Future<Session> getByToken(Connection connection, String token) async {
    final rows = await connection.query('select token from sessions where token = @token limit 1;', {
      'token': token,
    }).toList();

    if (rows.isEmpty) {
      throw new SessionNotFoundException(token);
    }

    return deserializeToSession(rows.single);
  }

  Future<Session> create(Connection connection, User user) async {
    final temporarySession = new Session.generateWithUser(user);
    final row = await connection.query('insert into sessions (token, user_id, created_at) values (@token, @userId, @now) returning token;', {
      'token': temporarySession.token,
      'userId': user.id,
      'now': new DateTime.now(),
    }).single;

    return deserializeToSession(row);
  }

  Future<dynamic> delete(Connection connection, String token) async {
    final affectedRows = await connection.execute('delete from sessions where token = @token;', {
      'token': token,
    });

    if (affectedRows == 0) {
      throw new SessionNotFoundException(token);
    }
  }
}

class SessionNotFoundException implements Exception {
  final String token;

  String toString() => 'Authentication token "$token" is not a valid token.';

  SessionNotFoundException(this.token);
}
