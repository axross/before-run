import 'dart:async';
import 'package:meta/meta.dart';
import 'package:postgresql/pool.dart' show Pool;
import '../entity/session.dart';
import '../entity/user.dart';
import './src/deserialize.dart';
import './src/resource_exception.dart';

class SessionRepository {
  final Pool _postgresConnectionPool;

  Future<Session> getSessionByToken(String token) async {
    final connection = await _postgresConnectionPool.connect();

    try {
      final rows = await connection.query('select token from sessions where token = @token limit 1;', {
        'token': token,
      }).toList();

      if (rows.isEmpty) {
        throw new SessionNotFoundException(token);
      }

      return deserializeToSession(rows.first);
    } finally {
      connection.close();
    }
  }

  Future<Session> createSession(User user) async {
    final connection = await _postgresConnectionPool.connect();

    try {
      final temporarySession = new Session.generateWithUser(user);
      final row = await connection.query('insert into sessions (token, user_id, created_at) values (@token, @userId, @now) returning token;', {
        'token': temporarySession.token,
        'userId': user.id,
        'now': new DateTime.now(),
      }).single;

      return deserializeToSession(row);
    } finally {
      connection.close();
    }
  }

  Future<dynamic> deleteSession(String token) async {
    final connection = await _postgresConnectionPool.connect();

    try {
      final affectedRows = await connection.execute('delete from sessions where token = @token;', {
        'token': token,
      });

      if (affectedRows == 0) {
        throw new SessionNotFoundException(token);
      }
    } finally {
      connection.close();
    }
  }

  SessionRepository({@required Pool postgresConnectionPool}):
    _postgresConnectionPool = postgresConnectionPool;
}